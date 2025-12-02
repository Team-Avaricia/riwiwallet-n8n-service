# Dockerfile personalizado para n8n - RiwiWallet
# Basado en la imagen oficial de n8n con extensiones adicionales

FROM n8nio/n8n:latest

# Metadatos
LABEL maintainer="Team Avaricia <team@avaricia.dev>"
LABEL description="n8n customizado para RiwiWallet con nodos adicionales"
LABEL version="1.0.0"

# Cambiar a root para instalar dependencias
USER root

# Instalar dependencias adicionales del sistema
RUN apk add --no-cache \
    curl \
    jq \
    openssl \
    ca-certificates

# Instalar nodos de comunidad adicionales (descomentar según necesidad)
# RUN cd /usr/local/lib/node_modules/n8n && \
#     npm install n8n-nodes-google-sheets-trigger \
#     npm install n8n-nodes-text-manipulation

# Crear directorio para workflows importados
RUN mkdir -p /home/node/workflows && \
    chown -R node:node /home/node/workflows

# Volver al usuario node por seguridad
USER node

# Variables de entorno por defecto
ENV NODE_ENV=production
ENV N8N_PORT=5678
ENV GENERIC_TIMEZONE=America/Bogota
ENV TZ=America/Bogota

# Puerto expuesto
EXPOSE 5678

# Comando de inicio
CMD ["n8n", "start"]

