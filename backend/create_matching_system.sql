-- Crear tabla de preferencias de matching
CREATE TABLE IF NOT EXISTS matching_preferences (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    estado_relacion VARCHAR(20) NOT NULL CHECK (estado_relacion IN ('soltero', 'buscando_pareja', 'no_disponible')),
    distancia_maxima INTEGER DEFAULT 50, -- En kilómetros
    edad_minima INTEGER DEFAULT 1,
    edad_maxima INTEGER DEFAULT 20,
    especies_preferidas TEXT[], -- Array de especies preferidas
    genero_preferido VARCHAR(20) CHECK (genero_preferido IN ('macho', 'hembra', 'ambos')),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- Crear tabla de matches con información adicional
DROP TABLE IF EXISTS matches;
CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    pet_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
    owner_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    decision VARCHAR(10) NOT NULL CHECK (decision IN ('like', 'dislike')),
    distancia_km DECIMAL(10,2), -- Distancia calculada en el momento del match
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, pet_id)
);

-- Crear tabla de matches mutuos (cuando ambos se dan like)
CREATE TABLE IF NOT EXISTS mutual_matches (
    id SERIAL PRIMARY KEY,
    user1_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    user2_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    pet1_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
    pet2_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
    fecha_match TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    UNIQUE(user1_id, user2_id, pet1_id, pet2_id)
);

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_matching_preferences_user_id ON matching_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_matching_preferences_estado ON matching_preferences(estado_relacion);
CREATE INDEX IF NOT EXISTS idx_matches_user_id ON matches(user_id);
CREATE INDEX IF NOT EXISTS idx_matches_pet_id ON matches(pet_id);
CREATE INDEX IF NOT EXISTS idx_matches_owner_id ON matches(owner_id);
CREATE INDEX IF NOT EXISTS idx_matches_decision ON matches(decision);
CREATE INDEX IF NOT EXISTS idx_mutual_matches_users ON mutual_matches(user1_id, user2_id);

-- Insertar preferencias por defecto para usuarios existentes
INSERT INTO matching_preferences (user_id, estado_relacion, distancia_maxima, genero_preferido)
SELECT id, 'soltero', 50, 'ambos'
FROM usuarios
WHERE id NOT IN (SELECT user_id FROM matching_preferences);

-- Comentarios para documentar las tablas
COMMENT ON TABLE matching_preferences IS 'Preferencias de matching para cada usuario';
COMMENT ON TABLE matches IS 'Decisiones de matching (like/dislike) entre usuarios y mascotas';
COMMENT ON TABLE mutual_matches IS 'Matches mutuos cuando ambos usuarios se dan like';
