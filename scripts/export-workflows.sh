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
N8N_HOST="${N8N_HOST:-https://n8n.avaricia.crudzaso.com}"
N8N_API_KEY="${N8N_API_KEY:-}"
EXPORT_DIR="../workflows"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="../backups/${TIMESTAMP}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  n8n Workflow Export Script${NC}"
echo -e "${GREEN}  RiwiWallet - Team Avaricia${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verificar API Key
if [ -z "$N8N_API_KEY" ]; then
    echo -e "${RED}Error: N8N_API_KEY no está configurado${NC}"
    echo "Configura la variable de entorno: export N8N_API_KEY=tu_api_key"
    exit 1
fi

# Verificar conexión
echo -e "${YELLOW}Verificando conexión con n8n...${NC}"
if ! curl -s "${N8N_HOST}/healthz" > /dev/null 2>&1; then
    echo -e "${RED}Error: No se puede conectar a n8n en ${N8N_HOST}${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Conexión exitosa${NC}"
echo ""

# Crear directorio temporal
mkdir -p "${BACKUP_DIR}"

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

# Ejecutar exportación
export_workflows

# Copiar a directorio de workflows
echo ""
echo -e "${YELLOW}Organizando workflows...${NC}"

for json_file in "${BACKUP_DIR}"/*.json; do
    if [ -f "$json_file" ]; then
        filename=$(basename "$json_file")
        
        # Por defecto, mover a email-parsing si coincide, o dejar en raíz de workflows
        if [[ "$filename" == *"email"* ]] || [[ "$filename" == *"parsing"* ]] || [[ "$filename" == *"bancolombia"* ]] || [[ "$filename" == *"nequi"* ]]; then
            cp "$json_file" "${EXPORT_DIR}/email-parsing/"
        else
            cp "$json_file" "${EXPORT_DIR}/"
        fi
    fi
done

# Limpiar backup temporal
rm -rf "../backups"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Exportación completada${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Workflows actualizados en: ${EXPORT_DIR}"

