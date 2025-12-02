# 📁 Workflows

Este directorio contiene todos los workflows de n8n exportados y organizados por categoría.

## Estructura

```
workflows/
├── email-parsing/          # Flujos de parsing de correos bancarios
├── user-sync/              # Sincronización de datos de usuario
├── notifications/          # Alertas y notificaciones
├── finance-analytics/      # Análisis y proyecciones financieras
└── README.md               # Este archivo
```

## Convención de Nombres

Los archivos de workflow siguen esta convención:

```
<categoria>-<accion>-<detalle>.json
```

**Ejemplos:**
- `email-parsing-bancolombia.json`
- `alert-budget-threshold.json`
- `sync-user-preferences.json`

## Cómo Importar Workflows

### Opción 1: Via Script

```bash
cd scripts
./import-workflows.sh
```

### Opción 2: Via UI de n8n

1. Abrir n8n en `http://localhost:5678`
2. Ir a **Workflows** → **Import from File**
3. Seleccionar el archivo `.json`
4. Configurar credenciales si es necesario

### Opción 3: Via API

```bash
curl -X POST "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: tu_api_key" \
  -H "Content-Type: application/json" \
  -d @workflow.json
```

## Cómo Exportar Workflows

### Via Script (Recomendado)

```bash
cd scripts
./export-workflows.sh
```

### Via UI de n8n

1. Abrir el workflow en n8n
2. Click en **⋮** (menú) → **Download**
3. Guardar en la carpeta correspondiente
4. Hacer commit al repositorio

## Categorías

### 📧 email-parsing/
Workflows para leer y procesar correos de bancos colombianos:
- Bancolombia
- Nequi
- Davivienda
- Otros bancos

### 🔄 user-sync/
Workflows para sincronizar datos:
- Preferencias de usuario
- Configuración de presupuestos
- Reglas de alerta

### 🔔 notifications/
Workflows de alertas y notificaciones:
- Alertas de presupuesto
- Gastos inusuales
- Resumen diario/semanal

### 📊 finance-analytics/
Workflows de análisis financiero:
- Proyecciones
- Clasificación con IA
- Reportes

## Buenas Prácticas

### ✅ DO's

- Exportar después de cada cambio significativo
- Incluir descripción clara en el workflow
- Usar nombres descriptivos para nodos
- Documentar variables de entorno necesarias
- Testear antes de hacer commit

### ❌ DON'Ts

- Nunca incluir credenciales en el JSON
- No commitear workflows sin probar
- Evitar IDs hardcodeados
- No modificar workflows de producción directamente

## Versionamiento

Cada workflow tiene un campo `versionId` automático. Para cambios significativos:

1. Actualizar descripción del workflow
2. Exportar nuevo JSON
3. Crear commit descriptivo:

```bash
git add workflows/
git commit -m "feat(workflows): add budget alert threshold logic"
```

## Troubleshooting

### El workflow no importa

1. Verificar que el JSON es válido: `jq . workflow.json`
2. Verificar versión de n8n compatible
3. Revisar credenciales requeridas

### Credenciales faltantes

Después de importar, configurar credenciales en n8n:
1. Editar workflow
2. Click en nodo con error
3. Seleccionar/crear credencial

### Nodos deprecated

Si n8n muestra warning de nodos obsoletos:
1. Identificar nodo afectado
2. Buscar reemplazo en documentación de n8n
3. Actualizar workflow
4. Re-exportar

