-- Migration script to create usuarios table with all required fields
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL,
    genero VARCHAR(50) NOT NULL CHECK (genero IN ('Hombre', 'Mujer', 'No Binario', 'Prefiero no decirlo')),
    ubicacion TEXT NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    latitud DECIMAL(10, 8) NULL,
    longitud DECIMAL(11, 8) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);