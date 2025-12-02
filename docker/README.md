# 🐳 Docker Configuration

Este directorio contiene la configuración de Docker para ejecutar n8n.

## Archivos

| Archivo | Descripción |
|---------|-------------|
| `docker-compose.yaml` | Orquestación de servicios (n8n, PostgreSQL, Redis) |
| `Dockerfile` | Imagen personalizada de n8n con extensiones |
| `nginx.conf` | Configuración de proxy reverso con SSL |

## 🚀 Inicio Rápido

### Desarrollo Local

```bash
# Copiar variables de entorno
cp ../env/.env.example ../env/.env

# Editar variables
nano ../env/.env

# Levantar servicios
docker-compose --env-file ../env/.env up -d
```

### Ver logs

```bash
docker-compose logs -f n8n
```

### Detener servicios

```bash
docker-compose down
```

### Reiniciar n8n

```bash
docker-compose restart n8n
```

## 🔧 Configuración de Producción

### 1. Usar Nginx como proxy

```bash
# Copiar configuración de nginx
sudo cp nginx.conf /etc/nginx/sites-available/n8n.conf
sudo ln -s /etc/nginx/sites-available/n8n.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 2. Configurar SSL con Let's Encrypt

```bash
sudo certbot --nginx -d n8n.riwiwallet.com
```

### 3. Usar imagen personalizada

```bash
# Construir imagen
docker build -t riwiwallet/n8n:latest .

# Actualizar docker-compose.yaml para usar la imagen
# image: riwiwallet/n8n:latest
```

## 📊 Servicios

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| n8n | 5678 | Interfaz web y API |
| PostgreSQL | 5432 | Base de datos |
| Redis | 6379 | Cola de trabajos |

## 🔐 Seguridad

- Nunca exponer el puerto de PostgreSQL o Redis al exterior
- Usar siempre HTTPS en producción
- Configurar `N8N_BASIC_AUTH` con credenciales fuertes
- Generar `N8N_ENCRYPTION_KEY` único para cada ambiente

```bash
# Generar encryption key
openssl rand -hex 32
```

## 🐛 Troubleshooting

### n8n no inicia

```bash
# Ver logs detallados
docker-compose logs n8n

# Verificar conexión a DB
docker-compose exec postgres pg_isready
```

### Problemas de permisos

```bash
# Arreglar permisos de volumen
sudo chown -R 1000:1000 ./data
```

### Redis connection refused

```bash
# Verificar que Redis esté corriendo
docker-compose ps redis
docker-compose logs redis
```

