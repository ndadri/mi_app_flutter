@echo off
echo 🗄️ Ejecutando migraciones de base de datos...

REM Verificar que el archivo .env existe
if not exist .env (
    echo ❌ Error: archivo .env no encontrado
    exit /b 1
)

REM Cargar DATABASE_URL del archivo .env
for /f "tokens=1,2 delims==" %%a in (.env) do (
    if "%%a"=="DATABASE_URL" set DATABASE_URL=%%b
)

REM Verificar que DATABASE_URL esté configurada
if "%DATABASE_URL%"=="" (
    echo ❌ Error: DATABASE_URL no está configurada en .env
    exit /b 1
)

echo 📊 Ejecutando migración de usuarios...
psql "%DATABASE_URL%" -f migrations/create_usuarios_table.sql

if %errorlevel% neq 0 (
    echo ❌ Error en migración de usuarios
    exit /b 1
)

echo ✅ Migración de usuarios completada

echo 📊 Ejecutando migración de mascotas...
psql "%DATABASE_URL%" -f migrations/create_mascotas_table.sql

if %errorlevel% neq 0 (
    echo ❌ Error en migración de mascotas
    exit /b 1
)

echo ✅ Migración de mascotas completada
echo 🎉 Todas las migraciones completadas exitosamente
