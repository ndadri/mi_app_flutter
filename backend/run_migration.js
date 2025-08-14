const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Configuración de la base de datos
const pool = new Pool({
    connectionString: 'postgresql://anderson:123456@localhost:5432/petmatch'
});

async function runMigration() {
    try {
        // Leer el archivo de migración
        const migrationPath = path.join(__dirname, 'migrations', 'create_usuarios_table.sql');
        const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
        
        console.log('🔄 Ejecutando migración de usuarios...');
        
        // Ejecutar la migración
        await pool.query(migrationSQL);
        
        console.log('✅ Migración ejecutada exitosamente');
        
        // Verificar que la tabla fue creada
        const result = await pool.query(`
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'usuarios' 
            ORDER BY ordinal_position;
        `);
        
        console.log('\n📋 Estructura de la tabla usuarios:');
        result.rows.forEach(row => {
            console.log(`  - ${row.column_name} (${row.data_type})`);
        });
        
    } catch (error) {
        console.error('❌ Error ejecutando migración:', error.message);
    } finally {
        await pool.end();
    }
}

runMigration();
