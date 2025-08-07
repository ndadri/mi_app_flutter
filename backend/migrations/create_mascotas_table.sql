-- Migration script to create mascotas table with all required fields
CREATE TABLE IF NOT EXISTS mascotas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    edad INTEGER NOT NULL,
    tipo_animal VARCHAR(20) NOT NULL,
    raza VARCHAR(100) NOT NULL,
    foto_url TEXT NOT NULL,
    id_duenio INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    state BOOLEAN NOT NULL  /* TRUE = buscando pareja, FALSE = soltero */
);