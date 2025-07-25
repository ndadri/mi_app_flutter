const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function addUltimaConexionColumn() {
    try {
        console.log('🔄 Iniciando actualización de base de datos...');
        
        // Verificar si la columna ya existe
        const checkColumnQuery = `
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'usuarios' 
            AND column_name = 'ultima_conexion';
        `;
        
        const columnExists = await pool.query(checkColumnQuery);
        
        if (columnExists.rows.length > 0) {
            console.log('✅ La columna ultima_conexion ya existe.');
            return;
        }
        
        // Agregar la columna
        await pool.query(`
            ALTER TABLE usuarios 
            ADD COLUMN ultima_conexion TIMESTAMP;
        `);
        console.log('✅ Columna ultima_conexion agregada exitosamente.');
        
        // Crear índice
        await pool.query(`
            CREATE INDEX IF NOT EXISTS idx_usuarios_ultima_conexion 
            ON usuarios(ultima_conexion);
        `);
        console.log('✅ Índice para ultima_conexion creado.');
        
        // Actualizar usuarios existentes
        const updateResult = await pool.query(`
            UPDATE usuarios 
            SET ultima_conexion = fecha_registro 
            WHERE ultima_conexion IS NULL;
        `);
        console.log(`✅ ${updateResult.rowCount} usuarios actualizados con fecha inicial.`);
        
        // Mostrar estructura actualizada
        const tableStructure = await pool.query(`
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'usuarios' 
            ORDER BY ordinal_position;
        `);
        
        console.log('\n📋 Estructura actualizada de la tabla usuarios:');
        tableStructure.rows.forEach(row => {
            console.log(`  - ${row.column_name}: ${row.data_type} (${row.is_nullable === 'YES' ? 'NULL' : 'NOT NULL'})`);
        });
        
        console.log('\n🎉 Actualización de base de datos completada exitosamente!');
        
    } catch (error) {
        console.error('❌ Error actualizando la base de datos:', error);
        throw error;
    } finally {
        await pool.end();
    }
}

// Ejecutar si se llama directamente
if (require.main === module) {
    addUltimaConexionColumn()
        .then(() => {
            console.log('✅ Script ejecutado exitosamente');
            process.exit(0);
        })
        .catch((error) => {
            console.error('❌ Error ejecutando script:', error);
            process.exit(1);
        });
}

module.exports = { addUltimaConexionColumn };
