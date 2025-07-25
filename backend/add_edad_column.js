// ================================================
// SCRIPT PARA AGREGAR COLUMNA EDAD A TABLA USUARIOS
// Pet Match Flutter App - Node.js Version
// ================================================

const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function addEdadColumn() {
    console.log('🔄 Agregando columna edad a tabla usuarios...');
    
    try {
        // Verificar si la columna ya existe
        const checkColumn = await pool.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'usuarios' AND column_name = 'edad'
        `);
        
        if (checkColumn.rows.length > 0) {
            console.log('⚠️ La columna "edad" ya existe en la tabla usuarios');
            return;
        }
        
        // Agregar la columna edad
        console.log('📝 Agregando columna edad...');
        await pool.query('ALTER TABLE usuarios ADD COLUMN edad INTEGER');
        
        // Agregar restricción de validación
        console.log('🛡️ Agregando restricción de validación...');
        await pool.query(`
            ALTER TABLE usuarios 
            ADD CONSTRAINT check_edad_valida 
            CHECK (edad >= 13 AND edad <= 100)
        `);
        
        // Agregar comentario a la columna
        console.log('💬 Agregando comentario a la columna...');
        await pool.query(`
            COMMENT ON COLUMN usuarios.edad IS 'Edad del usuario en años (13-100)'
        `);
        
        // Verificar la estructura actualizada
        console.log('🔍 Verificando estructura de la tabla...');
        const tableStructure = await pool.query(`
            SELECT column_name, data_type, is_nullable, column_default 
            FROM information_schema.columns 
            WHERE table_name = 'usuarios' 
            ORDER BY ordinal_position
        `);
        
        console.log('✅ Estructura actualizada de la tabla usuarios:');
        console.table(tableStructure.rows);
        
        console.log('🎉 Columna edad agregada exitosamente!');
        console.log('📋 Detalles:');
        console.log('   - Tipo: INTEGER');
        console.log('   - Restricción: edad >= 13 AND edad <= 100');
        console.log('   - Permite NULL: Sí');
        
    } catch (error) {
        console.error('❌ Error al agregar columna edad:', error.message);
        
        if (error.code === '42701') {
            console.log('💡 La columna "edad" ya existe en la tabla');
        } else if (error.code === '42P01') {
            console.error('💡 La tabla "usuarios" no existe');
        } else {
            console.error('💡 Asegúrate de que:');
            console.error('   - La base de datos esté corriendo');
            console.error('   - Las variables de entorno estén configuradas');
            console.error('   - Tengas permisos de ALTER TABLE');
        }
    } finally {
        await pool.end();
        console.log('🔌 Conexión a base de datos cerrada');
    }
}

// Ejecutar el script
addEdadColumn();
