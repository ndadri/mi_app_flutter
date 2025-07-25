require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function testChatSystem() {
    console.log('🧪 Probando sistema de chat completo...\n');
    
    try {
        // 1. Verificar usuarios disponibles
        console.log('1️⃣ Verificando usuarios disponibles...');
        const users = await pool.query('SELECT id, nombres, apellidos FROM usuarios ORDER BY id');
        
        if (users.rows.length < 2) {
            console.log('❌ Se necesitan al menos 2 usuarios para probar el chat');
            return;
        }
        
        console.log('✅ Usuarios encontrados:');
        users.rows.forEach(user => {
            console.log(`   - ID: ${user.id}, Nombre: ${user.nombres} ${user.apellidos}`);
        });
        
        const user1 = users.rows[0];
        const user2 = users.rows[1];
        
        // 2. Crear chat entre usuarios
        console.log('\n2️⃣ Creando chat entre usuarios...');
        
        const createChatResult = await pool.query(
            'SELECT obtener_o_crear_chat($1, $2) as chat_id',
            [user1.id, user2.id]
        );
        
        const chatId = createChatResult.rows[0].chat_id;
        console.log(`✅ Chat creado/obtenido con ID: ${chatId}`);
        
        // 3. Enviar mensajes de prueba
        console.log('\n3️⃣ Enviando mensajes de prueba...');
        
        const mensajes = [
            { de: user1.id, para: user2.id, texto: 'Hola! ¿Cómo estás?' },
            { de: user2.id, para: user1.id, texto: 'Hola! Todo bien, gracias por preguntar' },
            { de: user1.id, para: user2.id, texto: 'Qué bueno! Me alegra saber eso' },
            { de: user2.id, para: user1.id, texto: 'Sí, y tú ¿cómo has estado?' },
            { de: user1.id, para: user2.id, texto: 'Muy bien también, gracias!' },
        ];
        
        for (const msg of mensajes) {
            await pool.query(`
                INSERT INTO mensajes (chat_id, de_usuario_id, para_usuario_id, mensaje)
                VALUES ($1, $2, $3, $4)
            `, [chatId, msg.de, msg.para, msg.texto]);
            
            console.log(`   📤 ${msg.de} → ${msg.para}: "${msg.texto}"`);
        }
        
        // 4. Probar consulta de lista de chats
        console.log('\n4️⃣ Probando consulta de lista de chats...');
        
        const chatList = await pool.query(`
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
                (SELECT m.mensaje 
                 FROM mensajes m 
                 WHERE m.chat_id = c.id 
                 ORDER BY m.fecha DESC 
                 LIMIT 1) as ultimo_mensaje,
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
        `, [user1.id]);
        
        console.log(`✅ Lista de chats para ${user1.nombres}:`);
        chatList.rows.forEach(chat => {
            console.log(`   - Chat con: ${chat.nombres} ${chat.apellidos}`);
            console.log(`     Último mensaje: "${chat.ultimo_mensaje}"`);
            console.log(`     Mensajes no leídos: ${chat.mensajes_no_leidos}`);
        });
        
        // 5. Probar consulta de historial de mensajes
        console.log('\n5️⃣ Probando consulta de historial de mensajes...');
        
        const history = await pool.query(`
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
        `, [user1.id, user2.id]);
        
        console.log(`✅ Historial de mensajes entre ${user1.nombres} y ${user2.nombres}:`);
        history.rows.forEach(msg => {
            const direction = msg.de_usuario_id === user1.id ? '→' : '←';
            console.log(`   ${direction} ${msg.de_usuario_nombre}: "${msg.mensaje}" ${msg.leido ? '✓' : '○'}`);
        });
        
        // 6. Probar marcado como leído
        console.log('\n6️⃣ Probando marcado de mensajes como leídos...');
        
        const markReadResult = await pool.query(`
            UPDATE mensajes 
            SET leido = TRUE 
            WHERE para_usuario_id = $1 
            AND de_usuario_id = $2 
            AND leido = FALSE
            RETURNING id;
        `, [user1.id, user2.id]);
        
        console.log(`✅ ${markReadResult.rows.length} mensajes marcados como leídos`);
        
        // 7. Verificar endpoints con simulación
        console.log('\n7️⃣ Simulando respuestas de endpoints...');
        
        const endpoints = {
            'GET /api/chat/list/:userId': {
                success: true,
                chats: chatList.rows
            },
            'GET /api/chat/history': {
                success: true,
                mensajes: history.rows
            },
            'POST /api/chat/send': {
                success: true,
                mensaje: {
                    id: 999,
                    chat_id: chatId,
                    de_usuario_id: user1.id,
                    para_usuario_id: user2.id,
                    mensaje: 'Mensaje de prueba',
                    fecha: new Date().toISOString(),
                    leido: false
                }
            }
        };
        
        for (const [endpoint, response] of Object.entries(endpoints)) {
            console.log(`   ✅ ${endpoint} - respuesta simulada preparada`);
        }
        
        // 8. Limpiar datos de prueba
        console.log('\n8️⃣ Limpiando datos de prueba...');
        
        await pool.query('DELETE FROM mensajes WHERE chat_id = $1', [chatId]);
        await pool.query('DELETE FROM chats WHERE id = $1', [chatId]);
        
        console.log('✅ Datos de prueba eliminados');
        
        console.log('\n🎉 RESULTADO: Sistema de chat funcionando correctamente!');
        console.log('   ✅ Creación de chats');
        console.log('   ✅ Envío de mensajes');
        console.log('   ✅ Lista de chats');
        console.log('   ✅ Historial de mensajes');
        console.log('   ✅ Marcado como leído');
        console.log('   ✅ Endpoints preparados');
        
    } catch (error) {
        console.error('\n❌ ERROR en el sistema de chat:', error.message);
        console.error('📋 Detalles:', error.stack);
    } finally {
        await pool.end();
    }
}

// Ejecutar prueba
testChatSystem();
