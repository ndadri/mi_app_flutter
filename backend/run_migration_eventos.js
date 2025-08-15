const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { Pool } = require('pg');
const fs = require('fs');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function runEventosMigration() {
    try {
        console.log('🔧 Ejecutando migración de eventos...');
        
        // Leer el archivo SQL
        const migrationSQL = fs.readFileSync(
            path.join(__dirname, 'migrations', 'create_eventos_table.sql'),
            'utf8'
        );
        
        // Ejecutar la migración
        await pool.query(migrationSQL);
        console.log('✅ Migración ejecutada exitosamente');
        
        // Verificar que las tablas se crearon
        const eventos = await pool.query(`
            SELECT table_name FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name IN ('eventos', 'evento_asistencias')
        `);
        
        console.log('📋 Tablas encontradas:', eventos.rows.map(r => r.table_name));
        
        // Intentar crear un evento de prueba
        const testEvent = await pool.query(`
            INSERT INTO eventos (nombre, fecha, hora, lugar, creado_por)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id
        `, ['Evento de Prueba', '2025-08-15', '10:00', 'Lugar de Prueba', 2]);
        
        console.log('✅ Evento de prueba creado con ID:', testEvent.rows[0].id);
        
        // Eliminar el evento de prueba
        await pool.query('DELETE FROM eventos WHERE id = $1', [testEvent.rows[0].id]);
        console.log('🗑️ Evento de prueba eliminado');
        
    } catch (error) {
        console.error('❌ Error en migración:', error.message);
    } finally {
        pool.end();
    }
}

runEventosMigration();
