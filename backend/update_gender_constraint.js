const { Pool } = require('pg');

const pool = new Pool({
    connectionString: 'postgresql://anderson:123456@localhost:5432/petmatch'
});

async function updateGenderConstraint() {
    try {
        console.log('🔄 Actualizando restricción de género...');
        
        // Primero, eliminar la restricción actual
        await pool.query(`
            ALTER TABLE usuarios 
            DROP CONSTRAINT IF EXISTS usuarios_genero_check;
        `);
        
        console.log('✅ Restricción anterior eliminada');
        
        // Agregar la nueva restricción con los valores que quieres
        await pool.query(`
            ALTER TABLE usuarios 
            ADD CONSTRAINT usuarios_genero_check 
            CHECK (genero IN ('Hombre', 'Mujer', 'No Binario', 'Prefiero no decirlo'));
        `);
        
        console.log('✅ Nueva restricción agregada con valores: Hombre, Mujer, No Binario, Prefiero no decirlo');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

updateGenderConstraint();
