const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const emailService = require('../services/emailService');

// Configura tu conexión a la base de datos
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Ruta de test para verificar que las rutas funcionan
router.get('/test-password-reset', (req, res) => {
    res.json({
        message: '✅ Sistema de recuperación de contraseña funcionando',
        endpoints: [
            'POST /api/forgot-password',
            'POST /api/verify-reset-code', 
            'POST /api/reset-password'
        ],
        timestamp: new Date().toISOString()
    });
});

// Ruta POST para solicitar recuperación de contraseña
router.post('/forgot-password', async (req, res) => {
    try {
        let { email, correo } = req.body;
        
        // Aceptar tanto 'email' como 'correo' para compatibilidad
        const userEmail = email || correo;
        
        console.log('📧 Solicitud de recuperación recibida para:', userEmail);
        
        // Validar email
        const emailToUse = typeof userEmail === 'string' ? userEmail.trim().toLowerCase() : '';
        const emailRegex = /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/;
        
        if (!emailToUse || !emailRegex.test(emailToUse)) {
            console.log('❌ Email inválido:', emailToUse);
            return res.status(400).json({ 
                success: false,
                message: 'Por favor, ingresa un correo electrónico válido.' 
            });
        }

        // Verificar si el usuario existe
        console.log('🔍 Buscando usuario con email:', emailToUse);
        const userCheck = await pool.query(
            'SELECT id, nombres, apellidos FROM usuarios WHERE correo = $1', 
            [emailToUse]
        );
        
        if (userCheck.rows.length === 0) {
            console.log('❌ Usuario no encontrado');
            return res.status(404).json({ 
                success: false,
                message: 'No se encontró ninguna cuenta con este correo electrónico.' 
            });
        }

        const user = userCheck.rows[0];
        const userName = `${user.nombres} ${user.apellidos}`;
        console.log('✅ Usuario encontrado:', userName);

        // Generar código de 6 dígitos y token único
        const resetCode = emailService.generateResetCode();
        const resetToken = crypto.randomBytes(32).toString('hex');
        const expirationTime = new Date(Date.now() + 10 * 60 * 1000); // 10 minutos

        console.log('🔑 Código generado:', resetCode);

        // Guardar el código y token en la base de datos
        await pool.query(`
            UPDATE usuarios 
            SET reset_password_code = $1, 
                reset_password_token = $2, 
                reset_password_expires = $3 
            WHERE correo = $4
        `, [resetCode, resetToken, expirationTime, emailToUse]);

        console.log('💾 Código guardado en base de datos');

        // Enviar email con el código
        console.log('📤 Enviando email...');
        const emailResult = await emailService.sendPasswordResetCode(emailToUse, resetCode, userName);
        
        if (!emailResult.success) {
            console.log('❌ Error enviando email:', emailResult.error);
            return res.status(500).json({ 
                success: false,
                message: 'Error al enviar el email. Inténtalo nuevamente.' 
            });
        }

        console.log(`✅ Código de recuperación enviado exitosamente a ${emailToUse}`);
        
        res.status(200).json({
            success: true,
            message: 'Se ha enviado un código de verificación a tu correo electrónico.',
            email: emailToUse,
            expires_in: '10 minutos'
        });

    } catch (error) {
        console.error('❌ Error en forgot-password:', error);
        res.status(500).json({ 
            success: false,
            message: 'Error interno del servidor.' 
        });
    }
});

// Ruta POST para verificar el código de recuperación
router.post('/verify-reset-code', async (req, res) => {
    try {
        let { email, correo, code, codigo } = req.body;
        
        // Aceptar tanto formato inglés como español
        const userEmail = email || correo;
        const resetCode = code || codigo;
        
        console.log('🔍 Verificando código para:', userEmail);
        
        // Validar datos
        const emailToUse = typeof userEmail === 'string' ? userEmail.trim().toLowerCase() : '';
        const codeToUse = typeof resetCode === 'string' ? resetCode.trim() : '';
        
        if (!emailToUse || !codeToUse) {
            return res.status(400).json({ 
                success: false,
                message: 'Correo y código son obligatorios.' 
            });
        }

        if (codeToUse.length !== 6) {
            return res.status(400).json({ 
                success: false,
                message: 'El código debe tener 6 dígitos.' 
            });
        }

        // Buscar usuario con código válido y no expirado
        const userCheck = await pool.query(`
            SELECT id, nombres, apellidos, reset_password_token, reset_password_expires 
            FROM usuarios 
            WHERE correo = $1 
            AND reset_password_code = $2 
            AND reset_password_expires > NOW()
        `, [emailToUse, codeToUse]);

        if (userCheck.rows.length === 0) {
            console.log('❌ Código inválido o expirado');
            return res.status(400).json({ 
                success: false,
                message: 'Código inválido o expirado. Solicita un nuevo código.' 
            });
        }

        const user = userCheck.rows[0];
        
        console.log(`✅ Código verificado exitosamente para ${emailToUse}`);
        
        res.status(200).json({
            success: true,
            message: 'Código verificado exitosamente. Ahora puedes establecer tu nueva contraseña.',
            resetToken: user.reset_password_token,
            userId: user.id
        });

    } catch (error) {
        console.error('❌ Error en verify-reset-code:', error);
        res.status(500).json({ 
            success: false,
            message: 'Error interno del servidor.' 
        });
    }
});

// Ruta POST para establecer nueva contraseña
router.post('/reset-password', async (req, res) => {
    try {
        let { email, correo, token, reset_token, newPassword, nueva_contraseña } = req.body;
        
        // Aceptar tanto formato inglés como español
        const userEmail = email || correo;
        const resetToken = token || reset_token;
        const newPass = newPassword || nueva_contraseña;
        
        console.log('🔐 Solicitud de cambio de contraseña para:', userEmail);
        
        // Validar datos
        const emailToUse = typeof userEmail === 'string' ? userEmail.trim().toLowerCase() : '';
        const tokenToUse = typeof resetToken === 'string' ? resetToken.trim() : '';
        const passwordToUse = typeof newPass === 'string' ? newPass : '';
        
        if (!emailToUse || !tokenToUse || !passwordToUse) {
            return res.status(400).json({ 
                success: false,
                message: 'Todos los campos son obligatorios.' 
            });
        }

        // Validar contraseña
        if (passwordToUse.length < 6) {
            return res.status(400).json({ 
                success: false,
                message: 'La nueva contraseña debe tener al menos 6 caracteres.' 
            });
        }

        // Verificar token válido y no expirado
        const userCheck = await pool.query(`
            SELECT id, nombres, apellidos 
            FROM usuarios 
            WHERE correo = $1 
            AND reset_password_token = $2 
            AND reset_password_expires > NOW()
        `, [emailToUse, tokenToUse]);

        if (userCheck.rows.length === 0) {
            console.log('❌ Token inválido o expirado');
            return res.status(400).json({ 
                success: false,
                message: 'Token inválido o expirado. Solicita un nuevo código de recuperación.' 
            });
        }

        const user = userCheck.rows[0];
        const userName = `${user.nombres} ${user.apellidos}`;

        // Encriptar la nueva contraseña
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(passwordToUse, saltRounds);

        // Actualizar contraseña y limpiar tokens de reset
        await pool.query(`
            UPDATE usuarios 
            SET contraseña = $1,
                reset_password_code = NULL,
                reset_password_token = NULL,
                reset_password_expires = NULL
            WHERE correo = $2
        `, [hashedPassword, emailToUse]);

        // Enviar email de confirmación
        await emailService.sendPasswordChangeConfirmation(emailToUse, userName);

        console.log(`✅ Contraseña actualizada exitosamente para ${emailToUse}`);
        
        res.status(200).json({
            success: true,
            message: 'Contraseña actualizada exitosamente. Ya puedes iniciar sesión con tu nueva contraseña.'
        });

    } catch (error) {
        console.error('❌ Error en reset-password:', error);
        res.status(500).json({ 
            success: false,
            message: 'Error interno del servidor.' 
        });
    }
});

module.exports = router;
