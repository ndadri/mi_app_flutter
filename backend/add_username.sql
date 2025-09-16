-- Script SQL para agregar columna username
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS username VARCHAR(50) UNIQUE;

-- Generar usernames para usuarios existentes
UPDATE usuarios SET username = LOWER(REPLACE(nombres, ' ', '')) WHERE username IS NULL;
