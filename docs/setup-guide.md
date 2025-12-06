# 🚀 Guía de Instalación - RiwiWallet n8n Service

## 📋 Requisitos Previos

- Servidor con Ubuntu/Debian
- Docker y Docker Compose instalados
- Mínimo 4GB de RAM
- Puerto 5678 disponible

## 🔧 Instalación Paso a Paso

### 1. Clonar el repositorio

```bash
git clone https://github.com/Team-Avaricia/riwiwallet-n8n-service.git
cd riwiwallet-n8n-service
```

### 2. Configurar variables de entorno

Crear el archivo `.env` en la carpeta del proyecto con las siguientes variables:

```env
# BASE DE DATOS PRINCIPAL
DB_NAME=riwiwallet_db
DB_USER=riwi_user
DB_PASSWORD=<tu_password_seguro>

# WIKI.JS
WIKI_DB_USER=wiki_user
WIKI_DB_PASSWORD=<tu_password_wiki>
WIKI_DB_NAME=wiki_db

# n8n
N8N_USER=admin
N8N_PASSWORD=<tu_password_n8n>
N8N_HOST=<tu_ip_o_dominio>
N8N_PROTOCOL=http
N8N_WEBHOOK_URL=http://<tu_ip_o_dominio>:5678
N8N_DB_NAME=n8n
N8N_ENCRYPTION_KEY=<generar_key_64_caracteres>
N8N_SECURE_COOKIE=false
```

### 3. Crear la base de datos para n8n

Después de levantar los contenedores por primera vez:

```bash
docker exec -it riwi_db psql -U riwi_user -d riwiwallet_db -c "CREATE DATABASE n8n;"
```

### 4. Levantar los servicios

```bash
cd docker
docker compose -f docker-compose.servidor.yaml up -d
```

### 5. Verificar que todo esté corriendo

```bash
docker ps
```

Deberías ver 4 contenedores:
- `riwi_db` - PostgreSQL
- `riwi_wiki` - Wiki.js
- `riwi_n8n` - n8n
- `riwi_redis` - Redis

### 6. Acceder a n8n

Abre tu navegador en:
```
http://<tu_ip>:5678
```

## 🔐 Configuración de Gmail OAuth2 (Opcional)

Para conectar Gmail a n8n necesitas:

1. Crear proyecto en [Google Cloud Console](https://console.cloud.google.com/)
2. Habilitar Gmail API
3. Configurar pantalla de consentimiento OAuth
4. Crear credenciales OAuth 2.0
5. **Importante**: Google requiere un dominio válido (no IP) para OAuth2

### URLs de redirección para n8n:

```
Origen JavaScript: http://<tu_dominio>:5678
URI de redirección: http://<tu_dominio>:5678/rest/oauth2-credential/callback
```

## 📊 Servicios y Puertos

| Servicio | Puerto | URL |
|----------|--------|-----|
| n8n | 5678 | http://IP:5678 |
| Wiki.js | 3000 | http://IP:3000 |
| PostgreSQL | 5432 | localhost:5432 |
| Redis | 6379 | interno |

## 🔄 Comandos Útiles

```bash
# Ver logs de n8n
docker logs riwi_n8n --tail 50

# Reiniciar n8n
docker restart riwi_n8n

# Detener todo
docker compose -f docker-compose.servidor.yaml down

# Reiniciar todo
docker compose -f docker-compose.servidor.yaml up -d
```

## 📁 Estructura del Proyecto

```
riwiwallet-n8n-service/
├── docker/
│   ├── docker-compose.servidor.yaml  # Compose para producción
│   ├── docker-compose.yaml           # Compose para desarrollo
│   ├── n8n.env                        # Variables de n8n
│   └── nginx.conf                     # Configuración nginx (HTTPS)
├── docs/
│   ├── architecture.md
│   ├── security-policies.md
│   ├── setup-guide.md                 # Esta guía
│   └── webhook-contracts.md
├── workflows/
│   ├── email-parsing/
│   ├── finance-analytics/
│   ├── notifications/
│   └── user-sync/
└── scripts/
    ├── backup.sh
    ├── export-workflows.sh
    └── import-workflows.sh
```

## ⚠️ Notas Importantes

1. **N8N_SECURE_COOKIE=false** es necesario para acceder vía HTTP (sin HTTPS)
2. Para producción con HTTPS, usar nginx como reverse proxy
3. La base de datos `n8n` debe crearse manualmente la primera vez
4. Google OAuth2 requiere un dominio, no funciona con IPs

## 🆘 Solución de Problemas

### Error: "database n8n does not exist"
```bash
docker exec -it riwi_db psql -U riwi_user -d riwiwallet_db -c "CREATE DATABASE n8n;"
docker restart riwi_n8n
```

### Error: "secure cookie" en el navegador
Verificar que `N8N_SECURE_COOKIE=false` esté en el docker-compose y reiniciar.

### n8n no carga
```bash
docker logs riwi_n8n --tail 30
```

---

**Última actualización:** 6 de Diciembre 2025
**Servidor de producción:** 157.90.251.124:5678

