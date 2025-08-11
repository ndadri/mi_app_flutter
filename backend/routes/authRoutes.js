const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Configura tu conexión a la base de datos
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Ruta POST para registrar un usuario
router.post('/registrar', async (req, res) => {
    try {
        console.log('📝 Datos recibidos:', JSON.stringify(req.body, null, 2));
        
        let { nombres, apellidos, correo, contraseña, genero, ubicacion, fecha_nacimiento, coordenadas } = req.body;

        // Validaciones básicas
        nombres = typeof nombres === 'string' ? nombres.trim() : '';
        apellidos = typeof apellidos === 'string' ? apellidos.trim() : '';
        correo = typeof correo === 'string' ? correo.trim().toLowerCase() : '';
        contraseña = typeof contraseña === 'string' ? contraseña : '';
        genero = typeof genero === 'string' ? genero.trim() : '';
        ubicacion = typeof ubicacion === 'string' ? ubicacion.trim() : '';

        console.log('🔍 Contraseña procesada:', { 
            original: req.body.contraseña, 
            processed: contraseña, 
            length: contraseña.length,
            type: typeof contraseña
        });

        // Validar nombres
        if (!nombres || nombres.length === 0) {
            return res.status(400).json({ mensaje: 'Los nombres son obligatorios.' });
        }

        // Validar apellidos
        if (!apellidos || apellidos.length === 0) {
            return res.status(400).json({ mensaje: 'Los apellidos son obligatorios.' });
        }

        // Validar correo electrónico
        const emailRegex = /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/;
        if (!correo || !emailRegex.test(correo)) {
            return res.status(400).json({ mensaje: 'El correo electrónico no es válido.' });
        }

        // Validar contraseña
        if (!contraseña || contraseña.length < 6) {
            return res.status(400).json({ mensaje: 'La contraseña debe tener al menos 6 caracteres.' });
        }

        // Validar género
        const generosValidos = ['Hombre', 'Mujer', 'No Binario', 'Prefiero no decirlo'];
        if (!genero || !generosValidos.includes(genero)) {
            return res.status(400).json({ mensaje: 'Género no válido. Valores permitidos: Hombre, Mujer, No Binario, Prefiero no decirlo' });
        }

        // Validar ubicación
        if (!ubicacion || ubicacion.length === 0) {
            return res.status(400).json({ mensaje: 'La ubicación es obligatoria.' });
        }

        // Validar fecha_nacimiento (formato YYYY-MM-DD)
        const fechaRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!fecha_nacimiento || typeof fecha_nacimiento !== 'string' || !fechaRegex.test(fecha_nacimiento)) {
            return res.status(400).json({ mensaje: 'La fecha de nacimiento debe tener el formato YYYY-MM-DD.' });
        }

        // Verificar si el correo ya existe
        const emailCheck = await pool.query('SELECT id FROM usuarios WHERE correo = $1', [correo]);
        if (emailCheck.rows.length > 0) {
            return res.status(400).json({ mensaje: 'Este correo electrónico ya está registrado.' });
        }

        // Encriptar la contraseña
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(contraseña, saltRounds);

        // Preparar coordenadas (opcional)
        let latitud = null;
        let longitud = null;
        if (coordenadas && coordenadas.latitud && coordenadas.longitud) {
            latitud = parseFloat(coordenadas.latitud);
            longitud = parseFloat(coordenadas.longitud);
        }

        // Insertar el usuario en la base de datos
        const query = `
            INSERT INTO usuarios (nombres, apellidos, correo, contraseña, genero, ubicacion, fecha_nacimiento, latitud, longitud)
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

        const result = await pool.query(query, values);
        console.log('✅ Usuario insertado exitosamente:', result.rows[0]);

        // Devolver respuesta exitosa
        const usuario = result.rows[0];
        res.status(201).json({
            mensaje: 'Usuario registrado exitosamente.',
            usuario
        });
    } catch (error) {
        console.error('❌ Error completo al registrar usuario:', error);
        console.error('❌ Stack trace:', error.stack);
        console.error('❌ Query que falló:', error.query || 'No query info');
        res.status(500).json({ mensaje: 'Error interno del servidor: ' + error.message });
    }
});

// Ruta POST para iniciar sesión

router.post('/login', async (req, res) => {
    try {
        console.log('🔐 Intento de login:', JSON.stringify(req.body, null, 2));
        
        let { username, password } = req.body;

        // Validaciones básicas
        username = typeof username === 'string' ? username.trim() : '';
        password = typeof password === 'string' ? password : '';

        if (!username || !password) {
            return res.status(400).json({ 
                success: false,
                message: 'Usuario y contraseña son obligatorios.' 
            });
        }

        // Buscar usuario por correo o nombres
        const userQuery = `
            SELECT id, nombres, apellidos, correo, contraseña, genero, ubicacion, fecha_nacimiento
            FROM usuarios 
            WHERE correo = $1 OR nombres = $1
        `;
        const userResult = await pool.query(userQuery, [username]);

        if (userResult.rows.length === 0) {
            return res.status(401).json({ 
                success: false,
                message: 'Usuario no encontrado.' 
            });
        }

        const user = userResult.rows[0];

        // Verificar contraseña
        const isValidPassword = await bcrypt.compare(password, user.contraseña);

        if (!isValidPassword) {
            return res.status(401).json({ 
                success: false,
                message: 'Contraseña incorrecta.' 
            });
        }

        // Generar JWT
        const token = jwt.sign(
            { userId: user.id, correo: user.correo, nombres: user.nombres },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        // Login exitoso
        console.log('✅ Login exitoso para usuario:', user.nombres);
        
        // Eliminar la contraseña de la respuesta
        const { contraseña, ...userWithoutPassword } = user;
        
        res.status(200).json({
            success: true,
            message: `¡Bienvenido ${user.nombres}!`,
            user: userWithoutPassword,
            token // <-- Aquí se retorna el JWT
        });

    } catch (error) {
        console.error('❌ Error en login:', error);
        res.status(500).json({ 
            success: false,
            message: 'Error interno del servidor: ' + error.message 
        });
    }
});