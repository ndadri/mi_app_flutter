const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://Alexis:123@localhost:5432/petmatch',
});

async function crearDatosPrueba() {
    try {
        console.log('🎯 Creando datos de prueba para matches...');
        
        // Crear algunas mascotas de prueba
        const mascotas = [
            {
                nombre: 'Luna',
                edad: 3,
                tipo_animal: 'perro',
                raza: 'Golden Retriever',
                foto_url: 'https://images.pexels.com/photos/4587996/pexels-photo-4587996.jpeg',
                id_duenio: 3
            },
            {
                nombre: 'Max',
                edad: 2,
                tipo_animal: 'perro',
                raza: 'Labrador',
                foto_url: 'https://images.pexels.com/photos/4588000/pexels-photo-4588000.jpeg',
                id_duenio: 4
            },
            {
                nombre: 'Chispa',
                edad: 1,
                tipo_animal: 'gato',
                raza: 'Siamés',
                foto_url: 'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg',
                id_duenio: 6
            },
            {
                nombre: 'Bella',
                edad: 4,
                tipo_animal: 'perro',
                raza: 'Bulldog',
                foto_url: 'https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg',
                id_duenio: 2
            }
        ];
        
        const mascotasIds = [];
        
        for (const mascota of mascotas) {
            try {
                const query = `
                    INSERT INTO mascotas (nombre, edad, tipo_animal, raza, foto_url, id_duenio)
                    VALUES ($1, $2, $3, $4, $5, $6)
                    ON CONFLICT (nombre, id_duenio) DO UPDATE SET
                        foto_url = $5
                    RETURNING id, nombre, id_duenio
                `;
                
                const result = await pool.query(query, [
                    mascota.nombre,
                    mascota.edad,
                    mascota.tipo_animal,
                    mascota.raza,
                    mascota.foto_url,
                    mascota.id_duenio
                ]);
                
                mascotasIds.push({
                    id: result.rows[0].id,
                    nombre: result.rows[0].nombre,
                    duenio: result.rows[0].id_duenio
                });
                
                console.log(`✅ Mascota creada: ${result.rows[0].nombre} (ID: ${result.rows[0].id}, Dueño: ${result.rows[0].id_duenio})`);
                
            } catch (error) {
                console.log(`ℹ️  Mascota ya existe: ${mascota.nombre}`);
            }
        }
        
        // Crear likes cruzados para generar matches
        console.log('\n🎯 Creando likes para generar matches...');
        
        if (mascotasIds.length >= 2) {
            // Usuario 2 le da like a mascota de usuario 3
            // Usuario 3 le da like a mascota de usuario 2
            const likes = [
                { usuario_id: 2, mascota_id: mascotasIds.find(m => m.duenio === 3)?.id, is_like: true },
                { usuario_id: 3, mascota_id: mascotasIds.find(m => m.duenio === 2)?.id, is_like: true },
                { usuario_id: 4, mascota_id: mascotasIds.find(m => m.duenio === 6)?.id, is_like: true },
                { usuario_id: 6, mascota_id: mascotasIds.find(m => m.duenio === 4)?.id, is_like: true },
            ];
            
            for (const like of likes) {
                if (like.mascota_id) {
                    try {
                        const query = `
                            INSERT INTO pet_likes (usuario_id, mascota_id, is_like)
                            VALUES ($1, $2, $3)
                            ON CONFLICT (usuario_id, mascota_id) 
                            DO UPDATE SET is_like = $3
                        `;
                        
                        await pool.query(query, [like.usuario_id, like.mascota_id, like.is_like]);
                        console.log(`✅ Like creado: Usuario ${like.usuario_id} → Mascota ${like.mascota_id}`);
                        
                    } catch (error) {
                        console.log(`❌ Error creando like: ${error.message}`);
                    }
                }
            }
        }
        
        // Verificar matches generados
        console.log('\n📊 Verificando mutual_matches...');
        const matchesQuery = `
            SELECT * FROM mutual_matches ORDER BY fecha_match DESC LIMIT 5
        `;
        
        const matchesResult = await pool.query(matchesQuery);
        console.log(`📋 Matches encontrados: ${matchesResult.rows.length}`);
        
        matchesResult.rows.forEach((match, index) => {
            console.log(`${index + 1}. Match ID: ${match.id} - Usuario ${match.user1_id} ↔ Usuario ${match.user2_id}`);
        });
        
        console.log('\n🎉 Datos de prueba creados correctamente');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

crearDatosPrueba();
