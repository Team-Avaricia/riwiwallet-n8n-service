# 🔄 RiwiWallet n8n Service

> Servicio de automatizaciones para RiwiWallet - Procesamiento inteligente de correos bancarios, alertas financieras proactivas y workflows de IA.

---

## 📋 Descripción

Este repositorio contiene las **automatizaciones críticas** de RiwiWallet, incluyendo:

- 📧 **Parsing de correos bancarios** (Bancolombia, Nequi, Davivienda, etc.)
- 🤖 **Clasificación de gastos con IA** (LLM → categorías → presupuesto)
- 🔔 **Alertas proactivas** (límites de gasto, movimientos sospechosos)
- 📊 **Proyecciones financieras** (burn rate, predicciones, recomendaciones)
- 🔗 **Integración con el backend** (webhooks seguros, sincronización)

---

## 🐳 Contenedores en Producción

El servicio de n8n ya se encuentra desplegado y activo. Los contenedores principales son:

| Contenedor | Imagen | Descripción |
|------------|--------|-------------|
| `riwi_n8n` | `n8nio/n8n:latest` | Motor de workflows principal |
| `riwi_redis` | `redis:7-alpine` | Cola de mensajes y caché para n8n |

---

## 📁 Estructura del Repositorio

```
/riwiwallet-n8n-service
│
├── workflows/
│   ├── email-parsing/          # Flujos para leer y parsear correos bancarios
│   │   ├── bancolombia-nequi-parser.json
│   │   └── README.md           # Documentación específica del parser
│   ├── user-sync/              # Sincronización de datos de usuario
│   ├── notifications/          # Alertas y mensajes proactivos
│   ├── finance-analytics/      # Cálculos, reportes y proyecciones IA
│   └── README.md               # Documentación general de workflows
│
├── scripts/
│   ├── export-workflows.sh     # Exportar workflows desde n8n
│   ├── import-workflows.sh     # Importar workflows en nuevos entornos
│   └── backup.sh               # Respaldos automáticos
│
├── docs/
│   ├── architecture.md         # Arquitectura del servicio
│   ├── security-policies.md    # Políticas de seguridad
│   └── webhook-contracts.md    # Contratos de API (request/response)
│
└── README.md                   # Este archivo
```

---

## 🚀 Uso del Repositorio

Este repositorio sirve para **versionar y respaldar** los workflows de n8n.

### 1. Clonar el repositorio

```bash
git clone https://github.com/Team-Avaricia/riwiwallet-n8n-service.git
cd riwiwallet-n8n-service
```

### 2. Acceder a n8n

El servicio está activo en: `https://n8n.avaricia.crudzaso.com`

---

## 📥 Importar/Exportar Workflows

### Exportar workflows (Backup)

Para guardar cambios hechos en n8n:
1. Exportar el workflow desde la UI de n8n (Download JSON).
2. Guardar el archivo en la carpeta correspondiente dentro de `workflows/`.
3. Hacer commit y push.

```bash
git add workflows/
git commit -m "feat: update workflow logic"
git push
```

### Importar workflows

Para cargar un workflow en n8n:
1. Copiar el contenido del archivo JSON.
2. En n8n, ir a "Import from File" o pegar directamente en el editor.

---

## 🔐 Seguridad

### Comunicación Backend ↔ n8n

| Aspecto | Implementación |
|---------|----------------|
| Autenticación | Token secreto + firma HMAC |
| Red | n8n en red privada |
| Acceso | Solo el backend puede comunicarse |
| Logs | Auditados y monitoreados |
| Datos sensibles | Cifrado AES en el backend |

### Buenas Prácticas

- ❌ **NO** guardar tokens directamente en workflows
- ✅ **SÍ** usar credenciales cifradas de n8n
- ❌ **NO** hacer llamadas directas a la base de datos
- ✅ **SÍ** todo pasa por el backend vía API
- ❌ **NO** exponer webhooks sin autenticación
- ✅ **SÍ** validar todas las peticiones entrantes

---

## 📊 Workflows Principales

### 1. 📧 Email Parsing
- Lectura de correos de bancos colombianos
- Extracción de transacciones (monto, fecha, comercio)
- Clasificación automática con IA
- [Ver documentación detallada](workflows/email-parsing/README.md)

### 2. 🔔 Alertas Proactivas
- 80% del límite semanal alcanzado
- Gastos atípicos detectados
- Movimientos sospechosos

### 3. 📈 Proyecciones Financieras
- Cálculo de burn rate
- Predicciones semanales/mensuales
- Recomendaciones personalizadas

### 4. 🔄 Sincronización
- Sync de datos de usuario
- Actualización de límites y presupuestos
- Eventos en tiempo real

---

## 🔗 Endpoints del Backend → n8n

| Endpoint Backend | Webhook n8n | Descripción |
|-----------------|-------------|-------------|
| `POST /api/transactions/sync` | `/webhook/sync-transactions` | Sincronizar transacciones |
| `POST /api/alerts/evaluate` | `/webhook/evaluate-alerts` | Evaluar reglas de alertas |
| `POST /api/emails/parse` | `/webhook/parse-email` | Parsear correo bancario |
| `POST /api/analytics/project` | `/webhook/financial-projection` | Generar proyección |

---

## 🖥️ Servidor de Producción

| Servicio | URL | Estado |
|----------|-----|--------|
| n8n | https://n8n.avaricia.crudzaso.com | ✅ Activo |
| Wiki.js | https://docs.avaricia.crudzaso.com | ✅ Activo |

> **Última actualización:** 12 de Diciembre 2025

---

## 📚 Documentación Adicional

- [Políticas de Seguridad](docs/security-policies.md)
- [Contratos de Webhook](docs/webhook-contracts.md)

---

## 📄 Licencia

Este proyecto es privado y pertenece a **Team Avaricia** - RiwiWallet.
