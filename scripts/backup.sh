#!/bin/bash
# ============================================
# Script de backup automático para n8n
# RiwiWallet - Team Avaricia
# ============================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuración
BACKUP_ROOT="${BACKUP_ROOT:-/home/c-sharp/riwiwallet-n8n-service/backups}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"

# Docker compose path
DOCKER_COMPOSE_PATH="${DOCKER_COMPOSE_PATH:-/home/c-sharp/riwiwallet-n8n-service/docker}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  n8n Backup Script${NC}"
echo -e "${GREEN}  RiwiWallet - Team Avaricia${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Timestamp: ${TIMESTAMP}"
echo ""

# Crear directorio de backup
mkdir -p "${BACKUP_DIR}"

# ============================================
# 1. Backup de la base de datos PostgreSQL
# ============================================
echo -e "${YELLOW}[1/4] Respaldando base de datos PostgreSQL...${NC}"

docker exec riwiwallet-n8n-db pg_dump -U n8n n8n > "${BACKUP_DIR}/postgres_backup.sql"

if [ -f "${BACKUP_DIR}/postgres_backup.sql" ]; then
    echo -e "${GREEN}✓ postgres_backup.sql ($(du -h "${BACKUP_DIR}/postgres_backup.sql" | cut -f1))${NC}"
else
    echo -e "${RED}✗ Error en backup de PostgreSQL${NC}"
    exit 1
fi

# ============================================
# 2. Backup de volúmenes de Docker
# ============================================
echo -e "${YELLOW}[2/4] Respaldando volúmenes de Docker...${NC}"

# Backup del volumen de n8n
docker run --rm \
    -v riwiwallet-n8n-service_n8n_data:/data \
    -v "${BACKUP_DIR}:/backup" \
    alpine tar czf /backup/n8n_data.tar.gz -C /data .

if [ -f "${BACKUP_DIR}/n8n_data.tar.gz" ]; then
    echo -e "${GREEN}✓ n8n_data.tar.gz ($(du -h "${BACKUP_DIR}/n8n_data.tar.gz" | cut -f1))${NC}"
fi

# ============================================
# 3. Exportar workflows via API
# ============================================
echo -e "${YELLOW}[3/4] Exportando workflows via API...${NC}"

# Ejecutar script de export
if [ -f "./export-workflows.sh" ]; then
    chmod +x ./export-workflows.sh
    ./export-workflows.sh
    
    # Copiar workflows exportados al backup
    cp -r ../workflows "${BACKUP_DIR}/"
    echo -e "${GREEN}✓ Workflows exportados${NC}"
else
    echo -e "${YELLOW}⚠ Script de export no encontrado, omitiendo...${NC}"
fi

# ============================================
# 4. Backup de configuración
# ============================================
echo -e "${YELLOW}[4/4] Respaldando configuración...${NC}"

# Copiar archivos de configuración (sin .env real)
mkdir -p "${BACKUP_DIR}/config"
cp "${DOCKER_COMPOSE_PATH}/docker-compose.yaml" "${BACKUP_DIR}/config/" 2>/dev/null || true
cp "${DOCKER_COMPOSE_PATH}/Dockerfile" "${BACKUP_DIR}/config/" 2>/dev/null || true
cp "${DOCKER_COMPOSE_PATH}/nginx.conf" "${BACKUP_DIR}/config/" 2>/dev/null || true

echo -e "${GREEN}✓ Configuración respaldada${NC}"

# ============================================
# Comprimir backup completo
# ============================================
echo ""
echo -e "${YELLOW}Comprimiendo backup completo...${NC}"

cd "${BACKUP_ROOT}"
tar czf "${TIMESTAMP}.tar.gz" "${TIMESTAMP}"
rm -rf "${TIMESTAMP}"

BACKUP_SIZE=$(du -h "${TIMESTAMP}.tar.gz" | cut -f1)
echo -e "${GREEN}✓ Backup comprimido: ${TIMESTAMP}.tar.gz (${BACKUP_SIZE})${NC}"

# ============================================
# Limpiar backups antiguos
# ============================================
echo ""
echo -e "${YELLOW}Limpiando backups antiguos (>${RETENTION_DAYS} días)...${NC}"

find "${BACKUP_ROOT}" -name "*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete

REMAINING=$(find "${BACKUP_ROOT}" -name "*.tar.gz" -type f | wc -l)
echo -e "${GREEN}✓ Backups restantes: ${REMAINING}${NC}"

# ============================================
# Resumen
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Backup completado exitosamente${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Archivo: ${BACKUP_ROOT}/${TIMESTAMP}.tar.gz"
echo "Tamaño:  ${BACKUP_SIZE}"
echo ""
echo -e "${YELLOW}Contenido del backup:${NC}"
echo "  - postgres_backup.sql (base de datos)"
echo "  - n8n_data.tar.gz (datos de n8n)"
echo "  - workflows/ (archivos JSON)"
echo "  - config/ (configuración Docker)"
echo ""
echo -e "${YELLOW}Para restaurar:${NC}"
echo "  tar xzf ${TIMESTAMP}.tar.gz"
echo "  cat postgres_backup.sql | docker exec -i riwiwallet-n8n-db psql -U n8n n8n"

