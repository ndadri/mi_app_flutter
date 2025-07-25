const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const nodemailer = require('nodemailer');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

const transporter = nodemailer.createTransporter({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

function generateVerificationCode() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

// Registro completo
router.post('/register', async (req, res) => {
    const {
        nombres,
        apellidos,
        correo,
        contraseña,
        genero,
        ubicacion,
        fecha_nacimiento
    } = req.body;

    try {
        // Validar campos requeridos
        if (!nombres || !apellidos || !correo || !contraseña || !genero || !ubicacion || !fecha_nacimiento) {
            return res.status(400).json({
                success: false,
                message: 'Todos los campos son obligatorios'
            });
        }

        // Validar género
        if (!['Masculino', 'Femenino', 'Otro'].includes(genero)) {
            return res.status(400).json({
                success: false,
                message: 'Género no válido'
            });
        }

       const verificationCode = generateVerificationCode();

const result = await pool.query(
    `INSERT INTO usuarios 
    (nombres, apellidos, correo, contraseña, genero, ubicacion, fecha_nacimiento, latitud, longitud, foto_perfil_url, codigo_verificacion, verificado)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
    RETURNING id, nombres, apellidos, correo, genero, ubicacion, fecha_nacimiento, latitud, longitud, foto_perfil_url, verificado, fecha_registro`,
    [nombres, apellidos, correo, hashedPassword, genero, ubicacion, fecha_nacimiento, latitud, longitud, foto_perfil || null, verificationCode, false]
);

        // Enviar email de verificación
        await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to: correo,
            subject: 'Verifica tu cuenta en PET-MATCH',
            html: `
                <h2>¡Bienvenido a PET-MATCH, ${nombres}!</h2>
                <p>Tu código de verificación es: <strong>${verificationCode}</strong></p>
                <p>Ingresa este código para activar tu cuenta.</p>
            `
        });

        res.json({
            success: true,
            user: result.rows[0],
            message: 'Registro exitoso. Revisa tu correo para verificar tu cuenta.'
        });

    } catch (err) {
        console.error('❌ Error en registro:', err.message);

        // Error de correo duplicado
        if (err.code === '23505' && err.constraint === 'usuarios_correo_key') {
            return res.status(400).json({
                success: false,
                message: 'Este correo ya está registrado'
            });
        }

        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// Login
router.post('/login', async (req, res) => {
    const { correo, contraseña } = req.body;

    try {
        if (!correo || !contraseña) {
            return res.status(400).json({
                success: false,
                message: 'Correo y contraseña son requeridos'
            });
        }

        const result = await pool.query(
            'SELECT id, nombres, apellidos, correo, genero, ubicacion, fecha_nacimiento, verificado FROM usuarios WHERE correo = $1 AND contraseña = $2',
            [correo, contraseña]
        );

        if (result.rows.length > 0) {
            const user = result.rows[0];

            if (!user.verificado) {
                return res.json({
                    success: false,
                    needsVerification: true,
                    message: 'Tu cuenta no está verificada. Revisa tu correo o solicita un nuevo código.'
                });
            }

            res.json({
                success: true,
                user,
                message: `¡Bienvenido de nuevo, ${user.nombres}!`
            });
        } else {
            res.status(401).json({
                success: false,
                message: 'Correo o contraseña incorrectos'
            });
        }
    } catch (err) {
        console.error('❌ Error en login:', err.message);
        res.status(500).json({
            success: false,
            message: 'Error del servidor'
        });
    }
});

// Verificar código
router.post('/verify', async (req, res) => {
    const { correo, codigo } = req.body;
    console.log('Verificando:', { correo, codigo });

    try {
        if (!correo || !codigo) {
            return res.status(400).json({
                success: false,
                message: 'Correo y código son requeridos'
            });
        }

        const result = await pool.query(
            `UPDATE usuarios 
             SET verificado = true, 
                 fecha_verificacion = CURRENT_TIMESTAMP
             WHERE correo = $1 AND codigo_verificacion = $2
             RETURNING id, nombres, apellidos, correo, genero, ubicacion, fecha_nacimiento, verificado`,
            [correo, codigo]
        );

        if (result.rows.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Código incorrecto o usuario no encontrado'
            });
        }

        res.json({
            success: true,
            message: 'Cuenta verificada correctamente',
            usuario: result.rows[0]
        });
    } catch (err) {
        console.error('❌ Error al verificar código:', err.message);
        res.status(500).json({
            success: false,
            message: 'Error al verificar la cuenta'
        });
    }
});

// Reenviar código
router.post('/resend-code', async (req, res) => {
    const { correo } = req.body;

    try {
        if (!correo) {
            return res.status(400).json({
                success: false,
                message: 'El correo es requerido'
            });
        }

        // Verificar que el usuario existe y no está verificado
        const userCheck = await pool.query(
            'SELECT nombres, verificado FROM usuarios WHERE correo = $1',
            [correo]
        );

        if (userCheck.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'No existe una cuenta con este correo'
            });
        }

        if (userCheck.rows[0].verificado) {
            return res.status(400).json({
                success: false,
                message: 'Esta cuenta ya está verificada'
            });
        }

        const newCode = generateVerificationCode();
        const nombres = userCheck.rows[0].nombres;

        await pool.query(
            `UPDATE usuarios SET codigo_verificacion = $1 WHERE correo = $2`,
            [newCode, correo]
        );

        await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to: correo,
            subject: 'Nuevo código de verificación - PET-MATCH',
            html: `
                <h2>Nuevo código de verificación</h2>
                <p>Hola ${nombres},</p>
                <p>Tu nuevo código de verificación es: <strong>${newCode}</strong></p>
                <p>Ingresa este código para activar tu cuenta.</p>
            `
        });

        res.json({
            success: true,
            message: 'Nuevo código enviado a tu correo'
        });
    } catch (err) {
        console.error('❌ Error al reenviar código:', err.message);
        res.status(500).json({
            success: false,
            message: 'Error al reenviar el código'
        });
    }
});

module.exports = router;