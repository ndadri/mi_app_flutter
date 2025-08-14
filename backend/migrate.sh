#!/bin/bash

# Script para ejecutar migraciones de base de datos

echo "🗄️ Ejecutando migraciones de base de datos..."

# Verificar si psql está disponible
if ! command -v psql &> /dev/null; then
    echo "❌ Error: psql no está instalado o no está en el PATH"
    exit 1
fi

# Cargar variables de entorno
if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo "❌ Error: archivo .env no encontrado"
    exit 1
fi

# Verificar que DATABASE_URL esté configurada
if [ -z "$DATABASE_URL" ]; then
    echo "❌ Error: DATABASE_URL no está configurada en .env"
    exit 1
fi

echo "📊 Ejecutando migración de usuarios..."
psql "$DATABASE_URL" -f migrations/create_usuarios_table.sql

if [ $? -eq 0 ]; then
    echo "✅ Migración de usuarios completada"
else
    echo "❌ Error en migración de usuarios"
    exit 1
fi

echo "📊 Ejecutando migración de mascotas..."
psql "$DATABASE_URL" -f migrations/create_mascotas_table.sql

if [ $? -eq 0 ]; then
    echo "✅ Migración de mascotas completada"
else
    echo "❌ Error en migración de mascotas"
    exit 1
fi

echo "🎉 Todas las migraciones completadas exitosamente"
