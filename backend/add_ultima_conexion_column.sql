-- Agregar columna ultima_conexion a la tabla usuarios
ALTER TABLE usuarios 
ADD COLUMN IF NOT EXISTS ultima_conexion TIMESTAMP;

-- Comentario para documentar el cambio
COMMENT ON COLUMN usuarios.ultima_conexion IS 'Fecha y hora de la última conexión del usuario';

-- Crear índice para mejorar consultas por última conexión
CREATE INDEX IF NOT EXISTS idx_usuarios_ultima_conexion ON usuarios(ultima_conexion);

-- Actualizar usuarios existentes con fecha actual como valor inicial
UPDATE usuarios 
SET ultima_conexion = fecha_registro 
WHERE ultima_conexion IS NULL;

-- Mostrar la estructura actualizada de la tabla
\d usuarios;
