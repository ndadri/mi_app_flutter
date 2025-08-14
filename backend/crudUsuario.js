
const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const bcrypt = require('bcrypt');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Helper: validate email
function isValidEmail(email) {
    return /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/.test(email);
}

// CREATE usuario
router.post('/', async (req, res) => {
    try {
        let { nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state } = req.body;

        // Basic validation
        if (!nombre || !edad || !ubicacion || !fecha_nacimiento || !email || !contraseña || typeof state === 'undefined') {
            return res.status(400).json({ mensaje: 'Todos los campos son requeridos.' });
        }
        if (!isValidEmail(email)) {
            return res.status(400).json({ mensaje: 'Email no válido.' });
        }
        if (contraseña.length < 6) {
            return res.status(400).json({ mensaje: 'La contraseña debe tener al menos 6 caracteres.' });
        }
        // Validate state as boolean or string
        let stateBool;
        if (typeof state === 'boolean') {
            stateBool = state;
        } else if (typeof state === 'string') {
            state = state.trim().toLowerCase();
            if (state === 'verificado') stateBool = true;
            else if (state === 'no') stateBool = false;
            else return res.status(400).json({ mensaje: "El estado debe ser 'verificado' o 'no'." });
        } else {
            return res.status(400).json({ mensaje: "El estado debe ser 'verificado' o 'no'." });
        }

        // Check for duplicate email
        const exists = await pool.query('SELECT id FROM usuarios WHERE email = $1', [email]);
        if (exists.rows.length > 0) {
            return res.status(409).json({ mensaje: 'El email ya está registrado.' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(contraseña, 10);

        // Insert user
        const result = await pool.query(
            `INSERT INTO usuarios (nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state)
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [nombre, edad, ubicacion, fecha_nacimiento, email, hashedPassword, stateBool]
        );
        let usuario = result.rows[0];
        usuario.state = usuario.state ? 'verificado' : 'no';
        delete usuario.contraseña;
        res.status(201).json(usuario);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// READ all usuarios
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT id, nombre, edad, ubicacion, fecha_nacimiento, email, state FROM usuarios');
        // Convert state to string
        const usuarios = result.rows.map(u => ({ ...u, state: u.state ? 'verificado' : 'no' }));
        res.json(usuarios);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// READ one usuario
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT id, nombre, edad, ubicacion, fecha_nacimiento, email, state FROM usuarios WHERE id = $1', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        let usuario = result.rows[0];
        usuario.state = usuario.state ? 'verificado' : 'no';
        res.json(usuario);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// UPDATE usuario
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        let { nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state } = req.body;

        // Basic validation
        if (!nombre || !edad || !ubicacion || !fecha_nacimiento || !email || typeof state === 'undefined') {
            return res.status(400).json({ mensaje: 'Todos los campos son requeridos.' });
        }
        if (!isValidEmail(email)) {
            return res.status(400).json({ mensaje: 'Email no válido.' });
        }
        // Validate state as boolean or string
        let stateBool;
        if (typeof state === 'boolean') {
            stateBool = state;
        } else if (typeof state === 'string') {
            state = state.trim().toLowerCase();
            if (state === 'verificado') stateBool = true;
            else if (state === 'no') stateBool = false;
            else return res.status(400).json({ mensaje: "El estado debe ser 'verificado' o 'no'." });
        } else {
            return res.status(400).json({ mensaje: "El estado debe ser 'verificado' o 'no'." });
        }

        // Hash password if provided
        let hashedPassword = contraseña;
        if (contraseña && contraseña.length >= 6) {
            hashedPassword = await bcrypt.hash(contraseña, 10);
        }

        const result = await pool.query(
            `UPDATE usuarios SET nombre=$1, edad=$2, ubicacion=$3, fecha_nacimiento=$4, email=$5, contraseña=$6, state=$7 WHERE id=$8 RETURNING *`,
            [nombre, edad, ubicacion, fecha_nacimiento, email, hashedPassword, stateBool, id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        let usuario = result.rows[0];
        usuario.state = usuario.state ? 'verificado' : 'no';
        delete usuario.contraseña;
        res.json(usuario);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE usuario
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM usuarios WHERE id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        let usuario = result.rows[0];
        usuario.state = usuario.state ? 'verificado' : 'no';
        delete usuario.contraseña;
        res.json({ mensaje: 'Usuario eliminado', usuario });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
