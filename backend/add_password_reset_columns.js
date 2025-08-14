const { Pool } = require('pg');

const pool = new Pool({
    connectionString: 'postgresql://anderson:123456@localhost:5432/petmatch'
});

async function addPasswordResetColumns() {
    try {
        console.log('🔄 Agregando columnas para recuperación de contraseña...');
        
        // Agregar columnas para recuperación de contraseña
        await pool.query(`
            ALTER TABLE usuarios 
            ADD COLUMN IF NOT EXISTS reset_password_token VARCHAR(255),
            ADD COLUMN IF NOT EXISTS reset_password_expires TIMESTAMP,
            ADD COLUMN IF NOT EXISTS reset_password_code VARCHAR(6);
        `);
        
        console.log('✅ Columnas agregadas exitosamente:');
        console.log('  - reset_password_token: Para almacenar token único');
        console.log('  - reset_password_expires: Fecha de expiración del código');
        console.log('  - reset_password_code: Código de 6 dígitos para verificación');
        
        // Verificar que las columnas se agregaron
        const result = await pool.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'usuarios' 
            AND column_name LIKE '%reset%'
            ORDER BY column_name;
        `);
        
        console.log('\n📋 Columnas de recuperación disponibles:');
        result.rows.forEach(row => {
            console.log(`  - ${row.column_name}`);
        });
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

addPasswordResetColumns();
