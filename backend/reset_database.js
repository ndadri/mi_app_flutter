// ================================================
// SCRIPT PARA LIMPIAR Y REINICIAR TABLAS
// Pet Match Flutter App - Node.js Version
// ================================================

const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function resetDatabase() {
    console.log('🔄 Iniciando limpieza de base de datos...');
    
    try {
        // Eliminar todos los datos de mascotas primero (por las foreign keys)
        console.log('🗑️ Eliminando datos de mascotas...');
        await pool.query('DELETE FROM mascotas');
        
        // Eliminar todos los datos de usuarios
        console.log('🗑️ Eliminando datos de usuarios...');
        await pool.query('DELETE FROM usuarios');
        
        // Reiniciar secuencias
        console.log('🔄 Reiniciando secuencias...');
        await pool.query('ALTER SEQUENCE mascotas_id_seq RESTART WITH 1');
        await pool.query('ALTER SEQUENCE usuarios_id_seq RESTART WITH 1');
        
        // Verificar que las tablas están vacías
        const usuariosCount = await pool.query('SELECT COUNT(*) as count FROM usuarios');
        const mascotasCount = await pool.query('SELECT COUNT(*) as count FROM mascotas');
        
        console.log('✅ Limpieza completada:');
        console.log(`   - Usuarios en tabla: ${usuariosCount.rows[0].count}`);
        console.log(`   - Mascotas en tabla: ${mascotasCount.rows[0].count}`);
        console.log('✅ Las secuencias de ID han sido reiniciadas a 1');
        console.log('🎉 Base de datos limpia y lista para usar!');
        
    } catch (error) {
        console.error('❌ Error al limpiar la base de datos:', error.message);
        console.error('💡 Asegúrate de que:');
        console.error('   - La base de datos esté corriendo');
        console.error('   - Las variables de entorno estén configuradas');
        console.error('   - Las tablas "usuarios" y "mascotas" existan');
    } finally {
        await pool.end();
        console.log('🔌 Conexión a base de datos cerrada');
    }
}

// Ejecutar el script
resetDatabase();
