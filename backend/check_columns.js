const {Pool} = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});

async function checkColumns() {
    try {
        const result = await pool.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'mascotas' 
            ORDER BY ordinal_position
        `);
        
        console.log('Columnas de la tabla mascotas:');
        result.rows.forEach(row => {
            console.log(`- ${row.column_name}`);
        });
        
        await pool.end();
    } catch (error) {
        console.error('Error:', error);
        await pool.end();
    }
}

checkColumns();
