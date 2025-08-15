const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function checkEventoTable() {
    try {
        console.log('🔍 Verificando tabla eventos...');
        
        // Verificar si la tabla existe y su estructura
        const tableInfo = await pool.query(`
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'eventos'
            ORDER BY ordinal_position
        `);
        
        if (tableInfo.rows.length === 0) {
            console.log('❌ La tabla eventos no existe');
            return;
        }
        
        console.log('✅ Estructura de tabla eventos:');
        tableInfo.rows.forEach(col => {
            console.log(`  - ${col.column_name}: ${col.data_type} (${col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL'})`);
        });
        
        // Verificar cuántos eventos hay
        const eventCount = await pool.query('SELECT COUNT(*) FROM eventos');
        console.log(`📊 Total de eventos: ${eventCount.rows[0].count}`);
        
        // Verificar algunos eventos
        const events = await pool.query('SELECT id, nombre, fecha, creado_por FROM eventos LIMIT 3');
        console.log('📋 Eventos existentes:');
        events.rows.forEach(event => {
            console.log(`  - ID: ${event.id}, Nombre: ${event.nombre}, Fecha: ${event.fecha}, Creador: ${event.creado_por}`);
        });
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        pool.end();
    }
}

checkEventoTable();
