const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// CREATE mascota
router.post('/', async (req, res) => {
    try {
        const { nombre, edad, tipo_animal, raza, foto_url, id_duenio, state } = req.body;
        const result = await pool.query(
            `INSERT INTO mascotas (nombre, edad, tipo_animal, raza, foto_url, id_duenio, state)
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [nombre, edad, tipo_animal, raza, foto_url, id_duenio, state]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// READ all mascotas
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM mascotas');
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// READ one mascota
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM mascotas WHERE id = $1', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Mascota no encontrada' });
        }
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// UPDATE mascota
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, edad, tipo_animal, raza, foto_url, id_duenio, state } = req.body;
        const result = await pool.query(
            `UPDATE mascotas SET nombre=$1, edad=$2, tipo_animal=$3, raza=$4, foto_url=$5, id_duenio=$6, state=$7 WHERE id=$8 RETURNING *`,
            [nombre, edad, tipo_animal, raza, foto_url, id_duenio, state, id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Mascota no encontrada' });
        }
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE mascota
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM mascotas WHERE id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Mascota no encontrada' });
        }
        res.json({ mensaje: 'Mascota eliminada', mascota: result.rows[0] });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
