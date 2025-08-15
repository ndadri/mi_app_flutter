const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function createEventoTablesSimple() {
    try {
        console.log('🔧 Creando/verificando tabla eventos...');
        
        // Eliminar tabla si existe para crearla limpia
        await pool.query('DROP TABLE IF EXISTS evento_asistencias CASCADE');
        await pool.query('DROP TABLE IF EXISTS eventos CASCADE');
        
        // Crear tabla eventos sin foreign key primero
        await pool.query(`
            CREATE TABLE eventos (
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
            CREATE TABLE evento_asistencias (
                id SERIAL PRIMARY KEY,
                evento_id INTEGER NOT NULL,
                usuario_id INTEGER NOT NULL,
                asistira BOOLEAN DEFAULT FALSE,
                fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (evento_id) REFERENCES eventos(id) ON DELETE CASCADE,
                UNIQUE (evento_id, usuario_id)
            )
        `);
        
        console.log('✅ Tablas creadas exitosamente');
        
        // Probar insertar un evento
        const testResult = await pool.query(`
            INSERT INTO eventos (nombre, fecha, hora, lugar, creado_por)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id
        `, ['Test Event', '2025-08-15', '10:00', 'Test Location', 2]);
        
        console.log('✅ Evento de prueba insertado con ID:', testResult.rows[0].id);
        
        // Eliminar evento de prueba
        await pool.query('DELETE FROM eventos WHERE id = $1', [testResult.rows[0].id]);
        console.log('🗑️ Evento de prueba eliminado');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error('Stack:', error.stack);
    } finally {
        await pool.end();
    }
}

createEventoTablesSimple();
