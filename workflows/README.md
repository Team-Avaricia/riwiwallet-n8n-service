# 📁 Workflows

Este directorio contiene los workflows de n8n exportados y organizados por categoría.

## Estructura

```
workflows/
├── email-parsing/          # Flujos de parsing de correos bancarios
│   ├── bancolombia-nequi-parser.json
│   └── README.md
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

## Cómo Importar Workflows

### Opción 1: Via Script

```bash
cd scripts
./import-workflows.sh
```

### Opción 2: Via UI de n8n

1. Abrir n8n en `https://n8n.avaricia.crudzaso.com`
2. Ir a **Workflows** → **Import from File**
3. Seleccionar el archivo `.json`
4. Configurar credenciales si es necesario

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
