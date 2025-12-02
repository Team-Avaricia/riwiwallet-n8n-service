# 🔄 RiwiWallet n8n Service

> Servicio de automatizaciones para RiwiWallet - Procesamiento inteligente de correos bancarios, alertas financieras proactivas y workflows de IA.

[![n8n](https://img.shields.io/badge/n8n-Automation-FF6D5A?style=for-the-badge&logo=n8n&logoColor=white)](https://n8n.io/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com/)
[![Team Avaricia](https://img.shields.io/badge/Team-Avaricia-gold?style=for-the-badge)](https://github.com/Team-Avaricia)

---

## 📋 Descripción

Este repositorio contiene las **automatizaciones críticas** de RiwiWallet, incluyendo:

- 📧 **Parsing de correos bancarios** (Bancolombia, Nequi, Davivienda, etc.)
- 🤖 **Clasificación de gastos con IA** (LLM → categorías → presupuesto)
- 🔔 **Alertas proactivas** (límites de gasto, movimientos sospechosos)
- 📊 **Proyecciones financieras** (burn rate, predicciones, recomendaciones)
- 🔗 **Integración con el backend** (webhooks seguros, sincronización)

---

## 🏗️ Arquitectura

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Frontend  │────▶│   Backend   │────▶│    n8n      │
│  (Next.js)  │     │  (NestJS)   │     │  (Service)  │
└─────────────┘     └─────────────┘     └─────────────┘
                           │                    │
                           │                    ▼
                           │            ┌─────────────┐
                           │            │   OpenAI    │
                           │            │   (LLM)     │
                           │            └─────────────┘
                           ▼
                    ┌─────────────┐
                    │  PostgreSQL │
                    │   (DB)      │
                    └─────────────┘
```

> ⚠️ **Importante**: Solo el backend puede comunicarse con n8n. Nunca el frontend ni los usuarios directamente.

---

## 📁 Estructura del Repositorio

```
/riwiwallet-n8n-service
│
├── workflows/
│   ├── email-parsing/          # Flujos para leer y parsear correos bancarios
│   ├── user-sync/              # Sincronización de datos de usuario
│   ├── notifications/          # Alertas y mensajes proactivos
│   ├── finance-analytics/      # Cálculos, reportes y proyecciones IA
│   └── README.md               # Documentación de workflows
│
├── docker/
│   ├── Dockerfile              # Imagen personalizada de n8n
│   ├── docker-compose.yaml     # Ejecutar n8n localmente
│   ├── nginx.conf              # Proxy reverso con SSL
│   └── README.md               # Instrucciones de Docker
│
├── env/
│   ├── .env.example            # Variables de entorno (ejemplo)
│   └── production.env          # Variables de producción (NO subir)
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

## 🚀 Requisitos

| Herramienta | Versión Mínima |
|-------------|----------------|
| Docker      | 20.10+         |
| Docker Compose | 2.0+        |
| Node.js     | 18+            |
| n8n         | 1.0+           |

---

## ⚡ Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone https://github.com/Team-Avaricia/riwiwallet-n8n-service.git
cd riwiwallet-n8n-service
```

### 2. Configurar variables de entorno

```bash
cp env/.env.example env/.env
# Editar env/.env con tus credenciales
```

### 3. Levantar n8n con Docker

```bash
cd docker
docker-compose up -d
```

### 4. Acceder a n8n

Abre tu navegador en: `http://localhost:5678`

---

## 📥 Importar/Exportar Workflows

### Exportar workflows actuales

```bash
./scripts/export-workflows.sh
```

### Importar workflows al entorno

```bash
./scripts/import-workflows.sh
```

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

## 👥 Acceso al Repositorio

### 👑 Administradores
- Líder del proyecto
- Líder Backend
- DevOps

### 👨‍💻 Colaboradores
- Arquitecto de software
- QA (revisión de flujos)

### ❌ Sin acceso
- Frontend developers
- Estudiantes/internos nuevos

---

## 🔗 Endpoints del Backend → n8n

| Endpoint Backend | Webhook n8n | Descripción |
|-----------------|-------------|-------------|
| `POST /api/transactions/sync` | `/webhook/sync-transactions` | Sincronizar transacciones |
| `POST /api/alerts/evaluate` | `/webhook/evaluate-alerts` | Evaluar reglas de alertas |
| `POST /api/emails/parse` | `/webhook/parse-email` | Parsear correo bancario |
| `POST /api/analytics/project` | `/webhook/financial-projection` | Generar proyección |

---

## 📚 Documentación Adicional

- [Arquitectura del Sistema](docs/architecture.md)
- [Políticas de Seguridad](docs/security-policies.md)
- [Contratos de Webhook](docs/webhook-contracts.md)

---

## 🤝 Contribuir

1. Crear una rama desde `develop`
2. Implementar el workflow en n8n
3. Exportar y agregar a `/workflows`
4. Documentar en el README correspondiente
5. Crear Pull Request

---

## 📄 Licencia

Este proyecto es privado y pertenece a **Team Avaricia** - RiwiWallet.

---


