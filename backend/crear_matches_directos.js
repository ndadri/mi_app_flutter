const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://Alexis:123@localhost:5432/petmatch',
});

async function crearMatchesPrueba() {
    try {
        console.log('🎯 Creando matches de prueba directamente...');
        
        // Obtener algunas mascotas existentes
        const mascotasQuery = `
            SELECT m.id, m.nombre, m.id_duenio, u.nombre as duenio_nombre
            FROM mascotas m
            JOIN usuarios u ON m.id_duenio = u.id
            LIMIT 4
        `;
        
        const mascotasResult = await pool.query(mascotasQuery);
        console.log('📋 Mascotas encontradas:');
        mascotasResult.rows.forEach((mascota, index) => {
            console.log(`${index + 1}. ${mascota.nombre} (ID: ${mascota.id}) - Dueño: ${mascota.duenio_nombre} (ID: ${mascota.id_duenio})`);
        });
        
        if (mascotasResult.rows.length >= 2) {
            const mascotas = mascotasResult.rows;
            
            // Crear matches entre usuarios diferentes
            const matches = [
                {
                    user1_id: mascotas[0].id_duenio,
                    user2_id: mascotas[1].id_duenio,
                    pet1_id: mascotas[0].id,
                    pet2_id: mascotas[1].id
                }
            ];
            
            if (mascotas.length >= 4) {
                matches.push({
                    user1_id: mascotas[2].id_duenio,
                    user2_id: mascotas[3].id_duenio,
                    pet1_id: mascotas[2].id,
                    pet2_id: mascotas[3].id
                });
            }
            
            for (const match of matches) {
                if (match.user1_id !== match.user2_id) { // Asegurarse de que no sean el mismo usuario
                    try {
                        const insertQuery = `
                            INSERT INTO mutual_matches (user1_id, user2_id, pet1_id, pet2_id, fecha_match, activo)
                            VALUES ($1, $2, $3, $4, NOW(), true)
                            ON CONFLICT DO NOTHING
                            RETURNING *
                        `;
                        
                        const result = await pool.query(insertQuery, [
                            match.user1_id,
                            match.user2_id,
                            match.pet1_id,
                            match.pet2_id
                        ]);
                        
                        if (result.rows.length > 0) {
                            console.log(`✅ Match creado: Usuario ${match.user1_id} ↔ Usuario ${match.user2_id} (ID: ${result.rows[0].id})`);
                            
                            // Crear notificaciones para ambos usuarios
                            const mascota1 = mascotas.find(m => m.id === match.pet1_id);
                            const mascota2 = mascotas.find(m => m.id === match.pet2_id);
                            
                            const notificaciones = [
                                {
                                    usuario_id: match.user1_id,
                                    tipo: 'match',
                                    titulo: '¡Nuevo Match! 🎉',
                                    mensaje: `Tu mascota ${mascota1.nombre} hizo match con ${mascota2.nombre}`,
                                    match_id: result.rows[0].id
                                },
                                {
                                    usuario_id: match.user2_id,
                                    tipo: 'match',
                                    titulo: '¡Nuevo Match! 🎉',
                                    mensaje: `Tu mascota ${mascota2.nombre} hizo match con ${mascota1.nombre}`,
                                    match_id: result.rows[0].id
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
                            
                            console.log(`📧 Notificaciones creadas para el match`);
                        }
                        
                    } catch (error) {
                        console.log(`❌ Error creando match: ${error.message}`);
                    }
                }
            }
        }
        
        // Verificar matches totales
        const totalQuery = `SELECT COUNT(*) FROM mutual_matches WHERE activo = true`;
        const totalResult = await pool.query(totalQuery);
        console.log(`\n📊 Total de matches activos: ${totalResult.rows[0].count}`);
        
        // Verificar notificaciones
        const notifQuery = `SELECT COUNT(*) FROM notificaciones WHERE tipo = 'match'`;
        const notifResult = await pool.query(notifQuery);
        console.log(`📧 Total de notificaciones de match: ${notifResult.rows[0].count}`);
        
        console.log('\n🎉 Matches de prueba creados correctamente');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

crearMatchesPrueba();
