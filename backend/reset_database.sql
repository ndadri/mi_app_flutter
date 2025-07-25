-- ================================================
-- SCRIPT PARA LIMPIAR Y REINICIAR TABLAS
-- Pet Match Flutter App
-- ================================================

-- Eliminar todos los datos de la tabla mascotas
-- (Primero las mascotas porque pueden tener referencia a usuarios)
DELETE FROM mascotas;

-- Eliminar todos los datos de la tabla usuarios
DELETE FROM usuarios;

-- Reiniciar el autoincrement de la tabla mascotas a 1
ALTER SEQUENCE mascotas_id_seq RESTART WITH 1;

-- Reiniciar el autoincrement de la tabla usuarios a 1
ALTER SEQUENCE usuarios_id_seq RESTART WITH 1;

-- Verificar que las tablas están vacías
SELECT COUNT(*) AS total_usuarios FROM usuarios;
SELECT COUNT(*) AS total_mascotas FROM mascotas;

-- Mostrar el próximo ID que se asignará
SELECT nextval('usuarios_id_seq') AS proximo_id_usuario;
SELECT nextval('mascotas_id_seq') AS proximo_id_mascota;

-- Regresar las secuencias al valor 1 después de la verificación
ALTER SEQUENCE usuarios_id_seq RESTART WITH 1;
ALTER SEQUENCE mascotas_id_seq RESTART WITH 1;

-- ================================================
-- INSTRUCCIONES DE USO:
-- ================================================
-- 1. Conectarse a PostgreSQL:
--    psql -U tu_usuario -d tu_base_de_datos
-- 
-- 2. Ejecutar este archivo:
--    \i reset_database.sql
-- 
-- 3. O copiar y pegar las líneas una por una
-- ================================================

PRINT 'Base de datos limpia y reiniciada exitosamente!';
