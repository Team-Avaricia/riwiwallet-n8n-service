# 📡 Contratos de Webhook

Este documento define la estructura formal de las comunicaciones entre el **Backend de RiwiWallet** y el **servicio n8n**.

---

## Convenciones Generales

### Headers Requeridos

Todos los webhooks deben incluir estos headers:

```http
Content-Type: application/json
X-Webhook-Token: <WEBHOOK_SECRET_TOKEN>
X-Signature: <HMAC-SHA256 del body>
X-Request-Id: <UUID único por request>
X-Timestamp: <ISO 8601 timestamp>
```

### Estructura Base de Request

```json
{
  "requestId": "uuid-v4",
  "timestamp": "2024-12-01T10:30:00.000Z",
  "userId": "user-uuid",
  "action": "nombre_de_accion",
  "payload": {
    // datos específicos
  }
}
```

### Estructura Base de Response

```json
{
  "success": true,
  "requestId": "uuid-v4",
  "executionId": "n8n-execution-id",
  "timestamp": "2024-12-01T10:30:01.000Z",
  "data": {
    // resultado específico
  },
  "errors": []
}
```

---

## 1. Parse Email (Correo Bancario)

### Endpoint
`POST /webhook/parse-email`

### Descripción
Procesa un correo bancario y extrae información de transacción.

### Request

```json
{
  "requestId": "550e8400-e29b-41d4-a716-446655440001",
  "timestamp": "2024-12-01T10:30:00.000Z",
  "userId": "user-123",
  "action": "parse_email",
  "payload": {
    "emailId": "email-abc123",
    "from": "alertasynotificaciones@bancolombia.com.co",
    "subject": "Bancolombia le informa",
    "body": "Se ha realizado una compra por $45,000 en EXITO...",
    "receivedAt": "2024-12-01T10:25:00.000Z",
    "bank": "bancolombia"
  }
}
```

### Response (Éxito)

```json
{
  "success": true,
  "requestId": "550e8400-e29b-41d4-a716-446655440001",
  "executionId": "exec_789",
  "timestamp": "2024-12-01T10:30:02.000Z",
  "data": {
    "transaction": {
      "type": "expense",
      "amount": 45000,
      "currency": "COP",
      "merchant": "EXITO",
      "category": "groceries",
      "confidence": 0.95,
      "date": "2024-12-01T10:25:00.000Z",
      "description": "Compra en supermercado",
      "accountLastFour": "1234"
    },
    "metadata": {
      "parsingMethod": "regex_v2",
      "processingTime": 1250
    }
  },
  "errors": []
}
```

### Response (Error de Parsing)

```json
{
  "success": false,
  "requestId": "550e8400-e29b-41d4-a716-446655440001",
  "executionId": "exec_790",
  "timestamp": "2024-12-01T10:30:02.000Z",
  "data": null,
  "errors": [
    {
      "code": "PARSE_FAILED",
      "message": "No se pudo extraer información de transacción",
      "details": {
        "reason": "unknown_email_format"
      }
    }
  ]
}
```

---

## 2. Classify Transaction (Clasificar Transacción)

### Endpoint
`POST /webhook/classify-transaction`

### Descripción
Clasifica una transacción usando IA (categoría, tipo, etc.)

### Request

```json
{
  "requestId": "550e8400-e29b-41d4-a716-446655440002",
  "timestamp": "2024-12-01T10:35:00.000Z",
  "userId": "user-123",
  "action": "classify_transaction",
  "payload": {
    "transactionId": "txn-456",
    "amount": 150000,
    "merchant": "NETFLIX.COM",
    "description": "Pago mensual",
    "date": "2024-12-01T00:00:00.000Z",
    "userContext": {
      "previousCategories": ["entertainment", "subscriptions"],
      "monthlyBudgets": {
        "entertainment": 200000,
        "subscriptions": 100000
      }
    }
  }
}
```

### Response

```json
{
  "success": true,
  "requestId": "550e8400-e29b-41d4-a716-446655440002",
  "executionId": "exec_791",
  "timestamp": "2024-12-01T10:35:03.000Z",
  "data": {
    "classification": {
      "category": "subscriptions",
      "subcategory": "streaming",
      "confidence": 0.98,
      "isRecurring": true,
      "recurringPattern": "monthly",
      "tags": ["digital", "entertainment", "fixed_expense"]
    },
    "aiInsights": {
      "model": "gpt-4",
      "reasoning": "Netflix es un servicio de streaming con cobro mensual fijo",
      "alternativeCategories": [
        {"category": "entertainment", "confidence": 0.85}
      ]
    }
  },
  "errors": []
}
```

---

## 3. Evaluate Alerts (Evaluar Alertas)

### Endpoint
`POST /webhook/evaluate-alerts`

### Descripción
Evalúa si una transacción debe generar alertas basándose en reglas configuradas.

### Request

```json
{
  "requestId": "550e8400-e29b-41d4-a716-446655440003",
  "timestamp": "2024-12-01T11:00:00.000Z",
  "userId": "user-123",
  "action": "evaluate_alerts",
  "payload": {
    "transaction": {
      "id": "txn-789",
      "amount": 500000,
      "category": "shopping",
      "merchant": "ZARA",
      "date": "2024-12-01T10:55:00.000Z"
    },
    "userRules": {
      "weeklyBudget": 600000,
      "currentWeekSpent": 450000,
      "alertThreshold": 0.8,
      "unusualAmountThreshold": 300000,
      "blockedCategories": []
    },
    "historicalData": {
      "averageTransactionAmount": 85000,
      "maxTransactionLast30Days": 250000,
      "categoryAverages": {
        "shopping": 120000
      }
    }
  }
}
```

### Response

```json
{
  "success": true,
  "requestId": "550e8400-e29b-41d4-a716-446655440003",
  "executionId": "exec_792",
  "timestamp": "2024-12-01T11:00:04.000Z",
  "data": {
    "alerts": [
      {
        "type": "BUDGET_THRESHOLD",
        "severity": "high",
        "title": "¡Cuidado! Estás llegando al límite",
        "message": "Has gastado el 95% de tu presupuesto semanal ($950,000 de $600,000)",
        "data": {
          "budgetType": "weekly",
          "budgetAmount": 600000,
          "spentAmount": 950000,
          "percentageUsed": 158
        }
      },
      {
        "type": "UNUSUAL_AMOUNT",
        "severity": "medium",
        "title": "Gasto inusual detectado",
        "message": "Esta compra de $500,000 es 5.9x mayor que tu promedio ($85,000)",
        "data": {
          "transactionAmount": 500000,
          "userAverage": 85000,
          "multiplier": 5.88
        }
      }
    ],
    "recommendations": [
      {
        "type": "BUDGET_ADJUSTMENT",
        "message": "Considera aumentar tu presupuesto semanal o reducir gastos en 'shopping'"
      }
    ],
    "shouldNotify": true,
    "notificationPriority": "high"
  },
  "errors": []
}
```

---

## 4. Financial Projection (Proyección Financiera)

### Endpoint
`POST /webhook/financial-projection`

### Descripción
Genera proyecciones financieras usando IA basándose en datos históricos.

### Request

```json
{
  "requestId": "550e8400-e29b-41d4-a716-446655440004",
  "timestamp": "2024-12-01T12:00:00.000Z",
  "userId": "user-123",
  "action": "financial_projection",
  "payload": {
    "projectionType": "weekly",
    "historicalData": {
      "income": {
        "monthly": 4500000,
        "sources": [
          {"type": "salary", "amount": 4000000},
          {"type": "freelance", "amount": 500000}
        ]
      },
      "expenses": {
        "last30Days": 3200000,
        "byCategory": {
          "housing": 1200000,
          "food": 600000,
          "transport": 300000,
          "entertainment": 400000,
          "subscriptions": 200000,
          "shopping": 500000
        }
      },
      "trends": {
        "expenseGrowthRate": 0.05,
        "savingsRate": 0.28
      }
    },
    "goals": [
      {"type": "savings", "target": 500000, "period": "monthly"},
      {"type": "reduce_spending", "category": "shopping", "target": 300000}
    ]
  }
}
```

### Response

```json
{
  "success": true,
  "requestId": "550e8400-e29b-41d4-a716-446655440004",
  "executionId": "exec_793",
  "timestamp": "2024-12-01T12:00:08.000Z",
  "data": {
    "projection": {
      "period": "next_7_days",
      "estimatedExpenses": 800000,
      "estimatedIncome": 0,
      "projectedBalance": -800000,
      "burnRate": {
        "daily": 106667,
        "weekly": 800000,
        "monthly": 3200000
      },
      "byCategory": {
        "food": 150000,
        "transport": 75000,
        "entertainment": 100000,
        "other": 475000
      }
    },
    "insights": [
      {
        "type": "WARNING",
        "title": "Gasto en shopping por encima del objetivo",
        "description": "Gastaste $500,000 este mes, tu objetivo era $300,000",
        "impact": "Afecta tu meta de ahorro en $200,000"
      },
      {
        "type": "POSITIVE",
        "title": "Buen control en transporte",
        "description": "Estás 15% por debajo de tu promedio mensual"
      }
    ],
    "recommendations": [
      {
        "priority": "high",
        "action": "Reducir gastos en shopping",
        "potentialSavings": 200000,
        "difficulty": "medium"
      },
      {
        "priority": "medium",
        "action": "Revisar suscripciones activas",
        "potentialSavings": 50000,
        "difficulty": "easy"
      }
    ],
    "goalProgress": [
      {
        "goal": "Ahorro mensual $500,000",
        "currentProgress": 260000,
        "percentage": 52,
        "onTrack": false,
        "projectedCompletion": 390000
      }
    ],
    "aiSummary": "Basándome en tu historial, proyecto que gastarás aproximadamente $800,000 esta semana. Tu principal área de mejora es 'shopping', donde has excedido tu objetivo. Te recomiendo evitar compras impulsivas los próximos días para alcanzar tu meta de ahorro."
  },
  "errors": []
}
```

---

## 5. Sync User Data (Sincronizar Datos de Usuario)

### Endpoint
`POST /webhook/sync-user`

### Descripción
Sincroniza datos de configuración del usuario con n8n.

### Request

```json
{
  "requestId": "550e8400-e29b-41d4-a716-446655440005",
  "timestamp": "2024-12-01T13:00:00.000Z",
  "userId": "user-123",
  "action": "sync_user",
  "payload": {
    "syncType": "full",
    "userData": {
      "preferences": {
        "currency": "COP",
        "timezone": "America/Bogota",
        "language": "es",
        "notificationsEnabled": true
      },
      "budgets": {
        "weekly": 600000,
        "monthly": 2400000,
        "byCategory": {
          "food": 800000,
          "entertainment": 300000,
          "transport": 400000
        }
      },
      "alertRules": {
        "budgetThreshold": 0.8,
        "unusualAmountMultiplier": 3,
        "dailyDigest": true,
        "instantAlerts": ["BUDGET_EXCEEDED", "SUSPICIOUS_ACTIVITY"]
      },
      "connectedBanks": ["bancolombia", "nequi"]
    }
  }
}
```

### Response

```json
{
  "success": true,
  "requestId": "550e8400-e29b-41d4-a716-446655440005",
  "executionId": "exec_794",
  "timestamp": "2024-12-01T13:00:01.000Z",
  "data": {
    "syncStatus": "completed",
    "updatedFields": [
      "preferences",
      "budgets",
      "alertRules",
      "connectedBanks"
    ],
    "workflowsUpdated": [
      "email-parsing-bancolombia",
      "email-parsing-nequi",
      "alert-evaluation",
      "daily-digest"
    ],
    "nextScheduledSync": "2024-12-02T00:00:00.000Z"
  },
  "errors": []
}
```

---

## Códigos de Error

| Código | Descripción | Acción Recomendada |
|--------|-------------|-------------------|
| `AUTH_FAILED` | Token o firma inválidos | Verificar credenciales |
| `INVALID_PAYLOAD` | Estructura de request incorrecta | Revisar formato JSON |
| `PARSE_FAILED` | No se pudo procesar el contenido | Enviar para revisión manual |
| `AI_ERROR` | Error en servicio de IA | Reintentar o usar fallback |
| `RATE_LIMITED` | Demasiadas requests | Esperar y reintentar |
| `INTERNAL_ERROR` | Error interno de n8n | Contactar soporte |
| `TIMEOUT` | Workflow excedió tiempo límite | Optimizar workflow |

---

## Versionamiento

La versión actual de la API es **v1**. Cambios breaking se comunicarán con al menos 2 semanas de anticipación.

| Versión | Estado | Fecha |
|---------|--------|-------|
| v1 | Activa | Diciembre 2024 |

---

*Última actualización: Diciembre 2024*

