# 🗑️ Scripts de Limpieza de Base de Datos

Este directorio contiene scripts para limpiar completamente las tablas de usuarios y mascotas, reiniciando los IDs automáticos desde 1.

## 📁 Archivos incluidos:

### 1. `reset_database.sql`
Script SQL puro que puedes ejecutar directamente en PostgreSQL.

### 2. `reset_database.js`
Script de Node.js que usa la misma conexión de la aplicación.

## 🚀 Formas de ejecutar:

### Opción 1: Usando Node.js (Recomendado)
```bash
# Desde el directorio backend
npm run reset-db
```

### Opción 2: Usando el script SQL directamente
```bash
# Conectarse a PostgreSQL
psql -U tu_usuario -d tu_base_de_datos

# Ejecutar el archivo SQL
\i reset_database.sql
```

### Opción 3: Ejecutar Node.js directamente
```bash
# Desde el directorio backend
node reset_database.js
```

## ⚠️ **ADVERTENCIA IMPORTANTE:**

🚨 **ESTOS SCRIPTS ELIMINAN TODOS LOS DATOS PERMANENTEMENTE**

- ❌ Se borrarán TODOS los usuarios registrados
- ❌ Se borrarán TODAS las mascotas registradas  
- ❌ Se reiniciarán los IDs a 1
- ❌ Esta operación NO se puede deshacer

## ✅ Lo que hacen los scripts:

1. **Eliminan todos los datos** de la tabla `mascotas`
2. **Eliminan todos los datos** de la tabla `usuarios`
3. **Reinician las secuencias** de autoincremento a 1
4. **Verifican** que la limpieza fue exitosa
5. **Muestran confirmación** de la operación

## 🔧 Requisitos:

- Base de datos PostgreSQL corriendo
- Variables de entorno configuradas (`.env`)
- Tablas `usuarios` y `mascotas` existentes
- Permisos de escritura en la base de datos

## 🎯 Cuándo usar:

- 🧪 Durante desarrollo y testing
- 🔄 Para resetear datos de prueba
- 🧹 Para limpiar datos incorrectos
- 📊 Para empezar con base de datos limpia

## 📋 Ejemplo de salida exitosa:

```
🔄 Iniciando limpieza de base de datos...
🗑️ Eliminando datos de mascotas...
🗑️ Eliminando datos de usuarios...
🔄 Reiniciando secuencias...
✅ Limpieza completada:
   - Usuarios en tabla: 0
   - Mascotas en tabla: 0
✅ Las secuencias de ID han sido reiniciadas a 1
🎉 Base de datos limpia y lista para usar!
🔌 Conexión a base de datos cerrada
```
