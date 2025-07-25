-- ================================================
-- SCRIPT PARA AGREGAR COLUMNA EDAD A TABLA USUARIOS
-- Pet Match Flutter App
-- ================================================

-- Agregar la columna edad a la tabla usuarios
ALTER TABLE usuarios 
ADD COLUMN edad INTEGER;

-- Agregar una restricción para validar que la edad esté en un rango válido
ALTER TABLE usuarios 
ADD CONSTRAINT check_edad_valida 
CHECK (edad >= 13 AND edad <= 100);

-- Opcional: Agregar un comentario a la columna
COMMENT ON COLUMN usuarios.edad IS 'Edad del usuario en años (13-100)';

-- Verificar que la columna fue agregada correctamente
\d usuarios;

-- Mostrar la estructura actualizada de la tabla
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position;

-- ================================================
-- INSTRUCCIONES DE USO:
-- ================================================
-- 1. Conectarse a PostgreSQL:
--    psql -U tu_usuario -d tu_base_de_datos
-- 
-- 2. Ejecutar este archivo:
--    \i add_edad_column.sql
-- 
-- 3. O copiar y pegar las líneas una por una
-- ================================================

-- Mensaje de confirmación
SELECT 'Columna edad agregada exitosamente a la tabla usuarios!' as mensaje;
