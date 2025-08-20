const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://anderson:123456@localhost:5432/petmatch',
});

async function verificarMutualMatches() {
    try {
        console.log('🔍 Verificando estructura de mutual_matches...');
        
        const query = `
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'mutual_matches'
            ORDER BY ordinal_position;
        `;
        
        const result = await pool.query(query);
        
        if (result.rows.length > 0) {
            console.log('📋 Estructura de tabla mutual_matches:');
            result.rows.forEach(row => {
                console.log(`- ${row.column_name}: ${row.data_type}`);
            });
        } else {
            console.log('❌ La tabla mutual_matches no existe');
        }
        
        // También verificar pet_likes
        console.log('\n🔍 Verificando estructura de pet_likes...');
        
        const queryLikes = `
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'pet_likes'
            ORDER BY ordinal_position;
        `;
        
        const resultLikes = await pool.query(queryLikes);
        
        if (resultLikes.rows.length > 0) {
            console.log('📋 Estructura de tabla pet_likes:');
            resultLikes.rows.forEach(row => {
                console.log(`- ${row.column_name}: ${row.data_type}`);
            });
        } else {
            console.log('❌ La tabla pet_likes no existe');
        }
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

verificarMutualMatches();
