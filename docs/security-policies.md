# 🔐 Políticas de Seguridad

## Visión General

Este documento define las políticas de seguridad para el servicio n8n de RiwiWallet. Dado que manejamos **datos financieros sensibles**, la seguridad es nuestra máxima prioridad.

---

## 1. Autenticación y Autorización

### 1.1 Acceso a n8n UI

| Configuración | Valor |
|--------------|-------|
| Autenticación básica | **Obligatoria** |
| Complejidad de contraseña | Mínimo 16 caracteres, mixta |
| Rotación de credenciales | Cada 90 días |
| 2FA | Recomendado vía proxy |

### 1.2 Acceso a Webhooks

```
✅ OBLIGATORIO para todos los webhooks:
- Token secreto en header (X-Webhook-Token)
- Firma HMAC-SHA256 del payload
- Validación de IP origen (solo backend)
- Rate limiting (100 req/min por endpoint)
```

### Ejemplo de Validación de Webhook

```javascript
// En el workflow de n8n
const receivedToken = $input.headers['x-webhook-token'];
const receivedSignature = $input.headers['x-signature'];
const payload = JSON.stringify($input.body);

// Validar token
if (receivedToken !== process.env.WEBHOOK_SECRET_TOKEN) {
  throw new Error('Invalid token');
}

// Validar firma HMAC
const crypto = require('crypto');
const expectedSignature = crypto
  .createHmac('sha256', process.env.WEBHOOK_SECRET_TOKEN)
  .update(payload)
  .digest('hex');

if (receivedSignature !== expectedSignature) {
  throw new Error('Invalid signature');
}
```

---

## 2. Gestión de Credenciales

### 2.1 Credenciales en n8n

| Política | Detalle |
|----------|---------|
| Almacenamiento | Cifradas con `N8N_ENCRYPTION_KEY` |
| Acceso | Solo workflows autorizados |
| Compartir | **NUNCA** entre equipos |
| Exportación | Excluidas de exports |

### 2.2 Credenciales Externas

```
❌ PROHIBIDO:
- Hardcodear tokens en workflows
- Guardar API keys en nodos de código
- Compartir credenciales por Slack/email
- Usar credenciales de producción en desarrollo

✅ PERMITIDO:
- Usar sistema de credenciales de n8n
- Variables de entorno para secretos
- Vault para producción (HashiCorp, AWS Secrets)
```

### 2.3 Tokens de Usuario

Los tokens OAuth de usuarios (Gmail, etc.) **NUNCA** se almacenan en n8n:

```
1. Usuario autoriza en frontend
2. Backend recibe y cifra tokens (AES-256)
3. Backend almacena en DB cifrada
4. n8n solicita token al backend cuando necesita
5. Backend descifra y envía token temporal
6. Token se usa y se descarta inmediatamente
```

---

## 3. Red y Comunicación

### 3.1 Arquitectura de Red

```
┌─────────────────────────────────────────────────────────┐
│                    RED PRIVADA                          │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐            │
│  │   n8n   │    │ Postgres │    │  Redis  │            │
│  └────┬────┘    └─────────┘    └─────────┘            │
│       │                                                 │
│       │ (solo conexiones internas)                     │
└───────┼─────────────────────────────────────────────────┘
        │
        │ HTTPS + Auth
        ▼
┌─────────────┐
│   Backend   │  (única entrada permitida)
└─────────────┘
```

### 3.2 Reglas de Firewall

```bash
# Solo permitir conexiones desde backend
iptables -A INPUT -p tcp --dport 5678 -s BACKEND_IP -j ACCEPT
iptables -A INPUT -p tcp --dport 5678 -j DROP
```

### 3.3 TLS/SSL

| Ambiente | Requisito |
|----------|-----------|
| Desarrollo | HTTP permitido (localhost) |
| Staging | HTTPS obligatorio |
| Producción | HTTPS + HSTS + TLS 1.3 |

---

## 4. Datos Sensibles

### 4.1 Clasificación de Datos

| Categoría | Ejemplos | Tratamiento |
|-----------|----------|-------------|
| **Crítico** | Tokens OAuth, API keys | Nunca en logs, cifrado en tránsito y reposo |
| **Sensible** | Emails, transacciones | Minimizar retención, cifrar en DB |
| **Interno** | IDs de usuario, timestamps | Logs permitidos, no exponer |
| **Público** | Categorías, configuración | Sin restricciones |

### 4.2 Manejo en Workflows

```
✅ BUENAS PRÁCTICAS:
- Usar Function nodes para sanitizar datos antes de log
- Eliminar datos sensibles después de procesarlos
- No incluir PII en nombres de ejecución
- Configurar retención mínima de ejecuciones

❌ EVITAR:
- Loggear payloads completos de email
- Guardar números de tarjeta/cuenta
- Almacenar contraseñas en cualquier formato
```

### 4.3 Logs y Auditoría

```javascript
// Ejemplo de sanitización antes de log
const sanitizedTransaction = {
  id: transaction.id,
  amount: transaction.amount,
  category: transaction.category,
  // NO incluir:
  // - accountNumber
  // - cardLastFour
  // - userEmail
};

console.log('Transaction processed:', sanitizedTransaction);
```

---

## 5. Respuesta a Incidentes

### 5.1 Clasificación de Incidentes

| Severidad | Descripción | Tiempo de Respuesta |
|-----------|-------------|---------------------|
| **Crítica** | Brecha de datos, acceso no autorizado | < 1 hora |
| **Alta** | Workflow comprometido, credencial expuesta | < 4 horas |
| **Media** | Error de configuración, logs expuestos | < 24 horas |
| **Baja** | Vulnerabilidad potencial, mejora sugerida | < 1 semana |

### 5.2 Procedimiento de Incidente

1. **Detectar**: Alertas automáticas o reporte manual
2. **Contener**: Deshabilitar webhook/workflow afectado
3. **Investigar**: Revisar logs, identificar alcance
4. **Remediar**: Rotar credenciales, parchear vulnerabilidad
5. **Recuperar**: Restaurar servicio normal
6. **Documentar**: Post-mortem y lecciones aprendidas

### 5.3 Contactos de Emergencia

| Rol | Responsabilidad |
|-----|-----------------|
| Líder de Proyecto | Decisiones de negocio |
| DevOps | Infraestructura y acceso |
| Backend Lead | API y datos |
| Seguridad | Análisis y remediación |

---

## 6. Cumplimiento y Auditoría

### 6.1 Revisiones de Seguridad

| Frecuencia | Actividad |
|------------|-----------|
| Semanal | Revisar logs de acceso |
| Mensual | Auditar credenciales activas |
| Trimestral | Penetration testing |
| Anual | Auditoría completa de seguridad |

### 6.2 Checklist de Deployment

Antes de cada deploy a producción:

- [ ] Credenciales de desarrollo removidas
- [ ] Webhooks con autenticación
- [ ] Logs sanitizados
- [ ] Rate limiting configurado
- [ ] Backup verificado
- [ ] Rollback plan documentado

---

## 7. Mejores Prácticas para Desarrolladores

### DO's ✅

```
✅ Usar el sistema de credenciales de n8n
✅ Validar todos los inputs de webhooks
✅ Implementar timeouts en llamadas externas
✅ Usar HTTPS para todas las conexiones
✅ Documentar cambios de seguridad
✅ Reportar vulnerabilidades inmediatamente
```

### DON'Ts ❌

```
❌ Hardcodear secretos en workflows
❌ Exponer endpoints sin autenticación
❌ Loggear datos sensibles
❌ Usar credenciales compartidas
❌ Ignorar alertas de seguridad
❌ Desplegar sin revisión de código
```

---

## 8. Actualizaciones de Seguridad

### Política de Parches

| Tipo | Acción | Plazo |
|------|--------|-------|
| Crítico (CVE alto) | Patch inmediato | < 24 horas |
| Importante | Planificar actualización | < 1 semana |
| Moderado | Incluir en próximo release | < 1 mes |
| Bajo | Evaluar necesidad | Siguiente ciclo |

### Proceso de Actualización

1. Revisar changelog de n8n
2. Probar en ambiente de desarrollo
3. Validar workflows críticos
4. Deploy a staging
5. QA completo
6. Deploy a producción
7. Monitorear 24 horas

---

*Última actualización: Diciembre 2024*
*Próxima revisión: Marzo 2025*

