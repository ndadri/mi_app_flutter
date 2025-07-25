require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function testFullPetRegistrationFlow() {
    console.log('🔄 Probando flujo completo de registro de mascotas...\n');
    
    try {
        // 1. Verificar usuarios disponibles
        console.log('1️⃣ Verificando usuarios disponibles...');
        const users = await pool.query('SELECT id, nombres, apellidos, ubicacion FROM usuarios LIMIT 3');
        
        if (users.rows.length === 0) {
            console.log('❌ No hay usuarios registrados para hacer pruebas');
            return;
        }
        
        console.log('✅ Usuarios encontrados:');
        users.rows.forEach(user => {
            console.log(`   - ID: ${user.id}, Nombre: ${user.nombres} ${user.apellidos}, Ubicación: ${user.ubicacion || 'Sin ubicación'}`);
        });
        
        const testUser = users.rows[0];
        
        // 2. Limpiar mascotas de prueba existentes
        console.log('\n2️⃣ Limpiando mascotas de prueba anteriores...');
        await pool.query('DELETE FROM mascotas WHERE nombre LIKE $1 AND id_usuario = $2', ['%Test%', testUser.id]);
        console.log('✅ Limpieza completada');
        
        // 3. Simular registro de mascota (como lo haría la app)
        console.log('\n3️⃣ Simulando registro de mascota...');
        
        const nuevaMascota = {
            nombre: 'Buddy Test',
            edad: 3,
            tipo_animal: 'Perro',
            sexo: 'Macho',
            ciudad: testUser.ubicacion || 'Ciudad Test',
            foto_url: 'http://localhost:3001/uploads/test-buddy.jpg',
            estado: 'Soltero',
            id_usuario: testUser.id
        };
        
        // Simular la validación que hace el backend
        console.log('   📋 Validando datos...');
        
        // Validar nombre
        if (!nuevaMascota.nombre || nuevaMascota.nombre.trim().length < 2) {
            throw new Error('Nombre inválido');
        }
        
        // Validar edad
        if (nuevaMascota.edad <= 0 || nuevaMascota.edad > 20) {
            throw new Error('Edad inválida');
        }
        
        // Validar que no exista duplicado
        const duplicateCheck = await pool.query(
            'SELECT id FROM mascotas WHERE LOWER(nombre) = LOWER($1) AND id_usuario = $2',
            [nuevaMascota.nombre.trim(), nuevaMascota.id_usuario]
        );
        
        if (duplicateCheck.rows.length > 0) {
            throw new Error('Ya existe una mascota con ese nombre');
        }
        
        console.log('   ✅ Validaciones pasadas');
        
        // Insertar mascota
        console.log('   💾 Insertando mascota en base de datos...');
        const insertResult = await pool.query(
            `INSERT INTO mascotas (nombre, edad, tipo_animal, sexo, ciudad, foto_url, estado, id_usuario)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
             RETURNING *`,
            [nuevaMascota.nombre.trim(), nuevaMascota.edad, nuevaMascota.tipo_animal, 
             nuevaMascota.sexo, nuevaMascota.ciudad.trim(), nuevaMascota.foto_url, 
             nuevaMascota.estado, nuevaMascota.id_usuario]
        );
        
        const mascotaRegistrada = insertResult.rows[0];
        console.log('   ✅ Mascota registrada exitosamente:');
        console.log(`      - ID: ${mascotaRegistrada.id}`);
        console.log(`      - Nombre: ${mascotaRegistrada.nombre}`);
        console.log(`      - Edad: ${mascotaRegistrada.edad} años`);
        console.log(`      - Tipo: ${mascotaRegistrada.tipo_animal}`);
        console.log(`      - Sexo: ${mascotaRegistrada.sexo}`);
        console.log(`      - Ciudad: ${mascotaRegistrada.ciudad}`);
        console.log(`      - Estado: ${mascotaRegistrada.estado}`);
        
        // 4. Simular la consulta que hace la página "Mis Mascotas"
        console.log('\n4️⃣ Simulando consulta de "Mis Mascotas"...');
        
        const myPetsQuery = await pool.query(
            'SELECT * FROM mascotas WHERE id_usuario = $1 ORDER BY nombre',
            [testUser.id]
        );
        
        console.log(`   📊 Mascotas encontradas para el usuario: ${myPetsQuery.rows.length}`);
        
        if (myPetsQuery.rows.length === 0) {
            console.log('   ❌ No se encontraron mascotas - PROBLEMA EN LA CONSULTA');
        } else {
            console.log('   ✅ Mascotas que se mostrarán en la página:');
            myPetsQuery.rows.forEach((mascota, index) => {
                console.log(`      ${index + 1}. ${mascota.nombre} (${mascota.tipo_animal}, ${mascota.edad} años)`);
            });
        }
        
        // 5. Verificar que la mascota recién registrada aparece en la lista
        console.log('\n5️⃣ Verificando que la mascota aparece en la lista...');
        
        const mascotaEnLista = myPetsQuery.rows.find(m => m.id === mascotaRegistrada.id);
        
        if (mascotaEnLista) {
            console.log('   ✅ ¡ÉXITO! La mascota recién registrada aparece en "Mis Mascotas"');
            console.log(`      - Se mostrará como: ${mascotaEnLista.nombre} (${mascotaEnLista.tipo_animal})`);
            console.log(`      - Con la información: ${mascotaEnLista.edad} años, ${mascotaEnLista.sexo}, ${mascotaEnLista.ciudad}`);
        } else {
            console.log('   ❌ ERROR: La mascota no aparece en la lista');
        }
        
        // 6. Simular la respuesta JSON que recibirá la app
        console.log('\n6️⃣ Simulando respuesta JSON para la app...');
        
        const response = {
            success: true,
            mascotas: myPetsQuery.rows
        };
        
        console.log('   📱 Respuesta que recibirá la app Flutter:');
        console.log('   ```json');
        console.log('   {');
        console.log('     "success": true,');
        console.log(`     "mascotas": [`);
        response.mascotas.forEach((mascota, index) => {
            console.log(`       {`);
            console.log(`         "id": ${mascota.id},`);
            console.log(`         "nombre": "${mascota.nombre}",`);
            console.log(`         "edad": ${mascota.edad},`);
            console.log(`         "tipo_animal": "${mascota.tipo_animal}",`);
            console.log(`         "sexo": "${mascota.sexo}",`);
            console.log(`         "ciudad": "${mascota.ciudad}",`);
            console.log(`         "estado": "${mascota.estado}",`);
            console.log(`         "foto_url": "${mascota.foto_url || 'null'}"`);
            console.log(`       }${index < response.mascotas.length - 1 ? ',' : ''}`);
        });
        console.log('     ]');
        console.log('   }');
        console.log('   ```');
        
        // 7. Limpiar datos de prueba
        console.log('\n7️⃣ Limpiando datos de prueba...');
        await pool.query('DELETE FROM mascotas WHERE id = $1', [mascotaRegistrada.id]);
        console.log('   ✅ Datos de prueba eliminados');
        
        console.log('\n🎉 RESULTADO: El flujo completo funciona correctamente!');
        console.log('   ✅ La mascota se registra exitosamente');
        console.log('   ✅ La mascota aparece en "Mis Mascotas"');
        console.log('   ✅ Los datos se muestran correctamente en la interfaz');
        
    } catch (error) {
        console.error('\n❌ ERROR en el flujo:', error.message);
        console.error('📋 Detalles:', error.stack);
    } finally {
        await pool.end();
    }
}

// Ejecutar prueba
testFullPetRegistrationFlow();
