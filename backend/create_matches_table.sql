-- Crear tabla de matches para el sistema de matching de mascotas
CREATE TABLE IF NOT EXISTS matches (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    pet_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
    decision VARCHAR(10) NOT NULL CHECK (decision IN ('like', 'dislike')),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, pet_id)
);

-- Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_matches_user_id ON matches(user_id);
CREATE INDEX IF NOT EXISTS idx_matches_pet_id ON matches(pet_id);
CREATE INDEX IF NOT EXISTS idx_matches_decision ON matches(decision);

-- Comentarios para documentar la tabla
COMMENT ON TABLE matches IS 'Tabla para almacenar las decisiones de matching entre usuarios y mascotas';
COMMENT ON COLUMN matches.user_id IS 'ID del usuario que toma la decisión';
COMMENT ON COLUMN matches.pet_id IS 'ID de la mascota sobre la que se decide';
COMMENT ON COLUMN matches.decision IS 'Decisión tomada: like o dislike';
COMMENT ON COLUMN matches.fecha IS 'Fecha y hora de la decisión';
