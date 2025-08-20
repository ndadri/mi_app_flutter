const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://anderson:123456@localhost:5432/petmatch',
});

async function mostrarUsuarios() {
    try {
        console.log('🔍 Consultando usuarios en la base de datos...');
        const result = await pool.query('SELECT id, correo, nombres, apellidos FROM usuarios ORDER BY id LIMIT 10');
        
        if (result.rows.length === 0) {
            console.log('❌ No hay usuarios registrados en la base de datos.');
            console.log('\n💡 Para crear un usuario de prueba, puedes usar:');
            console.log('Correo: admin@test.com');
            console.log('Contraseña: admin123');
            console.log('\nO registrarte desde la app con cualquier credencial.');
        } else {
            console.log(`✅ Encontrados ${result.rows.length} usuarios:`);
            result.rows.forEach((user, index) => {
                console.log(`${index + 1}. ID: ${user.id} | Email: ${user.correo} | Nombre: ${user.nombres} ${user.apellidos}`);
            });
        }
        
        await pool.end();
    } catch (error) {
        console.error('❌ Error consultando usuarios:', error.message);
        await pool.end();
    }
}

mostrarUsuarios();
