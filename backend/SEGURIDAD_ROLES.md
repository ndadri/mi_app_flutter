# 🔒 DOCUMENTACIÓN DE SEGURIDAD - SISTEMA DE ROLES
## Pet Match Flutter App - Sistema de Roles Avanzado

### ⚠️ CONFIGURACIÓN DE SEGURIDAD CRÍTICA

#### 1. REGISTRO DE USUARIOS NORMALES
- **TODOS** los usuarios registrados a través del formulario público (`/register`) se asignan automáticamente como **USUARIO NORMAL** (id_rol = 1)
- **JAMÁS** se permite especificar rol en el registro público
- El backend bloquea automáticamente cualquier intento de enviar campos de rol (`rol`, `id_rol`, `role`)

#### 2. CREACIÓN DE ADMINISTRADORES
- Los administradores **SOLO** se pueden crear a través del script `create_admin.js`
- **NO** existe manera de crear administradores desde la interfaz de usuario
- El script requiere acceso directo al servidor y base de datos

#### 3. CAMBIO DE ROLES
- **SOLO** los administradores existentes pueden cambiar roles de usuarios
- Se requiere autenticación y verificación de permisos en cada operación
- Se registran logs de seguridad para cambios de roles

---

### 🎯 ROLES DISPONIBLES

#### 👤 USUARIO (ID: 1) - ROL POR DEFECTO
```json
{
  "usuarios": {"crear": false, "leer": false, "actualizar": false, "eliminar": false},
  "mascotas": {"crear": true, "leer": true, "actualizar": true, "eliminar": true},
  "reportes": {"generar": false, "exportar": false},
  "panel_admin": false
}
```

#### 🛡️ MODERADOR (ID: 3)
```json
{
  "usuarios": {"crear": false, "leer": true, "actualizar": false, "eliminar": false},
  "mascotas": {"crear": true, "leer": true, "actualizar": true, "eliminar": true},
  "reportes": {"generar": true, "exportar": false},
  "panel_admin": false
}
```

#### 👑 ADMINISTRADOR (ID: 2) - ACCESO COMPLETO
```json
{
  "usuarios": {"crear": true, "leer": true, "actualizar": true, "eliminar": true},
  "mascotas": {"crear": true, "leer": true, "actualizar": true, "eliminar": true},
  "reportes": {"generar": true, "exportar": true},
  "panel_admin": true
}
```

---

### 🔐 MEDIDAS DE SEGURIDAD IMPLEMENTADAS

#### Backend (authRoutes.js):
1. **Validación de rol en registro:** Bloquea campos de rol en `/register`
2. **Middleware de permisos:** `verificarPermiso()` y `verificarAdmin()`
3. **Log de seguridad:** Registra intentos de escalación de privilegios
4. **Hardcoded role = 1:** Valor fijo en INSERT de usuarios nuevos

#### Frontend (Flutter):
1. **Verificación de permisos:** `AuthProvider.tienePermiso()`
2. **UI condicionada:** Opciones de admin solo visibles para administradores
3. **Bloqueo de acceso:** Páginas admin protegidas por rol

#### Base de Datos:
1. **Claves foráneas:** Relación usuarios ↔ roles con FK
2. **Función SQL:** `verificar_permiso()` para validación eficiente
3. **Vista securizada:** `vista_usuarios_roles` para consultas seguras

---

### 🚨 PROCEDIMIENTOS DE EMERGENCIA

#### Crear primer administrador:
```bash
cd backend
node create_admin.js
```

#### Cambiar credenciales por defecto:
- Email: `admin@petmatch.com` → Cambiar en create_admin.js
- Contraseña: `admin123456` → Cambiar en create_admin.js

#### Resetear sistema de roles:
```bash
cd backend
psql -f create_advanced_roles_system.sql
```

---

### ✅ VERIFICACIONES DE SEGURIDAD

1. **✅ Registro público:** Solo crea usuarios normales (id_rol = 1)
2. **✅ Frontend seguro:** No envía campos de rol
3. **✅ Backend protegido:** Valida y bloquea escalación de privilegios
4. **✅ Admin creation:** Solo por script directo con DB access
5. **✅ Panel admin:** Protegido por verificación de rol
6. **✅ Logs de seguridad:** Registra intentos maliciosos

---

### 📋 CHECKLIST DE SEGURIDAD DIARIA

- [ ] Verificar logs de intentos de escalación de privilegios
- [ ] Revisar lista de administradores activos
- [ ] Confirmar que el registro público sigue creando solo usuarios normales
- [ ] Verificar acceso al panel de administración

---

**IMPORTANTE:** Este sistema de roles está diseñado para ser seguro por defecto. Cualquier modificación debe ser revisada cuidadosamente para mantener la seguridad.
