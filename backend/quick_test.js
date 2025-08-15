const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

console.log('🔍 Configuración actual:');
console.log('DATABASE_URL:', process.env.DATABASE_URL);
console.log('PORT:', process.env.PORT);

// Test simple sin Pool
const { Client } = require('pg');

async function quickTest() {
    const client = new Client({
        connectionString: process.env.DATABASE_URL,
    });
    
    try {
        console.log('🔌 Intentando conectar...');
        await client.connect();
        console.log('✅ Conexión exitosa');
        
        const result = await client.query('SELECT NOW()');
        console.log('🕐 Tiempo actual:', result.rows[0].now);
        
        // Verificar si existen las tablas
        const tables = await client.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name IN ('eventos', 'evento_asistencias', 'usuarios')
        `);
        
        console.log('📋 Tablas existentes:', tables.rows.map(r => r.table_name));
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await client.end();
    }
}

quickTest();
