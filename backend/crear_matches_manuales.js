const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://anderson:123456@localhost:5432/petmatch',
});

async function crearMatchesManuales() {
    try {
        console.log('💕 CREANDO MATCHES MANUALES PARA PRUEBAS...\n');
        
        // Obtener mascotas disponibles
        const mascotasQuery = `
            SELECT m.id, m.nombre, m.id_usuario, u.nombres, u.apellidos
            FROM mascotas m
            JOIN usuarios u ON m.id_usuario = u.id
            ORDER BY m.id
        `;
        
        const mascotasResult = await pool.query(mascotasQuery);
        
        console.log('🐕 Mascotas disponibles:');
        mascotasResult.rows.forEach(mascota => {
            console.log(`  ID: ${mascota.id} - ${mascota.nombre} (Dueño: ${mascota.nombres} ${mascota.apellidos}, ID: ${mascota.id_usuario})`);
        });
        
        if (mascotasResult.rows.length >= 4) {
            const mascotas = mascotasResult.rows;
            
            // Crear matches específicos que funcionen
            const matchesParaCrear = [
                {
                    user1_id: mascotas[0].id_usuario, // Usuario de Max
                    user2_id: mascotas[1].id_usuario, // Usuario de Luna
                    pet1_id: mascotas[0].id, // Max
                    pet2_id: mascotas[1].id, // Luna
                    pet1_nombre: mascotas[0].nombre,
                    pet2_nombre: mascotas[1].nombre
                },
                {
                    user1_id: mascotas[2].id_usuario, // Usuario de Milo
                    user2_id: mascotas[3].id_usuario, // Usuario de Bella
                    pet1_id: mascotas[2].id, // Milo
                    pet2_id: mascotas[3].id, // Bella
                    pet1_nombre: mascotas[2].nombre,
                    pet2_nombre: mascotas[3].nombre
                }
            ];
            
            if (mascotas.length >= 6) {
                matchesParaCrear.push({
                    user1_id: mascotas[4].id_usuario, // Usuario de Rocky
                    user2_id: mascotas[5].id_usuario, // Usuario de Coco
                    pet1_id: mascotas[4].id, // Rocky
                    pet2_id: mascotas[5].id, // Coco
                    pet1_nombre: mascotas[4].nombre,
                    pet2_nombre: mascotas[5].nombre
                });
            }
            
            let matchesCreados = 0;
            
            for (const match of matchesParaCrear) {
                // Solo crear matches entre usuarios diferentes
                if (match.user1_id !== match.user2_id) {
                    try {
                        // Primero crear los likes necesarios para que el match sea válido
                        console.log(`\n👍 Creando likes para el match ${match.pet1_nombre} ↔ ${match.pet2_nombre}:`);
                        
                        // Usuario 1 likes mascota de usuario 2
                        await pool.query(`
                            INSERT INTO pet_likes (usuario_id, mascota_id, is_like)
                            VALUES ($1, $2, true)
                            ON CONFLICT (usuario_id, mascota_id) DO UPDATE SET is_like = true
                        `, [match.user1_id, match.pet2_id]);
                        
                        console.log(`  Usuario ${match.user1_id} → LIKE → ${match.pet2_nombre} (ID: ${match.pet2_id})`);
                        
                        // Usuario 2 likes mascota de usuario 1
                        await pool.query(`
                            INSERT INTO pet_likes (usuario_id, mascota_id, is_like)
                            VALUES ($1, $2, true)
                            ON CONFLICT (usuario_id, mascota_id) DO UPDATE SET is_like = true
                        `, [match.user2_id, match.pet1_id]);
                        
                        console.log(`  Usuario ${match.user2_id} → LIKE → ${match.pet1_nombre} (ID: ${match.pet1_id})`);
                        
                        // Ahora crear el match
                        const matchQuery = `
                            INSERT INTO mutual_matches (user1_id, user2_id, pet1_id, pet2_id, fecha_match, activo)
                            VALUES ($1, $2, $3, $4, NOW(), true)
                            ON CONFLICT DO NOTHING
                            RETURNING *
                        `;
                        
                        const matchResult = await pool.query(matchQuery, [
                            match.user1_id,
                            match.user2_id,
                            match.pet1_id,
                            match.pet2_id
                        ]);
                        
                        if (matchResult.rows.length > 0) {
                            matchesCreados++;
                            console.log(`💝 MATCH CREADO: ID ${matchResult.rows[0].id} - ${match.pet1_nombre} ↔ ${match.pet2_nombre}`);
                            
                            // Crear notificaciones
                            const notificaciones = [
                                {
                                    usuario_id: match.user1_id,
                                    tipo: 'match',
                                    titulo: '¡Nuevo Match! 🎉',
                                    mensaje: `Tu mascota ${match.pet1_nombre} hizo match con ${match.pet2_nombre}`,
                                    match_id: matchResult.rows[0].id
                                },
                                {
                                    usuario_id: match.user2_id,
                                    tipo: 'match',
                                    titulo: '¡Nuevo Match! 🎉',
                                    mensaje: `Tu mascota ${match.pet2_nombre} hizo match con ${match.pet1_nombre}`,
                                    match_id: matchResult.rows[0].id
                                }
                            ];
                            
                            for (const notif of notificaciones) {
                                await pool.query(`
                                    INSERT INTO notificaciones (usuario_id, tipo, titulo, mensaje, match_id)
                                    VALUES ($1, $2, $3, $4, $5)
                                `, [
                                    notif.usuario_id,
                                    notif.tipo,
                                    notif.titulo,
                                    notif.mensaje,
                                    notif.match_id
                                ]);
                            }
                            
                            console.log(`📧 Notificaciones creadas para ambos usuarios`);
                        } else {
                            console.log(`⚠️ El match ya existía`);
                        }
                        
                    } catch (error) {
                        console.log(`❌ Error creando match: ${error.message}`);
                    }
                }
            }
            
            // Verificar estado final
            console.log('\n' + '='.repeat(50));
            console.log('📊 === ESTADO FINAL ===');
            
            const totalMatches = await pool.query('SELECT COUNT(*) FROM mutual_matches WHERE activo = true');
            const totalNotificaciones = await pool.query('SELECT COUNT(*) FROM notificaciones WHERE tipo = \'match\'');
            const totalLikes = await pool.query('SELECT COUNT(*) FROM pet_likes WHERE is_like = true');
            
            console.log(`💕 Matches activos: ${totalMatches.rows[0].count}`);
            console.log(`📧 Notificaciones de match: ${totalNotificaciones.rows[0].count}`);
            console.log(`👍 Total de likes: ${totalLikes.rows[0].count}`);
            
            // Mostrar los matches creados
            const matchesQuery = `
                SELECT 
                    mm.id,
                    mm.user1_id,
                    mm.user2_id,
                    m1.nombre as pet1_nombre,
                    m2.nombre as pet2_nombre,
                    u1.nombres as user1_nombre,
                    u2.nombres as user2_nombre
                FROM mutual_matches mm
                JOIN mascotas m1 ON mm.pet1_id = m1.id
                JOIN mascotas m2 ON mm.pet2_id = m2.id
                JOIN usuarios u1 ON mm.user1_id = u1.id
                JOIN usuarios u2 ON mm.user2_id = u2.id
                WHERE mm.activo = true
            `;
            
            const matchesResult = await pool.query(matchesQuery);
            
            if (matchesResult.rows.length > 0) {
                console.log('\n💝 MATCHES ACTIVOS:');
                matchesResult.rows.forEach(match => {
                    console.log(`  ID: ${match.id} - ${match.user1_nombre} (${match.pet1_nombre}) ↔ ${match.user2_nombre} (${match.pet2_nombre})`);
                });
            }
            
            console.log('\n🎉 ¡SISTEMA DE MATCHES LISTO PARA PROBAR!');
            console.log('✅ Ahora puedes abrir tu app Flutter y probar:');
            console.log('   1. Navegar a la pantalla de Matches');
            console.log('   2. Ver las notificaciones de matches');
            console.log('   3. Hacer swipe en nuevas mascotas para crear más matches');
            
        } else {
            console.log('❌ No hay suficientes mascotas para crear matches');
        }
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error('Stack:', error.stack);
    } finally {
        await pool.end();
    }
}

crearMatchesManuales();
