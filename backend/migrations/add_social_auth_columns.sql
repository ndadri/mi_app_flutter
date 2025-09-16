-- Agregar columnas para autenticación social
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS provider VARCHAR(50) DEFAULT 'email';
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS photo_url TEXT;
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Crear índice para búsqueda por email y provider
CREATE INDEX IF NOT EXISTS idx_usuarios_email_provider ON usuarios(correo, provider);
