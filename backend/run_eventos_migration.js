const { Pool } = require('pg');

async function runEventosMigration() {
  try {
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL || 'postgresql://Alexis:123@localhost:5432/petmatch'
    });

    console.log('✅ Conectado a PostgreSQL');

    // Crear tabla eventos
    await pool.query(`
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
      )
    `);
    
    console.log('✅ Tabla eventos creada');

    // Crear tabla evento_asistencias
    await pool.query(`
      CREATE TABLE IF NOT EXISTS evento_asistencias (
        id SERIAL PRIMARY KEY,
        evento_id INTEGER NOT NULL,
        usuario_id INTEGER NOT NULL,
        asistira BOOLEAN DEFAULT FALSE,
        fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
        UNIQUE (evento_id, usuario_id)
      )
    `);
    
    console.log('✅ Tabla evento_asistencias creada');

    // Insertar algunos eventos de prueba
    await pool.query(`
      INSERT INTO eventos (nombre, fecha, hora, lugar, creado_por) VALUES 
      ('Paseo Canino en el Parque', '25/08/2025', '10:00', 'Parque La Carolina', 1),
      ('Feria de Adopción', '30/08/2025', '15:00', 'Centro Comercial El Jardín', 1),
      ('Competencia de Agilidad', '05/09/2025', '09:00', 'Club Canino Central', 1)
      ON CONFLICT DO NOTHING
    `);
    
    console.log('✅ Eventos de prueba insertados');

    await pool.end();
    console.log('✅ Migración completada exitosamente');
  } catch (error) {
    console.error('❌ Error en migración:', error);
  }
}

runEventosMigration();
