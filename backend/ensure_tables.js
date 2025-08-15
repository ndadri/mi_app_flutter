const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function ensureEventoTables() {
    try {
        console.log('🔧 Asegurando que las tablas de eventos existan...');
        
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
                fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        
        // Crear tabla evento_asistencias
        await pool.query(`
            CREATE TABLE IF NOT EXISTS evento_asistencias (
                id SERIAL PRIMARY KEY,
                evento_id INTEGER NOT NULL,
                usuario_id INTEGER NOT NULL,
                asistira BOOLEAN DEFAULT FALSE,
                fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE (evento_id, usuario_id)
            )
        `);
        
        console.log('✅ Tablas aseguradas exitosamente');
        
        // Verificar estructura
        const tablesResult = await pool.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name IN ('eventos', 'evento_asistencias')
        `);
        
        console.log('📋 Tablas confirmadas:', tablesResult.rows.map(r => r.table_name));
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

ensureEventoTables();
