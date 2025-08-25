const express = require('express');
const router = express.Router();
const globalConfig = require('../globalConfig');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Configura tu conexión a la base de datos
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Rutas para parámetros globales
router.get('/global-config', async (req, res) => {
    try {
        const config = await globalConfig.getGlobalConfig();
        res.json({ success: true, config });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error al obtener configuración global.' });
    }
});

router.post('/global-config', async (req, res) => {
    try {
        await globalConfig.updateGlobalConfig(req.body);
        res.json({ success: true, message: 'Configuración actualizada.' });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error al actualizar configuración global.' });
    }
});

// Ruta POST para registrar un usuario
router.post('/registrar', async (req, res) => {
    try {
        console.log('📝 [REGISTRO] Datos recibidos:', JSON.stringify(req.body, null, 2));
        let { nombres, apellidos, correo, password, genero, ubicacion, fecha_nacimiento, coordenadas } = req.body;

        // Validaciones básicas
        nombres = typeof nombres === 'string' ? nombres.trim() : '';
        apellidos = typeof apellidos === 'string' ? apellidos.trim() : '';
        correo = typeof correo === 'string' ? correo.trim().toLowerCase() : '';
        password = typeof password === 'string' ? password : '';
        genero = typeof genero === 'string' ? genero.trim() : '';
        ubicacion = typeof ubicacion === 'string' ? ubicacion.trim() : '';

        console.log('🔍 [REGISTRO] Contraseña procesada:', { 
            original: req.body.password, 
            processed: password, 
            length: password.length,
            type: typeof password
        });

        // Validar nombres
        if (!nombres || nombres.length === 0) {
            console.log('❌ [REGISTRO] Faltan nombres');
            return res.status(400).json({ mensaje: 'Los nombres son obligatorios.' });
        }

        // Validar apellidos
        if (!apellidos || apellidos.length === 0) {
            console.log('❌ [REGISTRO] Faltan apellidos');
            return res.status(400).json({ mensaje: 'Los apellidos son obligatorios.' });
        }

        // Validar correo electrónico
        const emailRegex = /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/;
        if (!correo || !emailRegex.test(correo)) {
            console.log('❌ [REGISTRO] Correo no válido:', correo);
            return res.status(400).json({ mensaje: 'El correo electrónico no es válido.' });
        }

        // Validar contraseña
        if (!password || password.length < 6) {
            console.log('❌ [REGISTRO] Contraseña muy corta o vacía');
            return res.status(400).json({ mensaje: 'La contraseña debe tener al menos 6 caracteres.' });
        }

        // Validar género
        const generosValidos = ['Masculino', 'Femenino', 'Otro'];
        if (!genero || !generosValidos.includes(genero)) {
            console.log('❌ [REGISTRO] Género no válido:', genero);
            return res.status(400).json({ mensaje: 'Género no válido. Valores permitidos: Masculino, Femenino, Otro' });
        }

        // Validar ubicación
        if (!ubicacion || ubicacion.length === 0) {
            console.log('❌ [REGISTRO] Ubicación vacía');
            return res.status(400).json({ mensaje: 'La ubicación es obligatoria.' });
        }

        // Validar fecha_nacimiento (formato YYYY-MM-DD)
        const fechaRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!fecha_nacimiento || typeof fecha_nacimiento !== 'string' || !fechaRegex.test(fecha_nacimiento)) {
            console.log('❌ [REGISTRO] Fecha de nacimiento inválida:', fecha_nacimiento);
            return res.status(400).json({ mensaje: 'La fecha de nacimiento debe tener el formato YYYY-MM-DD.' });
        }

        // Verificar si el correo ya existe
        const emailCheck = await pool.query('SELECT id FROM usuarios WHERE correo = $1', [correo]);
        if (emailCheck.rows.length > 0) {
            console.log('❌ [REGISTRO] Correo ya registrado:', correo);
            return res.status(400).json({ mensaje: 'Este correo electrónico ya está registrado.' });
        }

        // Encriptar la contraseña
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        // Generar username automáticamente basado en nombres (temporalmente comentado)
        let username = nombres.toLowerCase().replace(/\s+/g, '');
        console.log(`📝 [REGISTRO] Username que se generaría: ${username}`);

        // Preparar coordenadas (opcional)
        let latitud = null;
        let longitud = null;
        if (coordenadas && coordenadas.latitud && coordenadas.longitud) {
            latitud = parseFloat(coordenadas.latitud);
            longitud = parseFloat(coordenadas.longitud);
        }

        // Insertar el usuario en la base de datos (sin username temporalmente)
        const query = `
            INSERT INTO usuarios (nombres, apellidos, correo, password, genero, ubicacion, fecha_nacimiento, latitud, longitud)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            RETURNING id, nombres, apellidos, correo, genero, ubicacion, fecha_nacimiento
        `;
        const values = [
            nombres,
            apellidos,
            correo,
            hashedPassword,
            genero,
            ubicacion,
            fecha_nacimiento,
            latitud,
            longitud
        ];

        let result;
        try {
            result = await pool.query(query, values);
        } catch (dbError) {
            console.error('❌ [REGISTRO] Error al insertar usuario en la base de datos:', dbError);
            return res.status(500).json({ mensaje: 'Error al guardar el usuario en la base de datos.', detalle: dbError.message });
        }
        console.log('✅ [REGISTRO] Usuario insertado exitosamente:', result.rows[0]);

        // Devolver respuesta exitosa
        const usuario = result.rows[0];
        res.status(201).json({
            mensaje: 'Usuario registrado exitosamente.',
            usuario
        });
    } catch (error) {
        console.error('❌ [REGISTRO] Error completo al registrar usuario:', error);
        console.error('❌ [REGISTRO] Stack trace:', error.stack);
        console.error('❌ [REGISTRO] Query que falló:', error.query || 'No query info');
        res.status(500).json({ mensaje: 'Error interno del servidor: ' + error.message, detalle: error.stack });
    }
});

// Ruta POST para iniciar sesión
router.post('/login', async (req, res) => {
    try {

        let { correo, password } = req.body;

        correo = typeof correo === 'string' ? correo.trim().toLowerCase() : '';
        password = typeof password === 'string' ? password : '';

        if (!correo || !password) {
            return res.status(400).json({
                success: false,
                message: 'Correo y contraseña son obligatorios.'
            });
        }

        // Buscar usuario solo por correo
        const userQuery = `
            SELECT id, nombres, apellidos, correo, password, genero, ubicacion, fecha_nacimiento, verificado, codigo_verificacion, fecha_registro, fecha_verificacion, latitud, longitud, foto_perfil_url, edad, id_rol, ultima_conexion
            FROM usuarios
            WHERE correo = $1
            LIMIT 1
        `;
        const userResult = await pool.query(userQuery, [correo]);

        if (userResult.rows.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'Usuario no encontrado.'
            });
        }

        const user = userResult.rows[0];

        // Verificar contraseña
        const isValidPassword = await bcrypt.compare(password, user.password);

        if (!isValidPassword) {
            return res.status(401).json({
                success: false,
                message: 'Contraseña incorrecta.'
            });
        }

        // Generar JWT
        const token = jwt.sign(
            { userId: user.id, correo: user.correo },
            process.env.JWT_SECRET || 'fallback_secret',
            { expiresIn: '7d' }
        );

        // Login exitoso
        res.status(200).json({
            success: true,
            message: 'Login exitoso',
            user: {
                id: user.id,
                nombres: user.nombres,
                apellidos: user.apellidos,
                correo: user.correo,
                genero: user.genero,
                ubicacion: user.ubicacion,
                fecha_nacimiento: user.fecha_nacimiento,
                verificado: user.verificado,
                codigo_verificacion: user.codigo_verificacion,
                fecha_registro: user.fecha_registro,
                fecha_verificacion: user.fecha_verificacion,
                latitud: user.latitud,
                longitud: user.longitud,
                foto_perfil_url: user.foto_perfil_url,
                edad: user.edad,
                id_rol: user.id_rol,
                ultima_conexion: user.ultima_conexion
            },
            token
        });

    } catch (error) {
        console.error('❌ Error en login:', error.message);
        res.status(500).json({ 
            success: false,
            message: 'Error interno del servidor' 
        });
    }
});

// Ruta POST para login social (Google/Facebook)
router.post('/social-login', async (req, res) => {
    try {
        let { email, name, provider, photoURL } = req.body;

        // Validaciones básicas
        email = typeof email === 'string' ? email.trim().toLowerCase() : '';
        name = typeof name === 'string' ? name.trim() : '';
        provider = typeof provider === 'string' ? provider.trim() : '';

        if (!email || !name || !provider) {
            return res.status(400).json({ 
                success: false,
                message: 'Email, nombre y proveedor son obligatorios.' 
            });
        }

        // Buscar si el usuario ya existe (consulta optimizada)
        const userQuery = `
            SELECT id, nombres, apellidos, correo, genero, ubicacion, fecha_nacimiento
            FROM usuarios 
            WHERE correo = $1
            LIMIT 1
        `;
        const userResult = await pool.query(userQuery, [email]);

        let user;
        
        if (userResult.rows.length > 0) {
            // Usuario existe
            user = userResult.rows[0];
        } else {
            // Usuario nuevo, crear registro optimizado
            const insertQuery = `
                INSERT INTO usuarios (nombres, apellidos, correo, password, genero, ubicacion, fecha_nacimiento)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                RETURNING id, nombres, apellidos, correo, genero, ubicacion, fecha_nacimiento
            `;
            
            // Separar nombre en nombres y apellidos
            const nameParts = name.split(' ');
            const firstName = nameParts[0] || name;
            const lastName = nameParts.slice(1).join(' ') || '';
            
            // Contraseña temporal para usuarios sociales
            const tempPassword = await bcrypt.hash('social_' + Date.now(), 5); // Menos rounds para más velocidad
            
            const insertResult = await pool.query(insertQuery, [
                firstName,
                lastName,
                email,
                tempPassword,
                'Prefiero no decirlo',
                'No especificada',
                '2000-01-01'
            ]);
            
            user = insertResult.rows[0];
        }

        // Generar JWT token optimizado
        const token = jwt.sign(
            { userId: user.id, correo: user.correo },
            process.env.JWT_SECRET || 'fallback_secret',
            { expiresIn: '7d' }
        );

        // Login exitoso - respuesta rápida
        res.status(200).json({
            success: true,
            message: 'Login exitoso',
            user: {
                id: user.id,
                nombres: user.nombres,
                apellidos: user.apellidos,
                correo: user.correo,
                genero: user.genero,
                ubicacion: user.ubicacion,
                fecha_nacimiento: user.fecha_nacimiento
            },
            token
        });

    } catch (error) {
        console.error('❌ Error en login social:', error.message);
        res.status(500).json({ 
            success: false,
            message: 'Error interno del servidor' 
        });
    }
});

// Ruta GET para obtener datos de usuario por ID
router.get('/usuarios/:id', async (req, res) => {
    try {
        const { id } = req.params;
        
        if (!id || isNaN(parseInt(id))) {
            return res.status(400).json({
                success: false,
                message: 'ID de usuario inválido'
            });
        }
        
        const userQuery = `
            SELECT id, nombres, apellidos, correo, genero, ubicacion, fecha_nacimiento
            FROM usuarios 
            WHERE id = $1
        `;
        const userResult = await pool.query(userQuery, [parseInt(id)]);
        
        if (userResult.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado'
            });
        }
        
        const user = userResult.rows[0];
        res.status(200).json({
            success: true,
            usuario: user
        });
        
    } catch (error) {
        console.error('❌ Error obteniendo usuario:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor: ' + error.message
        });
    }
});

// Ruta PUT para actualizar datos de usuario
router.put('/usuarios/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { nombres, apellidos, genero, ubicacion, fecha_nacimiento } = req.body;
        
        if (!id || isNaN(parseInt(id))) {
            return res.status(400).json({
                success: false,
                message: 'ID de usuario inválido'
            });
        }
        
        // Validar campos requeridos
        if (!nombres || !apellidos || !genero || !ubicacion || !fecha_nacimiento) {
            return res.status(400).json({
                success: false,
                message: 'Todos los campos son requeridos'
            });
        }
        
        const updateQuery = `
            UPDATE usuarios 
            SET nombres = $1, apellidos = $2, genero = $3, ubicacion = $4, fecha_nacimiento = $5
            WHERE id = $6
            RETURNING id, nombres, apellidos, correo, genero, ubicacion, fecha_nacimiento
        `;
        
        const result = await pool.query(updateQuery, [
            nombres, apellidos, genero, ubicacion, fecha_nacimiento, parseInt(id)
        ]);
        
        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Datos actualizados exitosamente',
            usuario: result.rows[0]
        });
        
    } catch (error) {
        console.error('❌ Error actualizando usuario:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor: ' + error.message
        });
    }
});

module.exports = router;