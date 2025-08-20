const { Pool } = require('pg');

const pool = new Pool({
    connectionString: 'postgresql://Alexis:123@localhost:5432/petmatch'
});

async function checkGenderConstraint() {
    try {
        const result = await pool.query(`
            SELECT con.conname, pg_get_constraintdef(con.oid) AS definition
            FROM pg_constraint con
            JOIN pg_class rel ON rel.oid = con.conrelid
            WHERE rel.relname = 'usuarios' AND con.contype = 'c';
        `);
        
        console.log('🔍 Restricciones CHECK en la tabla usuarios:');
        result.rows.forEach(row => {
            console.log(`- ${row.conname}: ${row.definition}`);
        });
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

checkGenderConstraint();
