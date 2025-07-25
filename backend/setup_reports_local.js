const { Pool } = require('pg');

// Configuración de la base de datos local
const pool = new Pool({
  user: 'admin',
  host: 'localhost',
  database: 'matchpet',
  password: '12345',
  port: 5432,
});

const createReportTables = async () => {
  const client = await pool.connect();
  
  try {
    console.log('🗄️ Creando tablas del sistema de reportes...');

    // Crear tabla de reportes
    await client.query(`
      CREATE TABLE IF NOT EXISTS reportes (
        id SERIAL PRIMARY KEY,
        usuario_reportador_id INTEGER NOT NULL,
        usuario_reportado_id INTEGER NOT NULL,
        tipo_reporte VARCHAR(50) NOT NULL,
        descripcion TEXT,
        estado VARCHAR(20) DEFAULT 'pendiente',
        fecha_reporte TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        fecha_resolucion TIMESTAMP,
        resuelto_por INTEGER,
        FOREIGN KEY (usuario_reportador_id) REFERENCES usuarios(id),
        FOREIGN KEY (usuario_reportado_id) REFERENCES usuarios(id),
        FOREIGN KEY (resuelto_por) REFERENCES usuarios(id)
      );
    `);

    // Crear índices para mejorar rendimiento
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_reportes_usuario_reportador 
      ON reportes(usuario_reportador_id);
    `);

    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_reportes_usuario_reportado 
      ON reportes(usuario_reportado_id);
    `);

    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_reportes_estado 
      ON reportes(estado);
    `);

    console.log('✅ Tablas del sistema de reportes creadas exitosamente');
    
    // Verificar que las tablas existan
    const result = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'reportes';
    `);
    
    if (result.rows.length > 0) {
      console.log('✅ Verificación: Tabla reportes existe');
    } else {
      console.log('❌ Error: Tabla reportes no fue creada');
    }
    
  } catch (error) {
    console.error('❌ Error creando tablas de reportes:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
};

// Ejecutar si se llama directamente
if (require.main === module) {
  createReportTables();
}

module.exports = createReportTables;
