const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function fixEventosDatabase() {
    try {
        console.log('🔧 ARREGLANDO BASE DE DATOS DE EVENTOS...');
        
        // 1. Eliminar tablas existentes para empezar limpio
        await pool.query('DROP TABLE IF EXISTS evento_asistencias CASCADE');
        await pool.query('DROP TABLE IF EXISTS eventos CASCADE');
        console.log('🗑️ Tablas anteriores eliminadas');
        
        // 2. Crear tabla eventos desde cero
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
        console.log('✅ Tabla eventos creada');
        
        // 3. Crear tabla evento_asistencias
        await pool.query(`
            CREATE TABLE evento_asistencias (
                id SERIAL PRIMARY KEY,
                evento_id INTEGER NOT NULL REFERENCES eventos(id) ON DELETE CASCADE,
                usuario_id INTEGER NOT NULL,
                asistira BOOLEAN DEFAULT FALSE,
                fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE (evento_id, usuario_id)
            )
        `);
        console.log('✅ Tabla evento_asistencias creada');
        
        // 4. Insertar evento de prueba
        const testEvent = await pool.query(`
            INSERT INTO eventos (nombre, fecha, hora, lugar, creado_por)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *
        `, ['Evento de Prueba', '2025-08-15', '10:00', 'Lugar de Prueba', 2]);
        
        console.log('✅ Evento de prueba creado:', testEvent.rows[0]);
        
        // 5. Eliminar evento de prueba
        await pool.query('DELETE FROM eventos WHERE id = $1', [testEvent.rows[0].id]);
        console.log('✅ Test completado exitosamente');
        
        console.log('🎉 BASE DE DATOS ARREGLADA COMPLETAMENTE');
        
    } catch (error) {
        console.error('❌ ERROR:', error.message);
        console.error('Stack:', error.stack);
    } finally {
        await pool.end();
    }
}

fixEventosDatabase();
