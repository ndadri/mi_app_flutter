const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

// Configuración de base de datos
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// POST - Dar like o dislike a una mascota
router.post('/like', async (req, res) => {
    try {
        const { usuario_id, mascota_id, is_like } = req.body;
        
        if (!usuario_id || !mascota_id || is_like === undefined) {
            return res.status(400).json({
                success: false,
                message: 'Faltan datos requeridos'
            });
        }
        
        // Insertar o actualizar el like
        const query = `
            INSERT INTO pet_likes (usuario_id, mascota_id, is_like)
            VALUES ($1, $2, $3)
            ON CONFLICT (usuario_id, mascota_id)
            DO UPDATE SET is_like = $3, fecha_creacion = NOW()
            RETURNING *
        `;
        
        const result = await pool.query(query, [usuario_id, mascota_id, is_like]);
        
        // Si es un like, verificar si hay match
        if (is_like) {
            const matchResult = await verificarMatch(usuario_id, mascota_id);
            if (matchResult.hayMatch) {
                // Crear notificaciones para ambos usuarios
                await crearNotificacionMatch(matchResult);
                
                return res.json({
                    success: true,
                    isMatch: true,
                    match: matchResult,
                    message: '¡Es un match! 🎉'
                });
            }
        }
        
        res.json({
            success: true,
            isMatch: false,
            message: is_like ? 'Like enviado' : 'Dislike registrado'
        });
        
    } catch (error) {
        console.error('Error en like:', error);
        res.status(500).json({
            success: false,
            message: 'Error al procesar like'
        });
    }
});

// GET - Obtener matches del usuario
router.get('/matches/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        
        const query = `
            SELECT DISTINCT
                m.id as match_id,
                CASE 
                    WHEN m.user1_id = $1 THEN m.user2_id 
                    ELSE m.user1_id 
                END as otro_usuario_id,
                CASE 
                    WHEN m.user1_id = $1 THEN m.pet2_id 
                    ELSE m.pet1_id 
                END as otra_mascota_id,
                CASE 
                    WHEN m.user1_id = $1 THEN u2.nombre 
                    ELSE u1.nombre 
                END as otro_usuario_nombre,
                CASE 
                    WHEN m.user1_id = $1 THEN mas2.nombre 
                    ELSE mas1.nombre 
                END as mascota_nombre,
                CASE 
                    WHEN m.user1_id = $1 THEN mas2.foto_url 
                    ELSE mas1.foto_url 
                END as mascota_foto,
                CASE 
                    WHEN m.user1_id = $1 THEN mas2.tipo_animal 
                    ELSE mas1.tipo_animal 
                END as mascota_tipo,
                CASE 
                    WHEN m.user1_id = $1 THEN mas2.edad 
                    ELSE mas1.edad 
                END as mascota_edad,
                m.fecha_match
            FROM mutual_matches m
            JOIN users u1 ON m.user1_id = u1.id
            JOIN users u2 ON m.user2_id = u2.id
            JOIN mascotas mas1 ON m.pet1_id = mas1.id
            JOIN mascotas mas2 ON m.pet2_id = mas2.id
            WHERE (m.user1_id = $1 OR m.user2_id = $1) 
            AND m.activo = true
            ORDER BY m.fecha_match DESC
        `;
        
        const result = await pool.query(query, [usuario_id]);
        
        res.json({
            success: true,
            matches: result.rows
        });
        
    } catch (error) {
        console.error('Error obteniendo matches:', error);
        res.status(500).json({
            success: false,
            message: 'Error al obtener matches'
        });
    }
});

// GET - Obtener notificaciones del usuario
router.get('/notificaciones/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        
        const query = `
            SELECT *
            FROM notificaciones
            WHERE usuario_id = $1
            ORDER BY fecha_creacion DESC
            LIMIT 20
        `;
        
        const result = await pool.query(query, [usuario_id]);
        
        res.json({
            success: true,
            notificaciones: result.rows
        });
        
    } catch (error) {
        console.error('Error obteniendo notificaciones:', error);
        res.status(500).json({
            success: false,
            message: 'Error al obtener notificaciones'
        });
    }
});

// PUT - Marcar notificación como leída
router.put('/notificaciones/:id/leer', async (req, res) => {
    try {
        const { id } = req.params;
        
        const query = `
            UPDATE notificaciones 
            SET leida = true 
            WHERE id = $1
            RETURNING *
        `;
        
        const result = await pool.query(query, [id]);
        
        res.json({
            success: true,
            notificacion: result.rows[0]
        });
        
    } catch (error) {
        console.error('Error marcando notificación:', error);
        res.status(500).json({
            success: false,
            message: 'Error al marcar notificación'
        });
    }
});

// Función para verificar si hay match
async function verificarMatch(usuario_id, mascota_id) {
    try {
        // Obtener información de la mascota que recibió el like
        const mascotaQuery = `
            SELECT id_duenio, nombre, foto_url, tipo_animal, edad 
            FROM mascotas 
            WHERE id = $1
        `;
        const mascotaResult = await pool.query(mascotaQuery, [mascota_id]);
        
        if (mascotaResult.rows.length === 0) {
            return { hayMatch: false };
        }
        
        const duenio_mascota = mascotaResult.rows[0].id_duenio;
        const dataMascota = mascotaResult.rows[0];
        
        // Obtener una mascota del usuario que dio like
        const miMascotaQuery = `
            SELECT id, nombre, foto_url, tipo_animal, edad 
            FROM mascotas 
            WHERE id_duenio = $1 
            LIMIT 1
        `;
        const miMascotaResult = await pool.query(miMascotaQuery, [usuario_id]);
        
        if (miMascotaResult.rows.length === 0) {
            return { hayMatch: false };
        }
        
        const miMascota = miMascotaResult.rows[0];
        
        // Verificar si el dueño de la otra mascota también dio like a mi mascota
        const matchQuery = `
            SELECT * FROM pet_likes 
            WHERE usuario_id = $1 AND mascota_id = $2 AND is_like = true
        `;
        const matchResult = await pool.query(matchQuery, [duenio_mascota, miMascota.id]);
        
        if (matchResult.rows.length > 0) {
            // ¡HAY MATCH! Crear registro en la tabla mutual_matches
            const insertMatchQuery = `
                INSERT INTO mutual_matches (user1_id, user2_id, pet1_id, pet2_id)
                VALUES ($1, $2, $3, $4)
                ON CONFLICT DO NOTHING
                RETURNING *
            `;
            
            const newMatch = await pool.query(insertMatchQuery, [
                usuario_id, duenio_mascota, miMascota.id, mascota_id
            ]);
            
            return {
                hayMatch: true,
                match_id: newMatch.rows[0]?.id,
                usuario_1: usuario_id,
                usuario_2: duenio_mascota,
                mascota_1: miMascota,
                mascota_2: dataMascota
            };
        }
        
        return { hayMatch: false };
        
    } catch (error) {
        console.error('Error verificando match:', error);
        return { hayMatch: false };
    }
}

// Función para crear notificaciones de match
async function crearNotificacionMatch(matchData) {
    try {
        const notificaciones = [
            {
                usuario_id: matchData.usuario_1,
                tipo: 'match',
                titulo: '¡Nuevo Match! 🎉',
                mensaje: `Tu mascota ${matchData.mascota_1.nombre} hizo match con ${matchData.mascota_2.nombre}`,
                match_id: matchData.match_id
            },
            {
                usuario_id: matchData.usuario_2,
                tipo: 'match',
                titulo: '¡Nuevo Match! 🎉',
                mensaje: `Tu mascota ${matchData.mascota_2.nombre} hizo match con ${matchData.mascota_1.nombre}`,
                match_id: matchData.match_id
            }
        ];
        
        for (const notif of notificaciones) {
        const query = `
            INSERT INTO notificaciones (usuario_id, tipo, titulo, mensaje, match_id)
            VALUES ($1, $2, $3, $4, $5)
        `;
            
            await pool.query(query, [
                notif.usuario_id,
                notif.tipo,
                notif.titulo,
                notif.mensaje,
                notif.match_id
            ]);
        }
        
        console.log('✅ Notificaciones de match creadas');
        
    } catch (error) {
        console.error('Error creando notificaciones:', error);
    }
}

module.exports = router;
