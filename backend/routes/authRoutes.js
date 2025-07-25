const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const nodemailer = require('nodemailer');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const bcrypt = require('bcryptjs');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

function generateVerificationCode() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

// Configuración de la ruta de uploads
const uploadPath = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadPath)) {
    fs.mkdirSync(uploadPath, { recursive: true });
}

// --- CONFIGURACIÓN MEJORADA de Multer para subir imágenes ---
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const uploadPath = path.join(__dirname, '..', 'uploads');
        // Asegurar que el directorio existe
        if (!fs.existsSync(uploadPath)) {
            fs.mkdirSync(uploadPath, { recursive: true });
            console.log('📁 Directorio uploads creado:', uploadPath);
        }
        cb(null, uploadPath);
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname);
        const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1E9) + ext;
        console.log('📝 Generando nombre único:', uniqueName);
        cb(null, uniqueName);
    }
});

// Filtro para validar tipos de archivo
const fileFilter = (req, file, cb) => {
    console.log('🔍 Validando archivo:', file.originalname);
    console.log('📋 MIME type:', file.mimetype);
    
    // Tipos MIME permitidos para imágenes (versión extendida)
    const allowedMimeTypes = [
        'image/jpeg',
        'image/jpg', 
        'image/png',
        'image/gif',
        'image/bmp',
        'image/webp',
        'image/tiff',
        'image/tif',
        'image/heic',
        'image/heif',
        'image/svg+xml',
        'image/x-ms-bmp',
        'image/vnd.microsoft.icon',
        'image/ico',
        'image/icon',
        'image/x-icon',
        // Algunos sistemas pueden reportar estos tipos MIME
        'application/octet-stream', // Para archivos que no se detectan correctamente
        'image/pjpeg', // Para IE y algunos navegadores
        'image/x-png'  // Para algunos sistemas
    ];
    
    // También validar por extensión de archivo como fallback
    const fileName = file.originalname.toLowerCase();
    const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tiff', '.tif', '.heic', '.heif', '.svg', '.ico'];
    const hasValidExtension = validExtensions.some(ext => fileName.endsWith(ext));
    
    if (allowedMimeTypes.includes(file.mimetype) || hasValidExtension) {
        console.log('✅ Archivo válido - MIME:', file.mimetype, 'Extensión válida:', hasValidExtension);
        cb(null, true);
    } else {
        console.log('❌ Archivo inválido - MIME:', file.mimetype, 'Extensión válida:', hasValidExtension);
        cb(new Error('Formato de archivo no válido. Solo se permiten: JPG, JPEG, PNG, GIF, BMP, WEBP, TIFF, HEIC, SVG'), false);
    }
};

const upload = multer({ 
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB máximo para perfiles de usuario
    }
});

// --- ENDPOINT MEJORADO para subir imagen y devolver URL ---
router.post('/upload', (req, res) => {
    console.log('📤 Recibiendo solicitud de upload...');
    
    upload.single('file')(req, res, function (err) {
        if (err instanceof multer.MulterError) {
            console.error('❌ Error de Multer:', err.message);
            if (err.code === 'LIMIT_FILE_SIZE') {
                return res.status(400).json({ 
                    success: false, 
                    message: 'Archivo muy grande. Máximo 10MB permitido' 
                });
            }
            return res.status(400).json({ 
                success: false, 
                message: `Error al procesar archivo: ${err.message}` 
            });
        } else if (err) {
            console.error('❌ Error personalizado:', err.message);
            return res.status(400).json({ 
                success: false, 
                message: err.message 
            });
        }

        if (!req.file) {
            console.log('❌ No se recibió ningún archivo');
            return res.status(400).json({ 
                success: false, 
                message: 'No se subió ninguna imagen' 
            });
        }

        console.log('✅ Archivo recibido:', req.file.filename);
        console.log('📁 Ubicación:', req.file.path);
        console.log('📏 Tamaño:', req.file.size, 'bytes');

        const url = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
        console.log('🔗 URL generada:', url);
        
        res.json({ 
            success: true, 
            url: url,
            filename: req.file.filename,
            size: req.file.size
        });
    });
});

// Registro completo
router.post('/register', async (req, res) => {
    const {
        nombres,
        apellidos,
        correo,
        contraseña,
        genero,
        ubicacion,
        edad,
        fecha_nacimiento,
        latitud,
        longitud,
        foto_perfil // <-- URL de la foto (opcional para usuarios)
    } = req.body;

    try {
        // Validación de campos obligatorios
        if (!nombres || !apellidos || !correo || !contraseña || !genero || !ubicacion || !fecha_nacimiento || edad === undefined || edad === null) {
            return res.status(400).json({
                success: false,
                message: 'Todos los campos son obligatorios (nombres, apellidos, correo, contraseña, género, ubicación, edad, fecha de nacimiento)'
            });
        }

        // Validación estricta de nombres (solo letras y espacios)
        const nameRegex = /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/;
        if (!nameRegex.test(nombres.trim())) {
            return res.status(400).json({
                success: false,
                message: 'Los nombres solo pueden contener letras y espacios'
            });
        }

        // Validación estricta de apellidos (solo letras y espacios)
        if (!nameRegex.test(apellidos.trim())) {
            return res.status(400).json({
                success: false,
                message: 'Los apellidos solo pueden contener letras y espacios'
            });
        }

        // Validación de nombres de prueba prohibidos
        const nombresProhibidos = ['test', 'prueba', 'testing', 'demo', 'ejemplo', 'admin', 'root', 'user'];
        const nombreCompleto = `${nombres.trim()} ${apellidos.trim()}`.toLowerCase();
        
        for (const prohibido of nombresProhibidos) {
            if (nombreCompleto.includes(prohibido)) {
                return res.status(400).json({
                    success: false,
                    message: 'No se permiten nombres de prueba o genéricos'
                });
            }
        }

        // Validación de edad (debe ser número entero)
        if (!Number.isInteger(edad) || edad < 13 || edad > 100) {
            return res.status(400).json({
                success: false,
                message: 'La edad debe ser un número entero entre 13 y 100 años'
            });
        }

        // Validación de correo electrónico
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(correo.trim())) {
            return res.status(400).json({
                success: false,
                message: 'Formato de correo electrónico inválido'
            });
        }

        // Validación de contraseña
        if (contraseña.length < 6) {
            return res.status(400).json({
                success: false,
                message: 'La contraseña debe tener al menos 6 caracteres'
            });
        }

        // Validación de género
        if (!['Masculino', 'Femenino', 'Otro'].includes(genero)) {
            return res.status(400).json({
                success: false,
                message: 'Género no válido'
            });
        }

        // Validación de ubicación
        if (ubicacion.trim().length < 3) {
            return res.status(400).json({
                success: false,
                message: 'La ubicación debe tener al menos 3 caracteres'
            });
        }

        // 🔒 SEGURIDAD CRÍTICA: Verificar que no se intente enviar campos de rol en el registro
        // TODOS los usuarios registrados a través de este endpoint DEBEN ser usuarios normales (id_rol = 1)
        if (req.body.rol || req.body.id_rol || req.body.role) {
            console.log('⚠️ INTENTO DE REGISTRO CON ROL PERSONALIZADO BLOQUEADO:', {
                ip: req.ip,
                correo: correo,
                intentedRole: req.body.rol || req.body.id_rol || req.body.role
            });
            return res.status(400).json({
                success: false,
                message: 'Parámetros no válidos en el registro'
            });
        }

        // Hashear la contraseña antes de guardar
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(contraseña, salt);

        const verificationCode = generateVerificationCode();

        const result = await pool.query(
            `INSERT INTO usuarios 
            (nombres, apellidos, correo, contraseña, genero, ubicacion, edad, fecha_nacimiento, latitud, longitud, foto_perfil_url, codigo_verificacion, verificado, id_rol)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
             RETURNING id, nombres, apellidos, correo, genero, ubicacion, edad, fecha_nacimiento, latitud, longitud, foto_perfil_url, verificado, fecha_registro, id_rol`,
            [
                nombres.trim(), 
                apellidos.trim(), 
                correo.trim(), 
                hashedPassword, 
                genero, 
                ubicacion.trim(), 
                edad, 
                fecha_nacimiento, 
                latitud, 
                longitud, 
                foto_perfil || null, 
                verificationCode, 
                false, 
                1 // 🔒 SEGURIDAD CRÍTICA: SIEMPRE rol = 1 (usuario normal) - NO modificar este valor
            ]
        );

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

        // Busca el usuario por correo con información de rol
        const result = await pool.query(`
            SELECT u.*, r.nombre as rol_nombre, r.descripcion as rol_descripcion, r.permisos as rol_permisos
            FROM usuarios u
            LEFT JOIN roles r ON u.id_rol = r.id
            WHERE u.correo = $1
        `, [correo]);

        if (result.rows.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'Correo o contraseña incorrectos'
            });
        }

        const user = result.rows[0];

        // Compara la contraseña usando bcrypt
        const isMatch = await bcrypt.compare(contraseña, user.contraseña);
        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: 'Correo o contraseña incorrectos'
            });
        }

        // Elimina la contraseña antes de enviar el usuario
        delete user.contraseña;

        if (!user.verificado) {
            return res.json({
                success: false,
                needsVerification: true,
                message: 'Tu cuenta no está verificada. Revisa tu correo o solicita un nuevo código.'
            });
        }

        // Actualizar ultima_conexion
        await pool.query(`
            UPDATE usuarios 
            SET ultima_conexion = CURRENT_TIMESTAMP 
            WHERE id = $1
        `, [user.id]);

        // Estructurar información del rol para el frontend
        const userResponse = {
            ...user,
            rol: {
                id: user.id_rol,
                nombre: user.rol_nombre || 'usuario',
                descripcion: user.rol_descripcion || 'Usuario normal',
                permisos: user.rol_permisos || {}
            }
        };

        // Limpiar campos redundantes
        delete userResponse.rol_nombre;
        delete userResponse.rol_descripcion;
        delete userResponse.rol_permisos;

        res.json({
            success: true,
            user: userResponse,
            token: `simple_token_${user.id}`, // Token simple basado en el ID de usuario
            message: `¡Bienvenido de nuevo, ${user.nombres}!`
        });

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
     RETURNING id, nombres, apellidos, correo, genero, ubicacion, fecha_nacimiento, latitud, longitud, foto_perfil_url, verificado`,
    [correo, codigo]
);

        console.log('Resultado del UPDATE:', result.rows);

        if (result.rows.length > 0) {
            const user = result.rows[0];
            res.json({
                success: true,
                user,
                message: `¡Cuenta verificada exitosamente! Bienvenido ${user.nombres}.`
            });
        } else {
            res.status(400).json({
                success: false,
                message: 'Código inválido o expirado'
            });
        }
    } catch (err) {
        console.error('❌ Error al verificar:', err.message);
        res.status(500).json({
            success: false,
            message: 'Error al verificar la cuenta'
        });
    }
});

// Recuperar contraseña: enviar código si el correo existe
router.post('/forgot-password', async (req, res) => {
    const { correo } = req.body;
    if (!correo) {
        return res.status(400).json({ success: false, message: 'El correo es requerido' });
    }

    try {
        // Buscar usuario por correo y obtener el código actual
        const userResult = await pool.query(
            'SELECT nombres, codigo_verificacion FROM usuarios WHERE correo = $1',
            [correo]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'El correo no existe' });
        }

        const nombres = userResult.rows[0].nombres;
        let code = userResult.rows[0].codigo_verificacion;

        // Si no hay código, genera uno y guárdalo
        if (!code) {
            code = generateVerificationCode();
            await pool.query(
                'UPDATE usuarios SET codigo_verificacion = $1 WHERE correo = $2',
                [code, correo]
            );
        }

        // Enviar el código por correo
        await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to: correo,
            subject: 'Código de recuperación de contraseña - PET-MATCH',
            html: `
                <div style="font-family: Arial, sans-serif; color: #333; background: #faf6ff; padding: 32px; border-radius: 16px; border: 1px solid #b266ff; max-width: 480px; margin: auto;">
                  <h2 style="color: #800080;">Recuperación de contraseña</h2>
                  <p>Hola <strong>${nombres}</strong>,</p>
                  <p>Recibimos una solicitud para recuperar el acceso a tu cuenta de Pet Match.</p>
                  <p style="font-size: 18px; margin: 24px 0;">Tu código de recuperación es:</p>
                  <div style="background: #e9d6ff; padding: 16px; border-radius: 8px; text-align: center; font-size: 28px; color: #800080; font-weight: bold; letter-spacing: 4px;">${code}</div>
                  <p style="margin-top: 24px;">Ingresa este código en la aplicación para reestablecer tu contraseña.</p>
                  <hr style="margin: 32px 0; border: none; border-top: 1px solid #b266ff;">
                  <p style="color: #800080; font-size: 15px;">Si no solicitaste este cambio, ignora este mensaje o contacta con nuestro soporte: <a href="mailto:soporte@petmatch.com" style="color: #800080; text-decoration: underline;">soporte@petmatch.com</a></p>
                  <p style="font-size: 13px; color: #888; margin-top: 16px;">Gracias por confiar en Pet Match 🐾</p>
                </div>
            `
        });

        res.json({ success: true, message: 'Código enviado a tu correo' });
    } catch (err) {
        console.error('❌ Error en forgot-password:', err.message);
        res.status(500).json({ success: false, message: 'Error interno del servidor' });
    }
});

// ...existing code...
router.post('/reset-password', async (req, res) => {
    const { correo, nueva_contraseña } = req.body;
    if (!correo || !nueva_contraseña) {
        return res.status(400).json({ success: false, message: 'Datos incompletos' });
    }
    try {
        // 1. Obtener la contraseña actual hasheada del usuario
        const userResult = await pool.query(
            'SELECT contraseña FROM usuarios WHERE correo = $1',
            [correo]
        );
        if (userResult.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Usuario no encontrado' });
        }
        const currentHashedPassword = userResult.rows[0].contraseña;

        // 2. Comparar la nueva contraseña con la actual
        const isSame = await bcrypt.compare(nueva_contraseña, currentHashedPassword);
        if (isSame) {
            return res.status(400).json({ success: false, message: 'La nueva contraseña no puede ser igual a la anterior' });
        }

        // 3. Si es diferente, actualizar
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(nueva_contraseña, salt);
        await pool.query(
            'UPDATE usuarios SET contraseña = $1 WHERE correo = $2',
            [hashedPassword, correo]
        );
        res.json({ success: true, message: 'Contraseña actualizada correctamente' });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Error al actualizar la contraseña' });
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

// 📌 Ruta PUT para actualizar perfil de usuario
router.put('/profile/:id', async (req, res) => {
    const { id } = req.params;
    const {
        nombres,
        apellidos,
        correo,
        genero,
        ubicacion,
        edad,
        fecha_nacimiento,
        foto_perfil
    } = req.body;

    try {
        // Validar que el ID sea un número válido
        const idUsuario = parseInt(id);
        if (isNaN(idUsuario) || idUsuario <= 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'ID de usuario inválido' 
            });
        }

        // Verificar que el usuario existe
        const userCheck = await pool.query(
            'SELECT id FROM usuarios WHERE id = $1',
            [idUsuario]
        );

        if (userCheck.rows.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'Usuario no encontrado' 
            });
        }

        // Validación de campos obligatorios
        if (!nombres || !apellidos || !correo || !genero || !ubicacion || !fecha_nacimiento || edad === undefined || edad === null) {
            return res.status(400).json({
                success: false,
                message: 'Todos los campos son obligatorios (nombres, apellidos, correo, género, ubicación, edad, fecha de nacimiento)'
            });
        }

        // Validación estricta de nombres (solo letras y espacios)
        const nameRegex = /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/;
        if (!nameRegex.test(nombres.trim())) {
            return res.status(400).json({
                success: false,
                message: 'Los nombres solo pueden contener letras y espacios'
            });
        }

        // Validación estricta de apellidos (solo letras y espacios)
        if (!nameRegex.test(apellidos.trim())) {
            return res.status(400).json({
                success: false,
                message: 'Los apellidos solo pueden contener letras y espacios'
            });
        }

        // Validación de edad (debe ser número entero)
        if (!Number.isInteger(edad) || edad < 13 || edad > 100) {
            return res.status(400).json({
                success: false,
                message: 'La edad debe ser un número entero entre 13 y 100 años'
            });
        }

        // Validación de correo electrónico
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(correo.trim())) {
            return res.status(400).json({
                success: false,
                message: 'Formato de correo electrónico inválido'
            });
        }

        // Validación de género
        if (!['Masculino', 'Femenino', 'Otro'].includes(genero)) {
            return res.status(400).json({
                success: false,
                message: 'Género no válido'
            });
        }

        // Validación de ubicación
        if (ubicacion.trim().length < 3) {
            return res.status(400).json({
                success: false,
                message: 'La ubicación debe tener al menos 3 caracteres'
            });
        }

        // Verificar si el correo ya existe en otro usuario
        const emailCheck = await pool.query(
            'SELECT id FROM usuarios WHERE correo = $1 AND id != $2',
            [correo.trim(), idUsuario]
        );

        if (emailCheck.rows.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'Este correo ya está registrado por otro usuario'
            });
        }

        // Construir la consulta de actualización dinámicamente
        let updateQuery = `UPDATE usuarios SET 
            nombres = $1, 
            apellidos = $2, 
            correo = $3, 
            genero = $4, 
            ubicacion = $5, 
            edad = $6, 
            fecha_nacimiento = $7`;
        
        let queryParams = [
            nombres.trim(), 
            apellidos.trim(), 
            correo.trim(), 
            genero, 
            ubicacion.trim(), 
            edad, 
            fecha_nacimiento
        ];

        // Agregar foto_perfil si se proporcionó
        if (foto_perfil) {
            updateQuery += `, foto_perfil_url = $${queryParams.length + 1}`;
            queryParams.push(foto_perfil);
        }

        updateQuery += ` WHERE id = $${queryParams.length + 1} 
            RETURNING id, nombres, apellidos, correo, genero, ubicacion, edad, fecha_nacimiento, foto_perfil_url, verificado, fecha_registro`;
        
        queryParams.push(idUsuario);

        // Ejecutar la actualización
        const updateResult = await pool.query(updateQuery, queryParams);

        if (updateResult.rows.length > 0) {
            const updatedUser = updateResult.rows[0];
            console.log(`✅ Perfil de usuario "${nombres}" (ID: ${idUsuario}) actualizado exitosamente`);
            
            res.json({ 
                success: true, 
                user: updatedUser,
                message: 'Perfil actualizado exitosamente'
            });
        } else {
            res.status(500).json({ 
                success: false, 
                message: 'No se pudo actualizar el perfil' 
            });
        }

    } catch (err) {
        console.error('❌ Error al actualizar perfil:', err.message);
        
        if (err.code === '23505' && err.constraint === 'usuarios_correo_key') {
            return res.status(400).json({
                success: false,
                message: 'Este correo ya está registrado'
            });
        }

        res.status(500).json({ 
            success: false, 
            message: 'Error interno del servidor al actualizar perfil' 
        });
    }
});

// ==========================================
// FUNCIONES DE MIDDLEWARE PARA ROLES
// ==========================================

// Middleware para verificar permisos
const verificarPermiso = (recurso, accion) => {
    return async (req, res, next) => {
        try {
            const { userId } = req.body; // Se podría obtener de token JWT en un futuro
            
            if (!userId) {
                return res.status(401).json({
                    success: false,
                    message: 'ID de usuario requerido'
                });
            }

            // Obtener permisos del usuario
            const result = await pool.query(`
                SELECT r.permisos, r.nombre as rol_nombre
                FROM usuarios u
                JOIN roles r ON u.id_rol = r.id
                WHERE u.id = $1
            `, [userId]);

            if (result.rows.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Usuario no encontrado'
                });
            }

            const { permisos, rol_nombre } = result.rows[0];
            
            // Verificar si el usuario tiene el permiso específico
            const tienePermiso = permisos?.[recurso]?.[accion] === true;
            
            if (!tienePermiso) {
                return res.status(403).json({
                    success: false,
                    message: `No tienes permisos para ${accion} ${recurso}`,
                    rolActual: rol_nombre
                });
            }

            // Agregar información de permisos al request para usar en la ruta
            req.userPermissions = permisos;
            req.userRole = rol_nombre;
            next();

        } catch (error) {
            console.error('❌ Error verificando permisos:', error);
            res.status(500).json({
                success: false,
                message: 'Error interno verificando permisos'
            });
        }
    };
};

// Middleware para verificar solo rol de administrador
const verificarAdmin = async (req, res, next) => {
    try {
        // Obtener userId del body, del header x-user-id, o del Authorization header
        let userId = req.body.userId || req.headers['x-user-id'];
        
        // Intentar extraer el ID del token de autorización si está presente
        const authHeader = req.headers['authorization'];
        if (!userId && authHeader && authHeader.startsWith('Bearer ')) {
            try {
                const token = authHeader.split(' ')[1];
                // Aquí normalmente verificaríamos el token JWT, pero para simplificar
                // vamos a extraer el ID del usuario de los headers
                userId = req.headers['x-user-id'];
            } catch (e) {
                console.log('❌ Error al extraer datos del token:', e.message);
            }
        }
        
        console.log('🔍 Verificando admin - userId:', userId);
        
        if (!userId) {
            console.log('❌ No se proporcionó userId');
            return res.status(401).json({
                success: false,
                message: 'ID de usuario requerido'
            });
        }

        const result = await pool.query(`
            SELECT r.nombre as rol_nombre
            FROM usuarios u
            JOIN roles r ON u.id_rol = r.id
            WHERE u.id = $1
        `, [userId]);

        console.log('🔍 Resultado de consulta de rol:', result.rows);

        if (result.rows.length === 0 || result.rows[0].rol_nombre !== 'administrador') {
            console.log('❌ Acceso denegado - no es administrador');
            return res.status(403).json({
                success: false,
                message: 'Acceso denegado. Solo administradores.'
            });
        }

        console.log('✅ Usuario verificado como administrador');
        next();

    } catch (error) {
        console.error('❌ Error verificando admin:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno verificando permisos de administrador'
        });
    }
};

// ==========================================
// RUTAS PARA GESTIÓN DE ROLES
// ==========================================

// Obtener información de roles disponibles
router.get('/roles', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT id, nombre, descripcion, permisos, activo
            FROM roles
            WHERE activo = true
            ORDER BY id
        `);

        res.json({
            success: true,
            roles: result.rows
        });

    } catch (error) {
        console.error('❌ Error obteniendo roles:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno obteniendo roles'
        });
    }
});

// Obtener permisos de un usuario específico
router.post('/user-permissions', async (req, res) => {
    try {
        const { userId } = req.body;
        
        if (!userId) {
            return res.status(400).json({
                success: false,
                message: 'ID de usuario requerido'
            });
        }

        const result = await pool.query(`
            SELECT 
                u.id, 
                u.nombres, 
                u.apellidos, 
                u.correo,
                r.id as rol_id,
                r.nombre as rol_nombre,
                r.descripcion as rol_descripcion,
                r.permisos as rol_permisos
            FROM usuarios u
            LEFT JOIN roles r ON u.id_rol = r.id
            WHERE u.id = $1
        `, [userId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado'
            });
        }

        const user = result.rows[0];
        
        res.json({
            success: true,
            user: {
                id: user.id,
                nombres: user.nombres,
                apellidos: user.apellidos,
                correo: user.correo,
                rol: {
                    id: user.rol_id,
                    nombre: user.rol_nombre || 'usuario',
                    descripcion: user.rol_descripcion || 'Usuario normal',
                    permisos: user.rol_permisos || {}
                }
            }
        });

    } catch (error) {
        console.error('❌ Error obteniendo permisos de usuario:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno obteniendo permisos'
        });
    }
});

// Cambiar rol de un usuario (solo administradores)
router.put('/change-user-role', verificarAdmin, async (req, res) => {
    try {
        const { targetUserId, newRoleId } = req.body;
        
        if (!targetUserId || !newRoleId) {
            return res.status(400).json({
                success: false,
                message: 'ID de usuario y nuevo rol son requeridos'
            });
        }

        // Verificar que el rol existe
        const roleCheck = await pool.query('SELECT nombre FROM roles WHERE id = $1', [newRoleId]);
        if (roleCheck.rows.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'El rol especificado no existe'
            });
        }

        // Actualizar rol del usuario
        const result = await pool.query(`
            UPDATE usuarios 
            SET id_rol = $1
            WHERE id = $2
            RETURNING id, nombres, apellidos
        `, [newRoleId, targetUserId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado'
            });
        }

        const updatedUser = result.rows[0];
        const newRoleName = roleCheck.rows[0].nombre;

        res.json({
            success: true,
            message: `Rol de ${updatedUser.nombres} ${updatedUser.apellidos} cambiado a ${newRoleName}`,
            user: {
                id: updatedUser.id,
                nombres: updatedUser.nombres,
                apellidos: updatedUser.apellidos,
                nuevoRol: newRoleName
            }
        });

    } catch (error) {
        console.error('❌ Error cambiando rol de usuario:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno cambiando rol'
        });
    }
});

// Listar todos los usuarios con sus roles (solo administradores)
router.post('/users-list', verificarAdmin, async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT 
                u.id,
                u.nombres,
                u.apellidos,
                u.correo,
                u.verificado,
                u.fecha_registro,
                r.id as rol_id,
                r.nombre as rol_nombre,
                r.descripcion as rol_descripcion
            FROM usuarios u
            LEFT JOIN roles r ON u.id_rol = r.id
            ORDER BY u.fecha_registro DESC
        `);

        const users = result.rows.map(user => ({
            id: user.id,
            nombres: user.nombres,
            apellidos: user.apellidos,
            correo: user.correo,
            verificado: user.verificado,
            fechaRegistro: user.fecha_registro,
            rol: {
                id: user.rol_id,
                nombre: user.rol_nombre || 'usuario',
                descripcion: user.rol_descripcion || 'Usuario normal'
            }
        }));

        res.json({
            success: true,
            users,
            total: users.length
        });

    } catch (error) {
        console.error('❌ Error listando usuarios:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno listando usuarios'
        });
    }
});

// Ruta para obtener usuarios para el CRUD (GET)
router.get('/admin/users', verificarAdmin, async (req, res) => {
    try {
        console.log('🔍 Iniciando consulta de usuarios para CRUD...');
        
        const result = await pool.query(`
            SELECT 
                u.id,
                u.nombres,
                u.apellidos,
                u.correo,
                u.verificado,
                u.fecha_registro,
                u.foto_perfil_url,
                u.ultima_conexion,
                COALESCE(
                    (SELECT COUNT(*) FROM mascotas WHERE id_usuario = u.id), 0
                ) as mascotas
            FROM usuarios u
            ORDER BY u.fecha_registro DESC
        `);

        console.log(`✅ Consulta exitosa. ${result.rows.length} usuarios encontrados.`);

        const users = result.rows.map(user => ({
            id: user.id,
            nombres: user.nombres,
            apellidos: user.apellidos,
            correo: user.correo,
            verificado: user.verificado,
            fecha_registro: user.fecha_registro,
            ultima_conexion: user.ultima_conexion ? user.ultima_conexion.toISOString() : null,
            foto_perfil_url: user.foto_perfil_url,
            mascotas: user.mascotas
        }));

        res.json({
            success: true,
            users,
            total: users.length
        });

    } catch (error) {
        console.error('❌ Error obteniendo usuarios para CRUD:', error);
        console.error('❌ Stack trace:', error.stack);
        res.status(500).json({
            success: false,
            message: 'Error interno obteniendo usuarios: ' + error.message
        });
    }
});

// Ruta para activar/desactivar usuario (PATCH)
router.patch('/admin/users/:id/active', verificarAdmin, async (req, res) => {
    try {
        const { id } = req.params;
        const { verificado } = req.body;

        const result = await pool.query(
            'UPDATE usuarios SET verificado = $1 WHERE id = $2 RETURNING *',
            [verificado, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado'
            });
        }

        res.json({
            success: true,
            message: verificado ? 'Usuario activado correctamente' : 'Usuario desactivado correctamente',
            user: result.rows[0]
        });

    } catch (error) {
        console.error('❌ Error cambiando estado del usuario:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno cambiando estado del usuario'
        });
    }
});

// Ruta para editar usuario (PUT)
router.put('/admin/users/:id', verificarAdmin, async (req, res) => {
    try {
        const { id } = req.params;
        const { nombres, apellidos, correo } = req.body;

        const result = await pool.query(
            'UPDATE usuarios SET nombres = $1, apellidos = $2, correo = $3 WHERE id = $4 RETURNING *',
            [nombres, apellidos, correo, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado'
            });
        }

        res.json({
            success: true,
            message: 'Usuario actualizado correctamente',
            user: result.rows[0]
        });

    } catch (error) {
        console.error('❌ Error editando usuario:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno editando usuario'
        });
    }
});

// Ruta para eliminar usuario (DELETE)
router.delete('/admin/users/:id', verificarAdmin, async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            'DELETE FROM usuarios WHERE id = $1 RETURNING *',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado'
            });
        }

        res.json({
            success: true,
            message: 'Usuario eliminado correctamente'
        });

    } catch (error) {
        console.error('❌ Error eliminando usuario:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno eliminando usuario'
        });
    }
});

// === ENDPOINT PARA ACTUALIZAR ÚLTIMA CONEXIÓN (HEARTBEAT) ===
router.post('/heartbeat', async (req, res) => {
    try {
        const userId = req.headers['x-user-id'];
        
        if (!userId) {
            return res.status(401).json({
                success: false,
                message: 'Usuario no autenticado'
            });
        }

        // Actualizar ultima_conexion
        await pool.query(`
            UPDATE usuarios 
            SET ultima_conexion = CURRENT_TIMESTAMP 
            WHERE id = $1
        `, [userId]);

        res.json({
            success: true,
            message: 'Última conexión actualizada'
        });

    } catch (error) {
        console.error('❌ Error actualizando última conexión:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// === ENDPOINT PARA OBTENER ESTADÍSTICAS ===
router.get('/admin/statistics', verificarAdmin, async (req, res) => {
    try {
        console.log('🔍 Obteniendo estadísticas del sistema...');

        // Inicializar estadísticas con valores por defecto
        let statistics = {
            totalUsuarios: 0,
            usuariosActivos: 0,
            totalMascotas: 0,
            usuariosOnline: 0,
            sesionesHoy: 0,
            sesionesEstaSemana: 0,
            registrosPorMes: [],
            iniciosSesionPorDia: []
        };

        try {
            // Total de usuarios
            const totalUsuarios = await pool.query('SELECT COUNT(*) as total FROM usuarios');
            statistics.totalUsuarios = parseInt(totalUsuarios.rows[0].total) || 0;

            // Usuarios activos (verificados)
            const usuariosActivos = await pool.query('SELECT COUNT(*) as total FROM usuarios WHERE verificado = true');
            statistics.usuariosActivos = parseInt(usuariosActivos.rows[0].total) || 0;

            // Total de mascotas
            const totalMascotas = await pool.query('SELECT COUNT(*) as total FROM mascotas');
            statistics.totalMascotas = parseInt(totalMascotas.rows[0].total) || 0;

            // Usuarios online (conectados en los últimos 5 minutos)
            const usuariosOnline = await pool.query(`
                SELECT COUNT(*) as total 
                FROM usuarios 
                WHERE ultima_conexion > NOW() - INTERVAL '5 minutes'
            `);
            statistics.usuariosOnline = parseInt(usuariosOnline.rows[0].total) || 0;

            // Sesiones hoy
            const sesionesHoy = await pool.query(`
                SELECT COUNT(*) as total 
                FROM usuarios 
                WHERE DATE(ultima_conexion) = CURRENT_DATE
            `);
            statistics.sesionesHoy = parseInt(sesionesHoy.rows[0].total) || 0;

            // Sesiones esta semana
            const sesionesEstaSemana = await pool.query(`
                SELECT COUNT(*) as total 
                FROM usuarios 
                WHERE ultima_conexion > NOW() - INTERVAL '7 days'
            `);
            statistics.sesionesEstaSemana = parseInt(sesionesEstaSemana.rows[0].total) || 0;

            // Registros por mes (últimos 6 meses)
            const registrosPorMes = await pool.query(`
                SELECT 
                    TO_CHAR(fecha_registro, 'YYYY-MM') as mes,
                    COUNT(*) as count
                FROM usuarios 
                WHERE fecha_registro > NOW() - INTERVAL '6 months'
                GROUP BY TO_CHAR(fecha_registro, 'YYYY-MM')
                ORDER BY mes ASC
            `);
            statistics.registrosPorMes = registrosPorMes.rows.map(row => ({
                mes: row.mes,
                count: parseInt(row.count)
            }));

            // Inicios de sesión por día (últimos 7 días)
            const iniciosSesionPorDia = await pool.query(`
                SELECT 
                    DATE(ultima_conexion) as fecha,
                    COUNT(DISTINCT id) as count
                FROM usuarios 
                WHERE ultima_conexion > NOW() - INTERVAL '7 days'
                    AND ultima_conexion IS NOT NULL
                GROUP BY DATE(ultima_conexion)
                ORDER BY fecha ASC
            `);
            statistics.iniciosSesionPorDia = iniciosSesionPorDia.rows.map(row => ({
                fecha: row.fecha ? row.fecha.toISOString().split('T')[0] : null,
                count: parseInt(row.count)
            })).filter(item => item.fecha);

        } catch (queryError) {
            console.log('⚠️ Error en consultas específicas:', queryError.message);
            // Las estadísticas ya están inicializadas con valores por defecto
        }

        console.log('✅ Estadísticas obtenidas exitosamente');

        res.json({
            success: true,
            statistics
        });

    } catch (error) {
        console.error('❌ Error obteniendo estadísticas:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor: ' + error.message
        });
    }
});

// 📌 Ruta GET para buscar un usuario por ID (para el chat)
router.get('/user/:id', async (req, res) => {
    const { id } = req.params;
    
    try {
        // Validar que el ID sea un número válido
        const userId = parseInt(id);
        if (isNaN(userId) || userId <= 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'ID de usuario inválido' 
            });
        }

        // Buscar el usuario en la base de datos
        const result = await pool.query(
            `SELECT id, nombres, apellidos, correo, genero, ubicacion, 
                    fecha_nacimiento, foto_perfil_url, ultima_conexion
             FROM usuarios 
             WHERE id = $1`,
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'Usuario no encontrado' 
            });
        }

        const user = result.rows[0];
        
        // Formatear la respuesta
        res.json({ 
            success: true, 
            user: {
                id: user.id,
                nombres: user.nombres,
                apellidos: user.apellidos,
                correo: user.correo,
                genero: user.genero,
                ubicacion: user.ubicacion,
                fecha_nacimiento: user.fecha_nacimiento,
                foto_perfil_url: user.foto_perfil_url,
                ultima_conexion: user.ultima_conexion
            }
        });

    } catch (err) {
        console.error('❌ Error al buscar usuario:', err);
        res.status(500).json({ 
            success: false, 
            message: 'Error interno del servidor: ' + err.message 
        });
    }
});

module.exports = router;