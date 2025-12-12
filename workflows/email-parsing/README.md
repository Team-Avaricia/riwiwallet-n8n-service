# 📧 Parser de Correos Bancarios (Bancolombia & Nequi)

Este workflow automatiza la lectura, extracción y registro de transacciones financieras a partir de los correos de notificación de **Bancolombia** y **Nequi**.

## 🔗 Enlace al Workflow
**URL del Editor:** [https://n8n.avaricia.crudzaso.com/workflow/B8rurjM15i0kASyK](https://n8n.avaricia.crudzaso.com/workflow/B8rurjM15i0kASyK)

## 🛠️ Funcionamiento del Flujo

El workflow consta de 5 nodos principales:

### 1. 📨 Gmail Trigger
- **Función:** Monitorea la bandeja de entrada en tiempo real.
- **Filtros:** Busca correos nuevos que provengan de:
  - `alertasynotificaciones@bancolombia.com.co`
  - `notificaciones@nequi.com.co` (o similares)

### 2. ⚖️ IF (Filtro de Banco)
- **Función:** Valida que el correo sea realmente de un banco soportado.
- **Lógica:** Verifica si el remitente (`From`) contiene "Bancolombia", "Nequi" o "Davivienda".

### 3. 💻 Code in JavaScript (Parser)
- **Función:** El cerebro del workflow. Analiza el cuerpo del correo y extrae los datos clave.
- **Datos Extraídos:**
  - **Monto:** Busca patrones de moneda (ej. `$20.000`).
  - **Comercio/Descripción:** Extrae el nombre del destinatario o comercio (ej. "Uber", "Netflix").
  - **Tipo:** Determina si es `Income` (Ingreso) o `Expense` (Gasto) basándose en palabras clave ("recibiste", "pagaste").
  - **Email Usuario:** Identifica el correo del usuario propietario de la cuenta.
- **Transformación:** Convierte los valores a los formatos requeridos por el Backend (Enums numéricos o Strings específicos).

### 4. 🌐 HTTP Request (Buscar Usuario)
- **Función:** Obtiene el ID del usuario en el sistema RiwiWallet.
- **Endpoint:** `GET /api/User/email/{email}`
- **Input:** Email extraído del correo.
- **Output:** `userId` (UUID).

### 5. 🌐 HTTP Request (Crear Transacción)
- **Función:** Registra la transacción en la base de datos.
- **Endpoint:** `POST /api/Transaction`
- **Body:**
  ```json
  {
    "userId": "uuid-del-usuario",
    "amount": 20000,
    "type": "Expense",       // "Income" o "Expense"
    "category": "Nequi",
    "description": "Uber Trip",
    "source": "Automatic"    // Identificador para transacciones automáticas
  }
  ```

## 📋 Requisitos Previos

Para que este workflow funcione, se requiere:
1.  **Credencial de Gmail (OAuth2):** Configurada en n8n para leer correos.
2.  **Usuario Registrado:** El email que recibe la notificación bancaria debe estar registrado en RiwiWallet.
3.  **Backend Activo:** La API debe estar respondiendo en `https://api.avaricia.crudzaso.com`.

## 🔄 Mantenimiento

Si el formato de los correos de los bancos cambia, es necesario actualizar la lógica de expresiones regulares (Regex) en el nodo **Code in JavaScript**.
