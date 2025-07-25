const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// 📌 Ruta para obtener la lista de chats de un usuario
router.get('/list/:userId', async (req, res) => {
    console.log('💬 Obteniendo lista de chats...');
    console.log('📋 Request params:', req.params);
    console.log('📋 Request headers:', req.headers);
    
    try {
        const { userId } = req.params;
        
        if (!userId) {
            console.log('❌ Error: ID de usuario no proporcionado');
            return res.status(400).json({ 
                success: false, 
                message: 'ID de usuario requerido' 
            });
        }
        
        const userIdNum = parseInt(userId);
        if (isNaN(userIdNum)) {
            console.log('❌ Error: ID de usuario no es un número');
            return res.status(400).json({ 
                success: false, 
                message: 'ID de usuario inválido' 
            });
        }
        
        console.log(`📋 Buscando chats para usuario ID: ${userIdNum}`);
        
        // Verificar existencia del usuario
        const userCheck = await pool.query('SELECT id FROM usuarios WHERE id = $1', [userIdNum]);
        console.log(`📋 Usuario existe: ${userCheck.rows.length > 0}`);
        
        if (userCheck.rows.length === 0) {
            console.log('❌ Error: Usuario no encontrado');
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado'
            });
        }
        
        // Obtener chats del usuario con información del otro participante
        console.log('📋 Ejecutando consulta de chats...');
        const result = await pool.query(`
            SELECT DISTINCT
                c.id as chat_id,
                c.ultima_actividad,
                CASE 
                    WHEN c.usuario1_id = $1 THEN u2.id
                    ELSE u1.id
                END as other_user_id,
                CASE 
                    WHEN c.usuario1_id = $1 THEN u2.nombres
                    ELSE u1.nombres
                END as nombres,
                CASE 
                    WHEN c.usuario1_id = $1 THEN u2.apellidos
                    ELSE u1.apellidos
                END as apellidos,
                CASE 
                    WHEN c.usuario1_id = $1 THEN u2.foto_perfil_url
                    ELSE u1.foto_perfil_url
                END as foto_perfil_url,
                (SELECT m.mensaje 
                 FROM mensajes m 
                 WHERE m.chat_id = c.id 
                 ORDER BY m.fecha DESC 
                 LIMIT 1) as ultimo_mensaje,
                (SELECT m.fecha 
                 FROM mensajes m 
                 WHERE m.chat_id = c.id 
                 ORDER BY m.fecha DESC 
                 LIMIT 1) as ultima_fecha,
                (SELECT COUNT(*) 
                 FROM mensajes m 
                 WHERE m.chat_id = c.id 
                 AND m.para_usuario_id = $1 
                 AND m.leido = FALSE) as mensajes_no_leidos
            FROM chats c
            JOIN usuarios u1 ON c.usuario1_id = u1.id
            JOIN usuarios u2 ON c.usuario2_id = u2.id
            WHERE c.usuario1_id = $1 OR c.usuario2_id = $1
            ORDER BY c.ultima_actividad DESC;
        `, [userIdNum]);
        
        console.log(`✅ Encontrados ${result.rows.length} chats`);
        
        // Mostrar información detallada para depuración
        if (result.rows.length > 0) {
            console.log('📋 Detalle de chats encontrados:');
            result.rows.forEach((chat, index) => {
                console.log(`  Chat #${index + 1}: ID=${chat.chat_id}, Con=${chat.nombres} ${chat.apellidos}, Último mensaje: "${chat.ultimo_mensaje?.substring(0, 20) || 'No hay mensajes'}"...`);
            });
        } else {
            console.log('⚠️ No se encontraron chats para este usuario');
        }
        
        res.json({ 
            success: true, 
            chats: result.rows,
            userIdReceived: userIdNum
        });
        
    } catch (error) {
        console.error('❌ Error al obtener lista de chats:', error);
        console.error('Stack:', error.stack);
        res.status(500).json({ 
            success: false, 
            message: 'Error interno del servidor',
            error: error.message
        });
    }
});

// 📌 Ruta para obtener historial de mensajes entre dos usuarios
router.get('/history', async (req, res) => {
    console.log('📜 Obteniendo historial de mensajes...');
    
    try {
        const { usuario1, usuario2 } = req.query;
        
        if (!usuario1 || !usuario2) {
            return res.status(400).json({ 
                success: false, 
                message: 'Se requieren los IDs de ambos usuarios' 
            });
        }
        
        const user1Id = parseInt(usuario1);
        const user2Id = parseInt(usuario2);
        
        if (isNaN(user1Id) || isNaN(user2Id)) {
            return res.status(400).json({ 
                success: false, 
                message: 'IDs de usuario inválidos' 
            });
        }
        
        console.log(`📋 Buscando mensajes entre usuarios ${user1Id} y ${user2Id}`);
        
        // Obtener mensajes del chat
        const result = await pool.query(`
            SELECT 
                m.id,
                m.de_usuario_id,
                m.para_usuario_id,
                m.mensaje,
                m.fecha,
                m.leido,
                u1.nombres as de_usuario_nombre,
                u2.nombres as para_usuario_nombre
            FROM mensajes m
            JOIN usuarios u1 ON m.de_usuario_id = u1.id
            JOIN usuarios u2 ON m.para_usuario_id = u2.id
            WHERE (m.de_usuario_id = $1 AND m.para_usuario_id = $2)
               OR (m.de_usuario_id = $2 AND m.para_usuario_id = $1)
            ORDER BY m.fecha ASC;
        `, [user1Id, user2Id]);
        
        // Marcar mensajes como leídos para el usuario que consulta
        await pool.query(`
            UPDATE mensajes 
            SET leido = TRUE 
            WHERE para_usuario_id = $1 
            AND de_usuario_id = $2 
            AND leido = FALSE;
        `, [user1Id, user2Id]);
        
        console.log(`✅ Encontrados ${result.rows.length} mensajes`);
        
        res.json({ 
            success: true, 
            mensajes: result.rows 
        });
        
    } catch (error) {
        console.error('❌ Error al obtener historial:', error.message);
        res.status(500).json({ 
            success: false, 
            message: 'Error interno del servidor' 
        });
    }
});

// 📌 Ruta para enviar un mensaje
router.post('/send', async (req, res) => {
    console.log('📤 Enviando mensaje...');
    
    try {
        const { de_usuario_id, para_usuario_id, mensaje } = req.body;
        
        // Validaciones
        if (!de_usuario_id || !para_usuario_id || !mensaje) {
            return res.status(400).json({ 
                success: false, 
                message: 'Faltan datos requeridos: de_usuario_id, para_usuario_id, mensaje' 
            });
        }
        
        const fromUserId = parseInt(de_usuario_id);
        const toUserId = parseInt(para_usuario_id);
        
        if (isNaN(fromUserId) || isNaN(toUserId)) {
            return res.status(400).json({ 
                success: false, 
                message: 'IDs de usuario inválidos' 
            });
        }
        
        if (fromUserId === toUserId) {
            return res.status(400).json({ 
                success: false, 
                message: 'No puedes enviarte un mensaje a ti mismo' 
            });
        }
        
        if (typeof mensaje !== 'string' || mensaje.trim().length === 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'El mensaje no puede estar vacío' 
            });
        }
        
        if (mensaje.trim().length > 1000) {
            return res.status(400).json({ 
                success: false, 
                message: 'El mensaje es muy largo (máximo 1000 caracteres)' 
            });
        }
        
        console.log(`📋 Enviando mensaje de ${fromUserId} a ${toUserId}`);
        
        // Obtener o crear chat
        const chatResult = await pool.query(
            'SELECT obtener_o_crear_chat($1, $2) as chat_id',
            [fromUserId, toUserId]
        );
        
        const chatId = chatResult.rows[0].chat_id;
        
        // Insertar mensaje
        const messageResult = await pool.query(`
            INSERT INTO mensajes (chat_id, de_usuario_id, para_usuario_id, mensaje)
            VALUES ($1, $2, $3, $4)
            RETURNING *;
        `, [chatId, fromUserId, toUserId, mensaje.trim()]);
        
        const newMessage = messageResult.rows[0];
        
        console.log(`✅ Mensaje enviado exitosamente (ID: ${newMessage.id})`);
        
        res.json({ 
            success: true, 
            mensaje: newMessage 
        });
        
    } catch (error) {
        console.error('❌ Error al enviar mensaje:', error.message);
        res.status(500).json({ 
            success: false, 
            message: 'Error interno del servidor' 
        });
    }
});

// 📌 Ruta para crear un nuevo chat
router.post('/create', async (req, res) => {
    console.log('🆕 Creando nuevo chat...');
    console.log('📋 Request body:', req.body);
    console.log('📋 Request headers:', req.headers);
    
    try {
        const { usuario1_id, usuario2_id } = req.body;
        
        console.log(`📋 IDs recibidos: usuario1=${usuario1_id}, usuario2=${usuario2_id}`);
        
        if (!usuario1_id || !usuario2_id) {
            console.log('❌ Error: Faltan IDs de usuario');
            return res.status(400).json({ 
                success: false, 
                message: 'Se requieren ambos IDs de usuario',
                received: { usuario1_id, usuario2_id }
            });
        }
        
        const user1Id = parseInt(usuario1_id);
        const user2Id = parseInt(usuario2_id);
        
        if (isNaN(user1Id) || isNaN(user2Id)) {
            return res.status(400).json({ 
                success: false, 
                message: 'IDs de usuario inválidos' 
            });
        }
        
        if (user1Id === user2Id) {
            return res.status(400).json({ 
                success: false, 
                message: 'No puedes crear un chat contigo mismo' 
            });
        }
        
        // Verificar que ambos usuarios existen
        const usersCheck = await pool.query(
            'SELECT id FROM usuarios WHERE id = $1 OR id = $2',
            [user1Id, user2Id]
        );
        
        if (usersCheck.rows.length < 2) {
            return res.status(400).json({ 
                success: false, 
                message: 'Uno o ambos usuarios no existen' 
            });
        }
        
        // Crear o obtener chat
        const chatResult = await pool.query(
            'SELECT obtener_o_crear_chat($1, $2) as chat_id',
            [user1Id, user2Id]
        );
        
        const chatId = chatResult.rows[0].chat_id;
        
        // Obtener información del chat creado
        const chatInfo = await pool.query(`
            SELECT 
                c.id,
                c.usuario1_id,
                c.usuario2_id,
                c.fecha_creacion,
                u1.nombres as usuario1_nombre,
                u2.nombres as usuario2_nombre
            FROM chats c
            JOIN usuarios u1 ON c.usuario1_id = u1.id
            JOIN usuarios u2 ON c.usuario2_id = u2.id
            WHERE c.id = $1;
        `, [chatId]);
        
        console.log(`✅ Chat creado/obtenido exitosamente (ID: ${chatId})`);
        
        res.json({ 
            success: true, 
            chat: chatInfo.rows[0] 
        });
        
    } catch (error) {
        console.error('❌ Error al crear chat:', error.message);
        res.status(500).json({ 
            success: false, 
            message: 'Error interno del servidor' 
        });
    }
});

// 📌 Ruta para marcar mensajes como leídos
router.put('/mark-read', async (req, res) => {
    console.log('👁️ Marcando mensajes como leídos...');
    
    try {
        const { usuario_id, chat_id } = req.body;
        
        if (!usuario_id || !chat_id) {
            return res.status(400).json({ 
                success: false, 
                message: 'Se requieren usuario_id y chat_id' 
            });
        }
        
        const userId = parseInt(usuario_id);
        const chatIdNum = parseInt(chat_id);
        
        if (isNaN(userId) || isNaN(chatIdNum)) {
            return res.status(400).json({ 
                success: false, 
                message: 'IDs inválidos' 
            });
        }
        
        // Marcar mensajes como leídos
        const result = await pool.query(`
            UPDATE mensajes 
            SET leido = TRUE 
            WHERE chat_id = $1 
            AND para_usuario_id = $2 
            AND leido = FALSE
            RETURNING id;
        `, [chatIdNum, userId]);
        
        console.log(`✅ ${result.rows.length} mensajes marcados como leídos`);
        
        res.json({ 
            success: true, 
            mensajes_actualizados: result.rows.length 
        });
        
    } catch (error) {
        console.error('❌ Error al marcar mensajes como leídos:', error.message);
        res.status(500).json({ 
            success: false, 
            message: 'Error interno del servidor' 
        });
    }
});

module.exports = router;
