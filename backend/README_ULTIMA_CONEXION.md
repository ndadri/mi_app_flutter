# Actualización de Base de Datos - Campo ultima_conexion

Este script agrega el campo `ultima_conexion` a la tabla de usuarios para rastrear la última vez que cada usuario se conectó al sistema.

## Pasos para ejecutar la actualización:

### Opción 1: Usar Node.js (Recomendado)
```bash
cd backend
node add_ultima_conexion_column.js
```

### Opción 2: Usar SQL directamente
```bash
# Si tienes acceso directo a PostgreSQL
psql -d tu_base_de_datos -f add_ultima_conexion_column.sql
```

## Qué hace esta actualización:

1. ✅ Agrega la columna `ultima_conexion TIMESTAMP` a la tabla `usuarios`
2. ✅ Crea un índice para optimizar consultas por última conexión  
3. ✅ Inicializa el campo con la fecha de registro para usuarios existentes
4. ✅ Actualiza automáticamente el campo cada vez que un usuario hace login

## Funcionalidades que se habilitan:

- **Indicador visual "ONLINE"**: Punto verde para usuarios conectados en los últimos 5 minutos
- **Columna "Última Conexión"**: Muestra cuándo fue la última vez que el usuario se conectó
- **Gestión mejorada**: Los administradores pueden ver patrones de uso y actividad

## Verificación:

Después de ejecutar el script, verifica que todo funcione correctamente:

1. Inicia el backend: `npm start`
2. Ejecuta la app Flutter: `flutter run -d chrome`  
3. Ingresa como administrador
4. Ve a "Gestionar Usuarios"
5. Verifica que aparezca la columna "Última Conexión"

## Notas importantes:

- ⚠️ **Backup**: Siempre haz un respaldo de tu base de datos antes de ejecutar scripts de migración
- ✅ **Seguro**: El script verifica si la columna ya existe antes de crearla
- 🔄 **Automático**: La actualización de `ultima_conexion` es automática en cada login

## Estructura final de la tabla usuarios:

```sql
usuarios:
  - id: SERIAL PRIMARY KEY
  - nombres: VARCHAR
  - apellidos: VARCHAR  
  - correo: VARCHAR
  - contraseña: VARCHAR
  - verificado: BOOLEAN
  - fecha_registro: TIMESTAMP
  - ultima_conexion: TIMESTAMP  ← NUEVO CAMPO
  - foto_perfil_url: VARCHAR
  - id_rol: INTEGER
  -- otros campos...
```

## Troubleshooting:

### Error: "column already exists"
- No es un problema, significa que ya ejecutaste la actualización antes

### Error de conexión a BD:
- Verifica que tu archivo `.env` tenga la configuración correcta de `DATABASE_URL`
- Asegúrate de que PostgreSQL esté corriendo

### No aparece la columna en el CRUD:
- Reinicia el backend después de ejecutar la migración
- Verifica que no haya errores en la consola del backend
