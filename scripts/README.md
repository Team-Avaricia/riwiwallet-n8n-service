# 📜 Scripts de Utilidad

Este directorio contiene scripts Bash para facilitar la gestión de workflows en el entorno de producción.

## Requisitos

- `curl`
- `jq`
- Acceso a la terminal (Linux/Mac/WSL)
- API Key de n8n (Generada en n8n > Settings > API)

## Scripts Disponibles

### 1. `export-workflows.sh`

Descarga todos los workflows desde el servidor de producción y los guarda en la carpeta `workflows/` del repositorio, organizándolos automáticamente.

**Uso:**

```bash
export N8N_API_KEY="tu-api-key-aqui"
./export-workflows.sh
```

**Flujo:**
1. Conecta a `https://n8n.avaricia.crudzaso.com`
2. Descarga cada workflow en formato JSON.
3. Si el nombre contiene "email" o "parsing", lo mueve a `workflows/email-parsing/`.
4. Otros workflows se guardan en la raíz de `workflows/`.

---

### 2. `import-workflows.sh`

Carga los archivos JSON locales al servidor de n8n. Útil para restaurar backups o desplegar cambios.

**Uso:**

```bash
export N8N_API_KEY="tu-api-key-aqui"
./import-workflows.sh
```

**Flujo:**
1. Busca archivos `.json` en la carpeta `workflows/`.
2. Verifica si el workflow ya existe en el servidor.
3. Si existe, pregunta si deseas actualizarlo.
4. Si no existe, lo crea como nuevo.

---

## Notas Importantes

- **URL por defecto:** Los scripts apuntan a `https://n8n.avaricia.crudzaso.com`. Si necesitas usar otro servidor, define la variable `N8N_HOST`.
  ```bash
  export N8N_HOST="http://localhost:5678"
  ```
- **Seguridad:** Nunca hagas commit de tu `N8N_API_KEY`. Usa variables de entorno.
