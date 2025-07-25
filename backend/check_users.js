const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function checkUsers() {
    try {
        console.log('🔍 Verificando usuarios en la base de datos...');
        
        const result = await pool.query(`
            SELECT id, nombres, apellidos, correo, genero, ubicacion 
            FROM usuarios 
            ORDER BY id
        `);
        
        console.log(`📊 Total de usuarios encontrados: ${result.rows.length}`);
        console.log('👥 Lista de usuarios:');
        
        result.rows.forEach(user => {
            console.log(`   🆔 ID: ${user.id}`);
            console.log(`   👤 Nombre: ${user.nombres} ${user.apellidos}`);
            console.log(`   📧 Email: ${user.correo}`);
            console.log(`   🚻 Género: ${user.genero || 'No especificado'}`);
            console.log(`   📍 Ubicación: ${user.ubicacion || 'No especificada'}`);
            console.log('   ─────────────────────────────');
        });
        
        // Probar la ruta de búsqueda por ID
        console.log('🧪 Probando búsqueda por ID...');
        for (let i = 0; i < Math.min(3, result.rows.length); i++) {
            const userId = result.rows[i].id;
            const testResult = await pool.query(
                'SELECT id, nombres, apellidos FROM usuarios WHERE id = $1',
                [userId]
            );
            
            if (testResult.rows.length > 0) {
                console.log(`✅ ID ${userId} encontrado: ${testResult.rows[0].nombres} ${testResult.rows[0].apellidos}`);
            } else {
                console.log(`❌ ID ${userId} NO encontrado`);
            }
        }
        
    } catch (err) {
        console.error('❌ Error al verificar usuarios:', err.message);
    } finally {
        await pool.end();
    }
}

checkUsers();
