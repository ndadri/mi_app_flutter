const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// CREATE usuario
router.post('/', async (req, res) => {
    try {
        const { nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state } = req.body;
        const result = await pool.query(
            `INSERT INTO usuarios (nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state)
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// READ all usuarios
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM usuarios');
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// READ one usuario
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM usuarios WHERE id = $1', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// UPDATE usuario
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state } = req.body;
        const result = await pool.query(
            `UPDATE usuarios SET nombre=$1, edad=$2, ubicacion=$3, fecha_nacimiento=$4, email=$5, contraseña=$6, state=$7 WHERE id=$8 RETURNING *`,
            [nombre, edad, ubicacion, fecha_nacimiento, email, contraseña, state, id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        res.json(result.rows[0]);
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
        res.json({ mensaje: 'Usuario eliminado', usuario: result.rows[0] });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
