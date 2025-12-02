# 🏗️ Arquitectura del Sistema n8n

## Visión General

El servicio n8n actúa como el **motor de automatizaciones** de RiwiWallet, procesando correos bancarios, ejecutando análisis con IA y generando alertas proactivas.

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                           USUARIOS                                   │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         FRONTEND (Next.js)                          │
│                                                                      │
│  • Dashboard de finanzas                                            │
│  • Visualización de transacciones                                   │
│  • Configuración de alertas                                         │
│  • Presupuestos y metas                                             │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         BACKEND (NestJS)                            │
│                                                                      │
│  • API REST                    • Autenticación JWT                  │
│  • Gestión de usuarios         • Validación de datos               │
│  • CRUD de transacciones       • Orquestación de servicios         │
│  • Cifrado AES de datos        • Gateway hacia n8n                 │
└─────────────────────────────────────────────────────────────────────┘
                    │                               │
                    ▼                               ▼
┌─────────────────────────────┐   ┌─────────────────────────────────┐
│       PostgreSQL            │   │         n8n SERVICE             │
│                             │   │                                  │
│  • Usuarios                 │   │  • Parsing de correos           │
│  • Transacciones            │   │  • Clasificación con IA         │
│  • Presupuestos             │   │  • Alertas proactivas           │
│  • Configuraciones          │   │  • Proyecciones financieras     │
│  • Logs de auditoría        │   │  • Sincronización               │
└─────────────────────────────┘   └─────────────────────────────────┘
                                                    │
                                                    ▼
                                  ┌─────────────────────────────────┐
                                  │        SERVICIOS EXTERNOS       │
                                  │                                  │
                                  │  • Gmail API (correos)          │
                                  │  • OpenAI API (clasificación)   │
                                  │  • Servicios de notificación    │
                                  └─────────────────────────────────┘
```

## Flujo de Datos

### 1. Procesamiento de Correos Bancarios

```
1. Usuario conecta su email (OAuth)
2. Backend almacena tokens cifrados
3. n8n ejecuta workflow periódico:
   a. Lee correos nuevos de bancos
   b. Parsea contenido (monto, comercio, fecha)
   c. Clasifica transacción con OpenAI
   d. Envía a backend vía webhook
4. Backend guarda en DB
5. Frontend actualiza UI
```

### 2. Sistema de Alertas

```
1. Backend recibe nueva transacción
2. Llama webhook de evaluación en n8n
3. n8n ejecuta reglas:
   a. ¿Superó 80% del presupuesto semanal?
   b. ¿Es un gasto atípico?
   c. ¿Movimiento sospechoso?
4. Si hay alerta, n8n notifica al backend
5. Backend envía push notification
```

### 3. Proyecciones Financieras

```
1. Usuario solicita proyección
2. Backend envía datos históricos a n8n
3. n8n ejecuta análisis:
   a. Calcula burn rate
   b. Genera predicción con IA
   c. Crea recomendaciones
4. Retorna proyección al backend
5. Frontend muestra resultados
```

## Principios de Diseño

### 🔒 Seguridad Primero

- **Aislamiento**: n8n corre en red privada
- **Autenticación**: Todos los webhooks requieren token + HMAC
- **Cifrado**: Datos sensibles cifrados con AES-256
- **Auditoría**: Todos los eventos se registran

### 🔄 Desacoplamiento

- n8n no accede directamente a la base de datos
- Toda comunicación es vía API del backend
- Permite escalar cada servicio independientemente

### 📈 Escalabilidad

- n8n usa Redis para colas de trabajo
- Workflows se ejecutan de forma asíncrona
- PostgreSQL optimizado para consultas financieras

## Comunicación Backend ↔ n8n

### Endpoints del Backend que llaman a n8n

| Método | Endpoint Backend | Webhook n8n |
|--------|-----------------|-------------|
| POST | `/api/emails/process` | `/webhook/parse-email` |
| POST | `/api/transactions/classify` | `/webhook/classify-transaction` |
| POST | `/api/alerts/evaluate` | `/webhook/evaluate-alerts` |
| POST | `/api/analytics/project` | `/webhook/financial-projection` |
| POST | `/api/sync/user-data` | `/webhook/sync-user` |

### Formato de Request

```json
{
  "userId": "uuid",
  "timestamp": "ISO8601",
  "signature": "HMAC-SHA256",
  "payload": {
    // datos específicos del workflow
  }
}
```

### Formato de Response

```json
{
  "success": true,
  "workflowId": "abc123",
  "executionId": "exec_456",
  "result": {
    // resultado del workflow
  }
}
```

## Ambientes

| Ambiente | URL n8n | Base de datos |
|----------|---------|---------------|
| Desarrollo | `http://localhost:5678` | PostgreSQL local |
| Staging | `https://n8n-staging.riwiwallet.com` | PostgreSQL staging |
| Producción | `https://n8n.riwiwallet.com` | PostgreSQL prod (RDS) |

## Monitoreo

### Métricas Clave

- Tiempo de ejecución de workflows
- Tasa de errores por workflow
- Webhooks procesados por minuto
- Latencia de respuesta

### Herramientas Recomendadas

- **Logs**: n8n logs + CloudWatch
- **Métricas**: Prometheus + Grafana
- **Alertas**: PagerDuty / Slack

## Backup y Recuperación

### Estrategia de Backup

1. **Workflows**: Exportados a Git (este repo)
2. **Credenciales**: Backup cifrado diario
3. **Base de datos**: Snapshots cada 6 horas
4. **Ejecuciones**: Retención de 30 días

### Plan de Recuperación

1. Desplegar nueva instancia de n8n
2. Restaurar base de datos
3. Importar workflows desde Git
4. Reconfigurar credenciales
5. Validar webhooks

**RTO**: 1 hora | **RPO**: 6 horas

