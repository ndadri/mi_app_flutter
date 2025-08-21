require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function testCrearEvento() {
    try {
        console.log('🔍 Verificando tabla eventos...');
        
        // Verificar si la tabla existe
        const checkTable = await pool.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = 'eventos'
        `);
        
        if (checkTable.rows.length === 0) {
            console.log('❌ La tabla eventos no existe. Creándola...');
            
            await pool.query(`
                CREATE TABLE eventos (
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
            
            console.log('✅ Tabla eventos creada exitosamente');
        } else {
            console.log('✅ La tabla eventos ya existe');
        }
        
        // Verificar estructura de la tabla
        const structure = await pool.query(`
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'eventos'
            ORDER BY ordinal_position
        `);
        
        console.log('📋 Estructura de la tabla eventos:');
        structure.rows.forEach(row => {
            console.log(`   ${row.column_name}: ${row.data_type} (${row.is_nullable === 'YES' ? 'nullable' : 'not null'})`);
        });
        
        // Test de inserción
        console.log('\n🧪 Probando inserción de evento de prueba...');
        
        const testEvento = await pool.query(`
            INSERT INTO eventos (nombre, fecha, hora, lugar, imagen, creado_por)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, nombre
        `, ['Evento de prueba', '2025-08-25', '15:00', 'Parque Central', null, '2']);
        
        console.log('✅ Evento de prueba creado:', testEvento.rows[0]);
        
        // Eliminar el evento de prueba
        await pool.query('DELETE FROM eventos WHERE id = $1', [testEvento.rows[0].id]);
        console.log('🗑️ Evento de prueba eliminado');
        
    } catch (error) {
        console.error('❌ Error:', error);
    } finally {
        await pool.end();
    }
}

testCrearEvento();
