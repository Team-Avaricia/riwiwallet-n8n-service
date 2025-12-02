#!/bin/bash
# ============================================
# Script para exportar workflows de n8n
# RiwiWallet - Team Avaricia
# ============================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuración
N8N_HOST="${N8N_HOST:-http://localhost:5678}"
N8N_API_KEY="${N8N_API_KEY:-}"
EXPORT_DIR="../workflows"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="../backups/${TIMESTAMP}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  n8n Workflow Export Script${NC}"
echo -e "${GREEN}  RiwiWallet - Team Avaricia${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verificar que n8n está corriendo
echo -e "${YELLOW}Verificando conexión con n8n...${NC}"
if ! curl -s "${N8N_HOST}/healthz" > /dev/null 2>&1; then
    echo -e "${RED}Error: No se puede conectar a n8n en ${N8N_HOST}${NC}"
    echo "Asegúrate de que n8n esté corriendo."
    exit 1
fi
echo -e "${GREEN}✓ Conexión exitosa${NC}"
echo ""

# Crear directorio de backup
mkdir -p "${BACKUP_DIR}"
echo -e "${YELLOW}Directorio de backup: ${BACKUP_DIR}${NC}"

# Función para exportar workflows
export_workflows() {
    echo -e "${YELLOW}Exportando workflows...${NC}"
    
    # Obtener lista de workflows
    WORKFLOWS=$(curl -s -X GET "${N8N_HOST}/api/v1/workflows" \
        -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
        -H "Content-Type: application/json")
    
    if [ -z "$WORKFLOWS" ]; then
        echo -e "${RED}No se encontraron workflows o error de autenticación${NC}"
        exit 1
    fi
    
    # Parsear y exportar cada workflow
    echo "$WORKFLOWS" | jq -c '.data[]' | while read -r workflow; do
        WORKFLOW_ID=$(echo "$workflow" | jq -r '.id')
        WORKFLOW_NAME=$(echo "$workflow" | jq -r '.name' | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
        
        echo -e "  Exportando: ${WORKFLOW_NAME} (ID: ${WORKFLOW_ID})"
        
        # Obtener workflow completo
        curl -s -X GET "${N8N_HOST}/api/v1/workflows/${WORKFLOW_ID}" \
            -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
            -H "Content-Type: application/json" \
            | jq '.' > "${BACKUP_DIR}/${WORKFLOW_NAME}.json"
        
        echo -e "${GREEN}  ✓ ${WORKFLOW_NAME}.json${NC}"
    done
}

# Función para exportar credenciales (sin secretos)
export_credentials_schema() {
    echo -e "${YELLOW}Exportando esquema de credenciales...${NC}"
    
    curl -s -X GET "${N8N_HOST}/api/v1/credentials" \
        -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
        -H "Content-Type: application/json" \
        | jq '[.data[] | {id, name, type, nodesAccess}]' > "${BACKUP_DIR}/credentials_schema.json"
    
    echo -e "${GREEN}✓ credentials_schema.json (sin secretos)${NC}"
}

# Ejecutar exportación
export_workflows
export_credentials_schema

# Copiar a directorio de workflows por categoría
echo ""
echo -e "${YELLOW}Organizando workflows por categoría...${NC}"

for json_file in "${BACKUP_DIR}"/*.json; do
    if [ -f "$json_file" ]; then
        filename=$(basename "$json_file")
        
        # Determinar categoría basándose en el nombre
        if [[ "$filename" == *"email"* ]] || [[ "$filename" == *"parsing"* ]]; then
            cp "$json_file" "${EXPORT_DIR}/email-parsing/"
        elif [[ "$filename" == *"sync"* ]] || [[ "$filename" == *"user"* ]]; then
            cp "$json_file" "${EXPORT_DIR}/user-sync/"
        elif [[ "$filename" == *"alert"* ]] || [[ "$filename" == *"notification"* ]]; then
            cp "$json_file" "${EXPORT_DIR}/notifications/"
        elif [[ "$filename" == *"analytics"* ]] || [[ "$filename" == *"projection"* ]] || [[ "$filename" == *"finance"* ]]; then
            cp "$json_file" "${EXPORT_DIR}/finance-analytics/"
        fi
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Exportación completada${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Backup guardado en: ${BACKUP_DIR}"
echo -e "Workflows organizados en: ${EXPORT_DIR}"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "1. Revisar los archivos exportados"
echo "2. git add workflows/"
echo "3. git commit -m 'chore: update workflows export'"
echo "4. git push"

