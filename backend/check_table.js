const { Pool } = require('pg');

const pool = new Pool({
    connectionString: 'postgresql://Alexis:123@localhost:5432/petmatch'
});

async function checkTableStructure() {
    try {
        const result = await pool.query(`
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'usuarios' 
            ORDER BY ordinal_position;
        `);
        
        console.log('📋 Columnas existentes en la tabla usuarios:');
        result.rows.forEach((row, index) => {
            console.log(`${index + 1}. ${row.column_name} (${row.data_type})`);
        });
        
        // También mostrar la lista simple
        console.log('\n📝 Lista simple de columnas:');
        const columns = result.rows.map(row => row.column_name);
        console.log(columns.join(', '));
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

checkTableStructure();
