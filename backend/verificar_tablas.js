const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://Alexis:123@localhost:5432/petmatch',
});

async function verificarTablas() {
    try {
        console.log('🔍 Verificando tablas existentes...');
        
        const query = `
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name;
        `;
        
        const result = await pool.query(query);
        
        console.log('📋 Tablas encontradas:');
        result.rows.forEach((row, index) => {
            console.log(`${index + 1}. ${row.table_name}`);
        });
        
        // Verificar estructura de la tabla matches si existe
        const matchesQuery = `
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'matches'
            ORDER BY ordinal_position;
        `;
        
        const matchesResult = await pool.query(matchesQuery);
        
        if (matchesResult.rows.length > 0) {
            console.log('\n🔍 Estructura de tabla matches:');
            matchesResult.rows.forEach(row => {
                console.log(`- ${row.column_name}: ${row.data_type}`);
            });
        } else {
            console.log('\n❌ La tabla matches no existe');
        }
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

verificarTablas();
