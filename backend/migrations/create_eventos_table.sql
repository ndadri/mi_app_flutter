-- Migración para crear tabla de eventos en PostgreSQL
CREATE TABLE IF NOT EXISTS eventos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    fecha VARCHAR(20) NOT NULL,
    hora VARCHAR(10) NOT NULL,
    lugar VARCHAR(255) NOT NULL,
    imagen VARCHAR(500),
    creado_por INTEGER NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creado_por) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabla para gestionar asistencia a eventos
CREATE TABLE IF NOT EXISTS evento_asistencias (
    id SERIAL PRIMARY KEY,
    evento_id INTEGER NOT NULL,
    usuario_id INTEGER NOT NULL,
    asistira BOOLEAN DEFAULT FALSE,
    fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE (evento_id, usuario_id)
);
