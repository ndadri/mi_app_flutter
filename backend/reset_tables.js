const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});

async function resetTables() {
    console.log('🔄 REINICIANDO TABLAS DE USUARIOS Y MASCOTAS');
    console.log('============================================');
    
    try {
        // Iniciar transacción
        await pool.query('BEGIN');
        
        console.log('1. 🗑️ Vaciando tabla de matches...');
        await pool.query('DELETE FROM matches');
        await pool.query('DELETE FROM mutual_matches');
        await pool.query('DELETE FROM matching_preferences');
        console.log('   ✅ Matches eliminados');
        
        console.log('2. 🗑️ Vaciando tabla de mascotas...');
        await pool.query('DELETE FROM mascotas');
        console.log('   ✅ Mascotas eliminadas');
        
        console.log('3. 🗑️ Vaciando tabla de usuarios (excepto admin)...');
        await pool.query("DELETE FROM usuarios WHERE correo != 'admin@petmatch.com'");
        console.log('   ✅ Usuarios eliminados (admin preservado)');
        
        console.log('4. 🔄 Reiniciando secuencias de autoincremento...');
        
        // Reiniciar secuencia de usuarios
        const maxUserId = await pool.query('SELECT COALESCE(MAX(id), 0) FROM usuarios');
        const nextUserId = maxUserId.rows[0].coalesce + 1;
        await pool.query(`ALTER SEQUENCE usuarios_id_seq RESTART WITH ${nextUserId}`);
        console.log(`   ✅ Secuencia usuarios reiniciada en: ${nextUserId}`);
        
        // Reiniciar secuencia de mascotas
        await pool.query('ALTER SEQUENCE mascotas_id_seq RESTART WITH 1');
        console.log('   ✅ Secuencia mascotas reiniciada en: 1');
        
        // Reiniciar secuencia de matches
        await pool.query('ALTER SEQUENCE matches_id_seq RESTART WITH 1');
        console.log('   ✅ Secuencia matches reiniciada en: 1');
        
        // Reiniciar secuencia de mutual_matches
        await pool.query('ALTER SEQUENCE mutual_matches_id_seq RESTART WITH 1');
        console.log('   ✅ Secuencia mutual_matches reiniciada en: 1');
        
        // Reiniciar secuencia de matching_preferences
        await pool.query('ALTER SEQUENCE matching_preferences_id_seq RESTART WITH 1');
        console.log('   ✅ Secuencia matching_preferences reiniciada en: 1');
        
        console.log('5. 📊 Verificando estado final...');
        
        // Verificar conteos
        const userCount = await pool.query('SELECT COUNT(*) FROM usuarios');
        const petCount = await pool.query('SELECT COUNT(*) FROM mascotas');
        const matchCount = await pool.query('SELECT COUNT(*) FROM matches');
        const mutualMatchCount = await pool.query('SELECT COUNT(*) FROM mutual_matches');
        const prefCount = await pool.query('SELECT COUNT(*) FROM matching_preferences');
        
        console.log(`   📋 Usuarios restantes: ${userCount.rows[0].count}`);
        console.log(`   📋 Mascotas restantes: ${petCount.rows[0].count}`);
        console.log(`   📋 Matches restantes: ${matchCount.rows[0].count}`);
        console.log(`   📋 Matches mutuos restantes: ${mutualMatchCount.rows[0].count}`);
        console.log(`   📋 Preferencias restantes: ${prefCount.rows[0].count}`);
        
        // Verificar usuario admin
        const adminUser = await pool.query("SELECT id, nombres, correo FROM usuarios WHERE correo = 'admin@petmatch.com'");
        if (adminUser.rows.length > 0) {
            console.log(`   👤 Usuario admin preservado: ${adminUser.rows[0].nombres} (ID: ${adminUser.rows[0].id})`);
        }
        
        // Confirmar transacción
        await pool.query('COMMIT');
        
        console.log('');
        console.log('🎉 REINICIO COMPLETADO EXITOSAMENTE!');
        console.log('============================================');
        console.log('✅ Todas las tablas han sido vaciadas');
        console.log('✅ Secuencias de autoincremento reiniciadas');
        console.log('✅ Usuario admin preservado');
        console.log('');
        console.log('💡 SIGUIENTE PASO:');
        console.log('   Ahora puedes registrar nuevos usuarios y mascotas');
        console.log('   con coordenadas de longitud y latitud correctas');
        console.log('');
        console.log('📱 COMANDOS ÚTILES:');
        console.log('   Backend: npm start');
        console.log('   Frontend: flutter run -d chrome');
        console.log('   Diagnóstico: node diagnostic_petmatch.js');
        
    } catch (error) {
        await pool.query('ROLLBACK');
        console.error('❌ ERROR durante el reinicio:', error);
        console.log('🔄 Transacción revertida');
    } finally {
        await pool.end();
    }
}

// Función para mostrar advertencia
function showWarning() {
    console.log('⚠️  ADVERTENCIA: REINICIO DE TABLAS ⚠️');
    console.log('=====================================');
    console.log('Este script eliminará TODOS los datos de:');
    console.log('- Usuarios (excepto admin@petmatch.com)');
    console.log('- Mascotas');
    console.log('- Matches');
    console.log('- Preferencias de matching');
    console.log('');
    console.log('¿Estás seguro de continuar?');
    console.log('Presiona Ctrl+C para cancelar o Enter para continuar...');
}

// Mostrar advertencia y esperar confirmación
showWarning();

// Esperar entrada del usuario
const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('', (answer) => {
    rl.close();
    resetTables();
});
