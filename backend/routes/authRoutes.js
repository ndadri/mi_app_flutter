const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const bcrypt = require('bcrypt');

// Configura tu conexión a la base de datos
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Ruta POST para registrar un usuario
router.post('/registrar', async (req, res) => {
    try {
        let { nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state } = req.body;

        // Validaciones básicas
        nombre = typeof nombre === 'string' ? nombre.trim() : '';
        ubicacion = typeof ubicacion === 'string' ? ubicacion.trim() : '';
        email = typeof email === 'string' ? email.trim().toLowerCase() : '';
        contraseña = typeof contraseña === 'string' ? contraseña : '';
        state = typeof state === 'string' ? state.trim().toLowerCase() : '';

        // Validar nombre
        if (!nombre || nombre.length === 0) {
            return res.status(400).json({ mensaje: 'El nombre es obligatorio.' });
        }
        // Validar edad
        const edadNum = Number(edad);
        if (!edad || isNaN(edadNum) || !Number.isInteger(edadNum) || edadNum <= 0) {
            return res.status(400).json({ mensaje: 'La edad debe ser un número entero positivo.' });
        }
        // Validar ubicacion
        if (!ubicacion || ubicacion.length === 0) {
            return res.status(400).json({ mensaje: 'La ubicación es obligatoria.' });
        }
        // Validar fecha_nacimiento (formato YYYY-MM-DD)
        const fechaRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!fecha_nacimiento || typeof fecha_nacimiento !== 'string' || !fechaRegex.test(fecha_nacimiento)) {
            return res.status(400).json({ mensaje: 'La fecha de nacimiento debe tener el formato YYYY-MM-DD.' });
        }
        // Validar email
        const emailRegex = /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/;
        if (!email || !emailRegex.test(email)) {
            return res.status(400).json({ mensaje: 'El email no es válido.' });
        }
        // Validar contraseña
        if (!contraseña || contraseña.length < 6) {
            return res.status(400).json({ mensaje: 'La contraseña debe tener al menos 6 caracteres.' });
        }
        // Validar state
        if (!['verificado', 'no'].includes(state)) {
            return res.status(400).json({ mensaje: "El estado debe ser 'verificado' o 'no'." });
        }

        // Encriptar la contraseña
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(contraseña, saltRounds);

        // Insertar el usuario en la base de datos
        const query = `
            INSERT INTO usuarios (nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *
        `;
        const values = [
            nombre,
            edadNum,
            ubicacion,
            fecha_nacimiento,
            email,
            hashedPassword,
            state
        ];

        const result = await pool.query(query, values);

        // Devuelve el id del usuario para usar como id_duenio en petRoutes
        res.status(201).json({
            mensaje: 'Usuario registrado exitosamente.',
            usuario: result.rows[0],
            id_duenio: result.rows[0].id // Asumiendo que la columna primaria es 'id'
        });
    } catch (error) {
        console.error('Error al registrar usuario:', error);
        res.status(500).json({ mensaje: 'Error interno del servidor.' });
    }
});

module.exports = router;
