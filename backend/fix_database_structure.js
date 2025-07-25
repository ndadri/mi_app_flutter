const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

const fixDatabaseStructure = async () => {
    const client = await pool.connect();
    
    try {
        console.log('🔧 Iniciando corrección de estructura de base de datos...');
        
        // Leer el archivo SQL
        const fs = require('fs');
        const path = require('path');
        const sqlScript = fs.readFileSync(path.join(__dirname, 'fix_database_structure.sql'), 'utf8');
        
        // Ejecutar el script SQL
        await client.query(sqlScript);
        
        console.log('✅ Estructura de base de datos corregida exitosamente');
        
        // Verificar las tablas
        const result = await client.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name;
        `);
        
        console.log('📋 Tablas en la base de datos:');
        result.rows.forEach(row => {
            console.log(`   - ${row.table_name}`);
        });
        
    } catch (error) {
        console.error('❌ Error corrigiendo estructura de base de datos:', error);
        throw error;
    } finally {
        client.release();
    }
};

// Ejecutar si es llamado directamente
if (require.main === module) {
    require('dotenv').config();
    fixDatabaseStructure()
        .then(() => {
            console.log('🎉 Proceso completado exitosamente');
            process.exit(0);
        })
        .catch((error) => {
            console.error('💥 Error en el proceso:', error);
            process.exit(1);
        });
}

module.exports = fixDatabaseStructure;
