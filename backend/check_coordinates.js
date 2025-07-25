const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});

async function checkCoordinates() {
    console.log('🌍 VERIFICANDO COORDENADAS DE USUARIOS');
    console.log('====================================');
    
    try {
        // Verificar coordenadas de usuarios
        const users = await pool.query(`
            SELECT id, nombres, apellidos, correo, latitud, longitud, ubicacion
            FROM usuarios 
            ORDER BY id
        `);
        
        console.log('📍 COORDENADAS DE USUARIOS:');
        console.log('---------------------------');
        
        users.rows.forEach(user => {
            const lat = user.latitud;
            const lng = user.longitud;
            const ubicacion = user.ubicacion || 'No especificada';
            
            console.log(`👤 ${user.nombres} ${user.apellidos} (${user.correo})`);
            console.log(`   ID: ${user.id}`);
            console.log(`   Latitud: ${lat || 'No especificada'}`);
            console.log(`   Longitud: ${lng || 'No especificada'}`);
            console.log(`   Ubicación: ${ubicacion}`);
            
            if (lat && lng) {
                console.log(`   📍 Coordenadas válidas: ✅`);
            } else {
                console.log(`   📍 Coordenadas válidas: ❌`);
            }
            console.log('');
        });
        
        // Verificar mascotas y coordenadas de sus dueños
        const pets = await pool.query(`
            SELECT p.id, p.nombre, p.tipo_animal, p.edad, p.estado, p.ciudad,
                   u.nombres as owner_nombres, u.apellidos as owner_apellidos,
                   u.latitud as owner_lat, u.longitud as owner_lng
            FROM mascotas p
            JOIN usuarios u ON p.id_usuario = u.id
            ORDER BY p.id
        `);
        
        console.log('🐾 MASCOTAS Y COORDENADAS DE SUS DUEÑOS:');
        console.log('---------------------------------------');
        
        pets.rows.forEach(pet => {
            console.log(`🐕 ${pet.nombre} (${pet.tipo_animal}, ${pet.edad} años)`);
            console.log(`   Estado: ${pet.estado || 'No especificado'}`);
            console.log(`   Ciudad: ${pet.ciudad || 'No especificada'}`);
            console.log(`   Dueño: ${pet.owner_nombres} ${pet.owner_apellidos}`);
            console.log(`   Coordenadas del dueño: ${pet.owner_lat || 'No'}, ${pet.owner_lng || 'No'}`);
            
            if (pet.owner_lat && pet.owner_lng) {
                console.log(`   📍 Coordenadas válidas: ✅`);
            } else {
                console.log(`   📍 Coordenadas válidas: ❌ (No aparecerá en matching)`);
            }
            console.log('');
        });
        
        // Estadísticas
        const usersWithCoords = users.rows.filter(u => u.latitud && u.longitud).length;
        const totalUsers = users.rows.length;
        const petsWithValidCoords = pets.rows.filter(p => p.owner_lat && p.owner_lng).length;
        const totalPets = pets.rows.length;
        
        console.log('📊 ESTADÍSTICAS:');
        console.log('---------------');
        console.log(`👥 Usuarios con coordenadas válidas: ${usersWithCoords}/${totalUsers}`);
        console.log(`🐾 Mascotas con coordenadas válidas: ${petsWithValidCoords}/${totalPets}`);
        console.log('');
        
        if (usersWithCoords === 0) {
            console.log('⚠️  ADVERTENCIA: Ningún usuario tiene coordenadas válidas');
            console.log('   El sistema de matching no funcionará correctamente');
        }
        
        if (petsWithValidCoords === 0) {
            console.log('⚠️  ADVERTENCIA: Ninguna mascota tiene coordenadas válidas');
            console.log('   No aparecerán mascotas en el matching');
        }
        
        console.log('💡 NOTAS:');
        console.log('- Las coordenadas se obtienen durante el registro');
        console.log('- Sin coordenadas, el sistema usa distancia por defecto');
        console.log('- Coordenadas son necesarias para matching por proximidad');
        
    } catch (error) {
        console.error('❌ ERROR:', error);
    } finally {
        await pool.end();
    }
}

checkCoordinates();
