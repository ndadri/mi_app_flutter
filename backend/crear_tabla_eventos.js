require('dotenv').config();
const { Pool } = require('pg');

console.log('🔧 Creando tabla eventos...');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function crearTablaEventos() {
    try {
        // Crear tabla eventos
        await pool.query(`
            CREATE TABLE IF NOT EXISTS eventos (
                id SERIAL PRIMARY KEY,
                nombre VARCHAR(255) NOT NULL,
                fecha VARCHAR(50) NOT NULL,
                hora VARCHAR(50) NOT NULL,
                lugar VARCHAR(255) NOT NULL,
                imagen VARCHAR(500),
                creado_por VARCHAR(50) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        
        console.log('✅ Tabla eventos creada/verificada');
        
        // Crear tabla de asistencias si no existe
        await pool.query(`
            CREATE TABLE IF NOT EXISTS evento_asistencias (
                id SERIAL PRIMARY KEY,
                evento_id INTEGER REFERENCES eventos(id) ON DELETE CASCADE,
                usuario_id VARCHAR(50) NOT NULL,
                asistira BOOLEAN NOT NULL,
                fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(evento_id, usuario_id)
            )
        `);
        
        console.log('✅ Tabla evento_asistencias creada/verificada');
        
        // Verificar que las tablas existen
        const eventos = await pool.query("SELECT COUNT(*) FROM eventos");
        const asistencias = await pool.query("SELECT COUNT(*) FROM evento_asistencias");
        
        console.log(`📊 Eventos en DB: ${eventos.rows[0].count}`);
        console.log(`📊 Asistencias en DB: ${asistencias.rows[0].count}`);
        
    } catch (error) {
        console.error('❌ Error:', error);
    } finally {
        await pool.end();
        console.log('🔚 Conexión cerrada');
    }
}

crearTablaEventos();
