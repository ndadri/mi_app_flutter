require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function createChatTables() {
    console.log('🗃️ Creando tablas del sistema de chat...\n');
    
    try {
        // Leer el archivo SQL
        const sqlFile = path.join(__dirname, 'create_chat_tables.sql');
        const sql = fs.readFileSync(sqlFile, 'utf8');
        
        // Ejecutar el SQL
        await pool.query(sql);
        
        console.log('✅ Tablas de chat creadas exitosamente:');
        console.log('   - chats (conversaciones)');
        console.log('   - mensajes');
        console.log('   - índices de rendimiento');
        console.log('   - funciones auxiliares');
        console.log('   - triggers automáticos');
        
        // Verificar que las tablas existen
        console.log('\n🔍 Verificando estructura de tablas...');
        
        const chatsTable = await pool.query(`
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'chats'
            ORDER BY ordinal_position;
        `);
        
        const mensajesTable = await pool.query(`
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'mensajes'
            ORDER BY ordinal_position;
        `);
        
        console.log('\n📋 Tabla CHATS:');
        chatsTable.rows.forEach(col => {
            console.log(`   - ${col.column_name} (${col.data_type}) ${col.is_nullable === 'NO' ? '* OBLIGATORIO' : ''}`);
        });
        
        console.log('\n📋 Tabla MENSAJES:');
        mensajesTable.rows.forEach(col => {
            console.log(`   - ${col.column_name} (${col.data_type}) ${col.is_nullable === 'NO' ? '* OBLIGATORIO' : ''}`);
        });
        
        // Verificar usuarios disponibles para pruebas
        console.log('\n👥 Usuarios disponibles para crear chats:');
        const users = await pool.query('SELECT id, nombres, apellidos FROM usuarios ORDER BY id');
        users.rows.forEach(user => {
            console.log(`   - ID: ${user.id}, Nombre: ${user.nombres} ${user.apellidos}`);
        });
        
        console.log('\n🎉 Sistema de chat listo para usar!');
        
    } catch (error) {
        console.error('❌ Error al crear tablas de chat:', error.message);
        console.error('📋 Detalles:', error.stack);
    } finally {
        await pool.end();
    }
}

// Ejecutar la función
createChatTables();
