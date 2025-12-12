#!/bin/bash
# ============================================
# Script para importar workflows a n8n
# RiwiWallet - Team Avaricia
# ============================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
N8N_HOST="${N8N_HOST:-https://n8n.avaricia.crudzaso.com}"
N8N_API_KEY="${N8N_API_KEY:-}"
IMPORT_DIR="${1:-../workflows}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  n8n Workflow Import Script${NC}"
echo -e "${GREEN}  RiwiWallet - Team Avaricia${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verificar argumentos
if [ -z "$N8N_API_KEY" ]; then
    echo -e "${RED}Error: N8N_API_KEY no está configurado${NC}"
    echo "Configura la variable de entorno: export N8N_API_KEY=tu_api_key"
    exit 1
fi

# Verificar que n8n está corriendo
echo -e "${YELLOW}Verificando conexión con n8n...${NC}"
if ! curl -s "${N8N_HOST}/healthz" > /dev/null 2>&1; then
    echo -e "${RED}Error: No se puede conectar a n8n en ${N8N_HOST}${NC}"
    echo "Asegúrate de que n8n esté corriendo."
    exit 1
fi
echo -e "${GREEN}✓ Conexión exitosa${NC}"
echo ""

# Contador de workflows
IMPORTED=0
SKIPPED=0
FAILED=0

# Función para importar un workflow
import_workflow() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    
    echo -e "${BLUE}Procesando: ${filename}${NC}"
    
    # Validar que es un JSON válido
    if ! jq empty "$file_path" 2>/dev/null; then
        echo -e "${RED}  ✗ JSON inválido${NC}"
        ((FAILED++))
        return
    fi
    
    # Obtener nombre del workflow
    local workflow_name=$(jq -r '.name // "Unknown"' "$file_path")
    
    # Verificar si el workflow ya existe
    local existing=$(curl -s -X GET "${N8N_HOST}/api/v1/workflows" \
        -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
        -H "Content-Type: application/json" \
        | jq -r ".data[] | select(.name == \"${workflow_name}\") | .id")
    
    if [ -n "$existing" ]; then
        echo -e "${YELLOW}  ⚠ Workflow '${workflow_name}' ya existe (ID: ${existing})${NC}"
        
        read -p "  ¿Deseas actualizar? (s/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            # Actualizar workflow existente
            local response=$(curl -s -X PUT "${N8N_HOST}/api/v1/workflows/${existing}" \
                -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
                -H "Content-Type: application/json" \
                -d @"$file_path")
            
            if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
                echo -e "${GREEN}  ✓ Actualizado: ${workflow_name}${NC}"
                ((IMPORTED++))
            else
                echo -e "${RED}  ✗ Error al actualizar${NC}"
                ((FAILED++))
            fi
        else
            echo -e "${YELLOW}  → Omitido${NC}"
            ((SKIPPED++))
        fi
    else
        # Crear nuevo workflow
        local response=$(curl -s -X POST "${N8N_HOST}/api/v1/workflows" \
            -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
            -H "Content-Type: application/json" \
            -d @"$file_path")
        
        if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
            local new_id=$(echo "$response" | jq -r '.id')
            echo -e "${GREEN}  ✓ Importado: ${workflow_name} (ID: ${new_id})${NC}"
            ((IMPORTED++))
        else
            echo -e "${RED}  ✗ Error al importar${NC}"
            echo "    Response: $(echo "$response" | jq -r '.message // "Unknown error"')"
            ((FAILED++))
        fi
    fi
}

# Buscar y procesar todos los archivos JSON
echo -e "${YELLOW}Buscando workflows en: ${IMPORT_DIR}${NC}"
echo ""

find "$IMPORT_DIR" -name "*.json" -type f | while read -r json_file; do
    # Ignorar archivos de schema
    if [[ "$json_file" == *"schema"* ]] || [[ "$json_file" == *"README"* ]]; then
        continue
    fi
    
    import_workflow "$json_file"
    echo ""
done

# Resumen
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Importación completada${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Importados:  ${GREEN}${IMPORTED}${NC}"
echo -e "Omitidos:    ${YELLOW}${SKIPPED}${NC}"
echo -e "Fallidos:    ${RED}${FAILED}${NC}"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "1. Verificar workflows en n8n UI: ${N8N_HOST}"
echo "2. Configurar credenciales necesarias"
echo "3. Activar workflows según necesidad"

