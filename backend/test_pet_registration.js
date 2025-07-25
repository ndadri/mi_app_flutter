const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});

async function testPetRegistration() {
    console.log('🧪 PROBANDO REGISTRO DE MASCOTAS');
    console.log('================================');
    
    try {
        // Verificar usuarios existentes
        const users = await pool.query('SELECT id, nombres, apellidos FROM usuarios');
        console.log('👥 Usuarios disponibles:');
        users.rows.forEach(user => {
            console.log(`   - ID: ${user.id}, Nombre: ${user.nombres} ${user.apellidos}`);
        });
        
        if (users.rows.length === 0) {
            console.log('❌ No hay usuarios para probar');
            return;
        }
        
        // Usar el primer usuario para la prueba
        const testUserId = users.rows[0].id;
        console.log(`\n🐕 Probando registro con usuario ID: ${testUserId}`);
        
        // Intentar registrar una mascota de prueba
        const testPet = {
            nombre: 'Firulais',
            edad: 3,
            tipo_animal: 'Perro',
            sexo: 'Macho',
            ciudad: 'Quito',
            foto_url: '/uploads/test.jpg',
            estado: 'Soltero',
            id_usuario: testUserId
        };
        
        console.log('📝 Datos de prueba:', testPet);
        
        const result = await pool.query(
            `INSERT INTO mascotas (nombre, edad, tipo_animal, sexo, ciudad, foto_url, estado, id_usuario)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
             RETURNING *`,
            [testPet.nombre, testPet.edad, testPet.tipo_animal, testPet.sexo, testPet.ciudad, testPet.foto_url, testPet.estado, testPet.id_usuario]
        );
        
        console.log('✅ Mascota registrada exitosamente:');
        console.log('   ID:', result.rows[0].id);
        console.log('   Nombre:', result.rows[0].nombre);
        console.log('   Edad:', result.rows[0].edad);
        console.log('   Tipo:', result.rows[0].tipo_animal);
        console.log('   Sexo:', result.rows[0].sexo);
        console.log('   Ciudad:', result.rows[0].ciudad);
        console.log('   Estado:', result.rows[0].estado);
        console.log('   Dueño ID:', result.rows[0].id_usuario);
        
        // Limpiar - eliminar la mascota de prueba
        await pool.query('DELETE FROM mascotas WHERE id = $1', [result.rows[0].id]);
        console.log('🧹 Mascota de prueba eliminada');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error('🔍 Detalles del error:', error);
    } finally {
        await pool.end();
    }
}

testPetRegistration();
