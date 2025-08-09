const { Pool } = require('pg');

const pool = new Pool({
    connectionString: 'postgresql://anderson:123456@localhost:5432/petmatch'
});

async function testPasswordResetSetup() {
    try {
        console.log('🧪 Probando configuración de recuperación de contraseña...\n');
        
        // 1. Verificar columnas de reset
        console.log('1️⃣ Verificando columnas de reset...');
        const columnsResult = await pool.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'usuarios' 
            AND column_name LIKE '%reset%'
            ORDER BY column_name;
        `);
        
        if (columnsResult.rows.length === 3) {
            console.log('✅ Columnas de reset creadas correctamente:');
            columnsResult.rows.forEach(row => {
                console.log(`   - ${row.column_name} (${row.data_type})`);
            });
        } else {
            console.log('❌ Faltan columnas de reset');
            return;
        }
        
        // 2. Verificar que existe al menos un usuario para probar
        console.log('\n2️⃣ Verificando usuarios disponibles...');
        const usersResult = await pool.query(`
            SELECT correo, nombres, apellidos 
            FROM usuarios 
            LIMIT 3;
        `);
        
        if (usersResult.rows.length > 0) {
            console.log('✅ Usuarios disponibles para pruebas:');
            usersResult.rows.forEach(user => {
                console.log(`   - ${user.correo} (${user.nombres} ${user.apellidos})`);
            });
        } else {
            console.log('❌ No hay usuarios registrados para probar');
        }
        
        console.log('\n🚀 ENDPOINTS DISPONIBLES:');
        console.log('📍 POST /api/forgot-password');
        console.log('   Body: { "correo": "email@ejemplo.com" }');
        console.log('   Descripción: Envía código de recuperación por email');
        
        console.log('\n📍 POST /api/verify-reset-code');
        console.log('   Body: { "correo": "email@ejemplo.com", "codigo": "123456" }');
        console.log('   Descripción: Verifica el código recibido por email');
        
        console.log('\n📍 POST /api/reset-password');
        console.log('   Body: { "correo": "email@ejemplo.com", "reset_token": "token", "nueva_contraseña": "nueva123" }');
        console.log('   Descripción: Establece nueva contraseña');
        
        console.log('\n✅ ¡Sistema de recuperación de contraseña listo para usar!');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

testPasswordResetSetup();
