-- ================================================
-- SCRIPT PARA CORREGIR Y UNIFICAR LA ESTRUCTURA DE LA BASE DE DATOS
-- Pet Match Flutter App
-- ================================================

-- 1. Verificar y crear tabla usuarios si no existe
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(255) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL,
    genero VARCHAR(20) NOT NULL CHECK (genero IN ('Masculino', 'Femenino', 'Otro')),
    ubicacion VARCHAR(255) NOT NULL,
    edad INTEGER CHECK (edad >= 13 AND edad <= 100),
    fecha_nacimiento DATE,
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    foto_perfil_url TEXT,
    codigo_verificacion VARCHAR(10),
    verificado BOOLEAN DEFAULT FALSE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_verificacion TIMESTAMP,
    ultima_conexion TIMESTAMP,
    id_rol INTEGER DEFAULT 1
);

-- 2. Crear tabla de roles si no existe
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    permisos JSONB DEFAULT '{}',
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Insertar roles básicos
INSERT INTO roles (id, nombre, descripcion, permisos, activo)
VALUES 
    (1, 'usuario', 'Usuario normal del sistema', '{}', TRUE),
    (2, 'administrador', 'Administrador del sistema', '{
        "usuarios": {"leer": true, "crear": true, "actualizar": true, "eliminar": true},
        "mascotas": {"leer": true, "crear": true, "actualizar": true, "eliminar": true},
        "matches": {"leer": true, "crear": true, "actualizar": true, "eliminar": true},
        "estadisticas": {"leer": true}
    }', TRUE)
ON CONFLICT (nombre) DO UPDATE SET
    descripcion = EXCLUDED.descripcion,
    permisos = EXCLUDED.permisos,
    activo = EXCLUDED.activo;

-- 4. Crear tabla mascotas unificada
CREATE TABLE IF NOT EXISTS mascotas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    edad INTEGER NOT NULL CHECK (edad >= 1 AND edad <= 15),
    tipo_animal VARCHAR(50) NOT NULL CHECK (tipo_animal IN ('Perro', 'Gato', 'Ave', 'Otro')),
    raza VARCHAR(100),
    sexo VARCHAR(20) NOT NULL CHECK (sexo IN ('Macho', 'Hembra', 'Otro')),
    ciudad VARCHAR(255) NOT NULL,
    descripcion TEXT,
    foto_url TEXT NOT NULL,
    estado VARCHAR(50) NOT NULL CHECK (estado IN ('Soltero', 'Buscando pareja')),
    id_usuario INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Crear tabla de preferencias de matching
CREATE TABLE IF NOT EXISTS matching_preferences (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    estado_relacion VARCHAR(20) NOT NULL DEFAULT 'soltero' CHECK (estado_relacion IN ('soltero', 'buscando_pareja', 'no_disponible')),
    distancia_maxima INTEGER DEFAULT 50,
    edad_minima INTEGER DEFAULT 1,
    edad_maxima INTEGER DEFAULT 20,
    especies_preferidas TEXT[],
    genero_preferido VARCHAR(20) DEFAULT 'ambos' CHECK (genero_preferido IN ('macho', 'hembra', 'ambos')),
    max_distance_km INTEGER DEFAULT 50,
    age_min INTEGER DEFAULT 0,
    age_max INTEGER DEFAULT 20,
    species_preference TEXT[],
    gender_preference VARCHAR(20),
    looking_for VARCHAR(20) DEFAULT 'friendship',
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 6. Crear tabla de matches unificada
DROP TABLE IF EXISTS matches CASCADE;
CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    pet_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
    owner_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    decision VARCHAR(10) NOT NULL CHECK (decision IN ('like', 'dislike')),
    distancia_km DECIMAL(10,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, pet_id)
);

-- 7. Crear tabla de matches mutuos
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

-- 8. Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_usuarios_correo ON usuarios(correo);
CREATE INDEX IF NOT EXISTS idx_usuarios_verificado ON usuarios(verificado);
CREATE INDEX IF NOT EXISTS idx_usuarios_ultima_conexion ON usuarios(ultima_conexion);
CREATE INDEX IF NOT EXISTS idx_mascotas_usuario ON mascotas(id_usuario);
CREATE INDEX IF NOT EXISTS idx_mascotas_tipo_animal ON mascotas(tipo_animal);
CREATE INDEX IF NOT EXISTS idx_mascotas_estado ON mascotas(estado);
CREATE INDEX IF NOT EXISTS idx_matching_preferences_user_id ON matching_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_matches_user_id ON matches(user_id);
CREATE INDEX IF NOT EXISTS idx_matches_pet_id ON matches(pet_id);
CREATE INDEX IF NOT EXISTS idx_matches_owner_id ON matches(owner_id);
CREATE INDEX IF NOT EXISTS idx_matches_decision ON matches(decision);
CREATE INDEX IF NOT EXISTS idx_mutual_matches_users ON mutual_matches(user1_id, user2_id);

-- 9. Insertar preferencias por defecto para usuarios existentes
INSERT INTO matching_preferences (user_id, estado_relacion, distancia_maxima, genero_preferido, max_distance_km, age_min, age_max, looking_for)
SELECT 
    id, 
    'soltero', 
    50, 
    'ambos', 
    50, 
    0, 
    20, 
    'friendship'
FROM usuarios
WHERE id NOT IN (SELECT user_id FROM matching_preferences);

-- 10. Actualizar secuencias si es necesario
SELECT setval('usuarios_id_seq', COALESCE((SELECT MAX(id) FROM usuarios), 1), false);
SELECT setval('mascotas_id_seq', COALESCE((SELECT MAX(id) FROM mascotas), 1), false);
SELECT setval('roles_id_seq', COALESCE((SELECT MAX(id) FROM roles), 1), false);

-- 11. Verificar integridad de la base de datos
SELECT 
    'usuarios' as tabla,
    COUNT(*) as total_registros
FROM usuarios

UNION ALL

SELECT 
    'mascotas' as tabla,
    COUNT(*) as total_registros
FROM mascotas

UNION ALL

SELECT 
    'roles' as tabla,
    COUNT(*) as total_registros
FROM roles

UNION ALL

SELECT 
    'matching_preferences' as tabla,
    COUNT(*) as total_registros
FROM matching_preferences

UNION ALL

SELECT 
    'matches' as tabla,
    COUNT(*) as total_registros
FROM matches

UNION ALL

SELECT 
    'mutual_matches' as tabla,
    COUNT(*) as total_registros
FROM mutual_matches;

-- Comentarios para documentar las tablas
COMMENT ON TABLE usuarios IS 'Tabla de usuarios del sistema Pet Match';
COMMENT ON TABLE roles IS 'Tabla de roles y permisos del sistema';
COMMENT ON TABLE mascotas IS 'Tabla de mascotas registradas en el sistema';
COMMENT ON TABLE matching_preferences IS 'Preferencias de matching para cada usuario';
COMMENT ON TABLE matches IS 'Decisiones de matching (like/dislike) entre usuarios y mascotas';
COMMENT ON TABLE mutual_matches IS 'Matches mutuos cuando ambos usuarios se dan like';

SELECT 'Base de datos estructurada y corregida exitosamente!' as mensaje;
