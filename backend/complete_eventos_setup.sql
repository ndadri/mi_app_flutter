-- Setup completo para eventos en PostgreSQL
-- Conectar a la base de datos petmatch

-- Crear tabla eventos
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

-- Crear tabla evento_asistencias
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

-- Insertar algunos eventos de prueba
INSERT INTO eventos (nombre, fecha, hora, lugar, creado_por) VALUES 
('Paseo Canino en el Parque', '25/08/2025', '10:00', 'Parque La Carolina', 1),
('Feria de Adopción de Mascotas', '30/08/2025', '15:00', 'Centro Comercial El Jardín', 1),
('Competencia de Agilidad Canina', '05/09/2025', '09:00', 'Club Canino Central', 1),
('Taller de Entrenamiento', '10/09/2025', '16:00', 'Escuela Canina Premium', 1),
('Encuentro de Razas Pequeñas', '15/09/2025', '11:00', 'Parque El Ejido', 1)
ON CONFLICT DO NOTHING;
