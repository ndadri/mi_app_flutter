const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://anderson:123456@localhost:5432/petmatch',
});

async function crearDatosCompletos() {
    try {
        console.log('🎯 CREANDO DATOS COMPLETOS PARA EL SISTEMA DE MATCHES...\n');
        
        // 1. Verificar usuarios existentes
        console.log('👥 === VERIFICANDO USUARIOS EXISTENTES ===');
        const usuariosQuery = `SELECT id, nombres, apellidos, correo FROM usuarios ORDER BY id`;
        const usuariosResult = await pool.query(usuariosQuery);
        
        console.log('Usuarios encontrados:');
        usuariosResult.rows.forEach((user, index) => {
            console.log(`${index + 1}. ID: ${user.id} - ${user.nombres} ${user.apellidos} (${user.correo})`);
        });
        
        if (usuariosResult.rows.length < 2) {
            console.log('❌ Se necesitan al menos 2 usuarios para crear matches');
            return;
        }
        
        // 2. Crear mascotas para los usuarios
        console.log('\n🐕 === CREANDO MASCOTAS ===');
        
        const mascotas = [
            {
                nombre: 'Max',
                edad: 3,
                tipo_animal: 'Perro',
                sexo: 'Macho',
                ciudad: 'Quito',
                estado: 'Activo',
                id_usuario: usuariosResult.rows[0].id,
                foto_url: 'https://example.com/max.jpg'
            },
            {
                nombre: 'Luna',
                edad: 2,
                tipo_animal: 'Perro',
                sexo: 'Hembra',
                ciudad: 'Quito',
                estado: 'Activo',
                id_usuario: usuariosResult.rows[1].id,
                foto_url: 'https://example.com/luna.jpg'
            },
            {
                nombre: 'Milo',
                edad: 4,
                tipo_animal: 'Gato',
                sexo: 'Macho',
                ciudad: 'Guayaquil',
                estado: 'Activo',
                id_usuario: usuariosResult.rows[0].id,
                foto_url: 'https://example.com/milo.jpg'
            },
            {
                nombre: 'Bella',
                edad: 1,
                tipo_animal: 'Gato',
                sexo: 'Hembra',
                ciudad: 'Cuenca',
                estado: 'Activo',
                id_usuario: usuariosResult.rows[1].id,
                foto_url: 'https://example.com/bella.jpg'
            }
        ];
        
        // Si hay más usuarios, agregar más mascotas
        if (usuariosResult.rows.length >= 3) {
            mascotas.push({
                nombre: 'Rocky',
                edad: 5,
                tipo_animal: 'Perro',
                sexo: 'Macho',
                ciudad: 'Quito',
                estado: 'Activo',
                id_usuario: usuariosResult.rows[2].id,
                foto_url: 'https://example.com/rocky.jpg'
            });
        }
        
        if (usuariosResult.rows.length >= 4) {
            mascotas.push({
                nombre: 'Coco',
                edad: 3,
                tipo_animal: 'Perro',
                sexo: 'Hembra',
                ciudad: 'Quito',
                estado: 'Activo',
                id_usuario: usuariosResult.rows[3].id,
                foto_url: 'https://example.com/coco.jpg'
            });
        }
        
        const mascotasCreadas = [];
        
        for (const mascota of mascotas) {
            try {
                const insertQuery = `
                    INSERT INTO mascotas (nombre, edad, tipo_animal, sexo, ciudad, estado, id_usuario, foto_url)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                    RETURNING *
                `;
                
                const result = await pool.query(insertQuery, [
                    mascota.nombre,
                    mascota.edad,
                    mascota.tipo_animal,
                    mascota.sexo,
                    mascota.ciudad,
                    mascota.estado,
                    mascota.id_usuario,
                    mascota.foto_url
                ]);
                
                mascotasCreadas.push(result.rows[0]);
                console.log(`✅ Mascota creada: ${result.rows[0].nombre} (ID: ${result.rows[0].id}) - Dueño: ${mascota.id_usuario}`);
                
            } catch (error) {
                console.log(`❌ Error creando mascota ${mascota.nombre}: ${error.message}`);
            }
        }
        
        console.log(`\n📊 Total de mascotas creadas: ${mascotasCreadas.length}`);
        
        // 3. Crear likes entre usuarios y mascotas
        console.log('\n👍 === CREANDO LIKES ===');
        
        const likesCreados = [];
        
        // Crear likes que generen matches
        for (let i = 0; i < mascotasCreadas.length; i++) {
            for (let j = 0; j < mascotasCreadas.length; j++) {
                const mascotaActual = mascotasCreadas[i];
                const mascotaObjetivo = mascotasCreadas[j];
                
                // No hacer like a sus propias mascotas
                if (mascotaActual.id_usuario !== mascotaObjetivo.id_usuario) {
                    // Crear like del dueño de mascotaActual hacia mascotaObjetivo
                    try {
                        const likeQuery = `
                            INSERT INTO pet_likes (usuario_id, mascota_id, is_like)
                            VALUES ($1, $2, $3)
                            ON CONFLICT DO NOTHING
                            RETURNING *
                        `;
                        
                        const isLike = Math.random() > 0.3; // 70% probabilidad de like
                        
                        const result = await pool.query(likeQuery, [
                            mascotaActual.id_usuario,
                            mascotaObjetivo.id,
                            isLike
                        ]);
                        
                        if (result.rows.length > 0) {
                            likesCreados.push(result.rows[0]);
                            console.log(`${isLike ? '👍' : '👎'} Usuario ${mascotaActual.id_usuario} ${isLike ? 'LIKE' : 'DISLIKE'} a mascota ${mascotaObjetivo.nombre} (ID: ${mascotaObjetivo.id})`);
                        }
                        
                    } catch (error) {
                        // Ignorar duplicados
                    }
                }
            }
        }
        
        console.log(`\n📊 Total de likes/dislikes creados: ${likesCreados.length}`);
        
        // 4. Detectar y crear matches mutuos
        console.log('\n💕 === DETECTANDO Y CREANDO MATCHES MUTUOS ===');
        
        const matchesCreados = [];
        
        // Buscar likes mutuos para crear matches
        const mutualLikesQuery = `
            SELECT 
                l1.usuario_id as user1_id,
                l1.mascota_id as pet2_id,
                l2.usuario_id as user2_id,
                l2.mascota_id as pet1_id,
                m1.nombre as pet1_nombre,
                m2.nombre as pet2_nombre
            FROM pet_likes l1
            JOIN pet_likes l2 ON l1.usuario_id = l2.mascota_id AND l1.mascota_id = l2.usuario_id
            JOIN mascotas m1 ON l2.mascota_id = m1.id
            JOIN mascotas m2 ON l1.mascota_id = m2.id
            WHERE l1.is_like = true AND l2.is_like = true
            AND l1.usuario_id < l2.usuario_id
        `;
        
        const mutualLikesResult = await pool.query(mutualLikesQuery);
        
        console.log(`🔍 Se encontraron ${mutualLikesResult.rows.length} likes mutuos potenciales`);
        
        for (const mutualLike of mutualLikesResult.rows) {
            try {
                // Verificar que realmente hay match entre las mascotas correctas
                const verificarQuery = `
                    SELECT 1 FROM pet_likes l1
                    JOIN pet_likes l2 ON l1.usuario_id != l2.usuario_id
                    WHERE l1.usuario_id = $1 AND l1.mascota_id = $2 AND l1.is_like = true
                    AND l2.usuario_id = $3 AND l2.mascota_id = $4 AND l2.is_like = true
                `;
                
                const verificar = await pool.query(verificarQuery, [
                    mutualLike.user1_id,
                    mutualLike.pet2_id,
                    mutualLike.user2_id,
                    mutualLike.pet1_id
                ]);
                
                if (verificar.rows.length > 0) {
                    const matchQuery = `
                        INSERT INTO mutual_matches (user1_id, user2_id, pet1_id, pet2_id, fecha_match, activo)
                        VALUES ($1, $2, $3, $4, NOW(), true)
                        ON CONFLICT DO NOTHING
                        RETURNING *
                    `;
                    
                    const matchResult = await pool.query(matchQuery, [
                        mutualLike.user1_id,
                        mutualLike.user2_id,
                        mutualLike.pet1_id,
                        mutualLike.pet2_id
                    ]);
                    
                    if (matchResult.rows.length > 0) {
                        matchesCreados.push(matchResult.rows[0]);
                        console.log(`💝 MATCH CREADO: Usuario ${mutualLike.user1_id} (${mutualLike.pet1_nombre}) ↔ Usuario ${mutualLike.user2_id} (${mutualLike.pet2_nombre})`);
                        
                        // Crear notificaciones para ambos usuarios
                        const notificaciones = [
                            {
                                usuario_id: mutualLike.user1_id,
                                tipo: 'match',
                                titulo: '¡Nuevo Match! 🎉',
                                mensaje: `Tu mascota ${mutualLike.pet1_nombre} hizo match con ${mutualLike.pet2_nombre}`,
                                match_id: matchResult.rows[0].id
                            },
                            {
                                usuario_id: mutualLike.user2_id,
                                tipo: 'match',
                                titulo: '¡Nuevo Match! 🎉',
                                mensaje: `Tu mascota ${mutualLike.pet2_nombre} hizo match con ${mutualLike.pet1_nombre}`,
                                match_id: matchResult.rows[0].id
                            }
                        ];
                        
                        for (const notif of notificaciones) {
                            const notifQuery = `
                                INSERT INTO notificaciones (usuario_id, tipo, titulo, mensaje, match_id)
                                VALUES ($1, $2, $3, $4, $5)
                            `;
                            
                            await pool.query(notifQuery, [
                                notif.usuario_id,
                                notif.tipo,
                                notif.titulo,
                                notif.mensaje,
                                notif.match_id
                            ]);
                        }
                        
                        console.log(`📧 Notificaciones creadas para el match ID: ${matchResult.rows[0].id}`);
                    }
                }
                
            } catch (error) {
                console.log(`❌ Error creando match: ${error.message}`);
            }
        }
        
        // 5. Resumen final
        console.log('\n' + '='.repeat(60));
        console.log('📊 === RESUMEN FINAL ===');
        
        // Contar totales
        const totalMascotas = await pool.query('SELECT COUNT(*) FROM mascotas');
        const totalLikes = await pool.query('SELECT COUNT(*) FROM pet_likes');
        const totalMatches = await pool.query('SELECT COUNT(*) FROM mutual_matches WHERE activo = true');
        const totalNotificaciones = await pool.query('SELECT COUNT(*) FROM notificaciones');
        
        console.log(`👥 Usuarios: ${usuariosResult.rows.length}`);
        console.log(`🐕 Mascotas: ${totalMascotas.rows[0].count}`);
        console.log(`👍 Likes/Dislikes: ${totalLikes.rows[0].count}`);
        console.log(`💕 Matches activos: ${totalMatches.rows[0].count}`);
        console.log(`🔔 Notificaciones: ${totalNotificaciones.rows[0].count}`);
        
        console.log('\n🎉 ¡DATOS COMPLETOS PARA EL SISTEMA DE MATCHES CREADOS EXITOSAMENTE!');
        console.log('✅ Ahora puedes probar el sistema de matches en tu app Flutter');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error('Stack:', error.stack);
    } finally {
        await pool.end();
    }
}

crearDatosCompletos();
