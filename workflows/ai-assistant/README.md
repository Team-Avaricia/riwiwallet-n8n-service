# 🤖 AI Financial Assistant Workflow

Este workflow actúa como el motor de ejecución para el Asistente Financiero con IA.

## 📝 Descripción

Recibe comandos estructurados en JSON desde un sistema externo (tu IA o Chatbot) y ejecuta las acciones correspondientes en el Backend de RiwiWallet.

## ⚙️ Configuración

Este workflow usa la siguiente variable de entorno para conectar con el Backend:

- `BACKEND_URL`: URL base de la API (ej: `http://riwi_api:8080` o `https://api.midominio.com`).
- **Valor por defecto:** `https://api.avaricia.crudzaso.com` (Producción).

## 🔗 Webhook Trigger

**Método:** `POST`
**Path:** `/webhook/ai-action`

### Payload Esperado

El workflow espera un JSON con la siguiente estructura (basada en el Prompt del Sistema):

```json
{
  "intent": "create_expense",
  "userId": "uuid-del-usuario",
  "amount": 50000,
  "category": "Comida",
  "description": "Almuerzo",
  "type": "Expense",
  "startDate": "2024-01-01", // Opcional, para filtros
  "endDate": "2024-01-31",   // Opcional, para filtros
  "searchQuery": "Netflix"   // Opcional, para búsquedas
}
```

## 🧠 Lógica de Negocio

El nodo **Switch Intent** enruta la petición basándose en el campo `intent`:

| Intent | Acción Backend |
|--------|----------------|
| `validate_expense` | `POST /api/SpendingValidation/validate` |
| `create_expense` | `POST /api/Transaction` |
| `create_income` | `POST /api/Transaction` |
| `list_transactions` | `GET /api/Transaction/user/{id}` |
| `list_transactions_by_date` | `GET /api/Transaction/user/{id}/date/{date}` |
| `list_transactions_by_range` | `GET /api/Transaction/user/{id}/range` |
| `search_transactions` | `GET /api/Transaction/user/{id}/search` |
| `get_balance` | `GET /api/User/{id}/balance` |
| `get_summary` | `GET /api/Transaction/user/{id}/summary/category` |
| `delete_transaction` | `DELETE /api/Transaction/{id}` |
| `create_rule` | `POST /api/FinancialRule` |
| `list_rules` | `GET /api/FinancialRule/user/{id}` |

## 🚀 Despliegue

1. Importar `ai-financial-assistant.json` en n8n.
2. Activar el workflow.
3. Configurar tu Chatbot/IA para enviar peticiones a la URL del Webhook.
