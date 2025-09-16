const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const bcrypt = require('bcrypt');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Helper: validate email
function isValidEmail(correo) {
    return /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/.test(correo);
}

// Registro de usuario solo por /api/auth/registrar. Este endpoint es solo para administración/consulta.

// Endpoint para obtener el total de usuarios registrados
router.get('/total', async (req, res) => {
    try {
        const result = await pool.query('SELECT COUNT(*) AS total FROM usuarios');
        const total = parseInt(result.rows[0].total, 10);
        res.json({ total });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint para obtener el total de usuarios activos (verificado=true)
router.get('/activos', async (req, res) => {
    try {
        const result = await pool.query("SELECT COUNT(*) AS total FROM usuarios WHERE verificado = true");
        const total = parseInt(result.rows[0].total, 10);
        res.json({ total });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ...endpoint de usuarios online eliminado...

router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT id, nombres, edad, ubicacion, fecha_nacimiento, correo, verificado FROM usuarios');
        // Convert verificado to string
        const usuarios = result.rows.map(u => ({ ...u, verificado: u.verificado ? 'verificado' : 'no' }));
        res.json(usuarios);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// READ one usuario
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        // Validar que id sea un número
        if (isNaN(parseInt(id))) {
            return res.status(400).json({ error: 'ID inválido, debe ser un número.' });
        }
        const result = await pool.query('SELECT id, nombres, edad, ubicacion, fecha_nacimiento, correo, verificado FROM usuarios WHERE id = $1', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        let usuario = result.rows[0];
        usuario.verificado = usuario.verificado ? 'verificado' : 'no';
        res.json(usuario);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// UPDATE usuario
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
    let { nombres, edad, ubicacion, fecha_nacimiento, correo, contraseña, verificado } = req.body;

        // Basic validation
        if (!nombres || !edad || !ubicacion || !fecha_nacimiento || !correo || typeof verificado === 'undefined') {
            return res.status(400).json({ mensaje: 'Todos los campos son requeridos.' });
        }
        if (!isValidEmail(correo)) {
            return res.status(400).json({ mensaje: 'Correo no válido.' });
        }
        // Validate verificado as boolean or string
        let verificadoBool;
        if (typeof verificado === 'boolean') {
            verificadoBool = verificado;
        } else if (typeof verificado === 'string') {
            verificado = verificado.trim().toLowerCase();
            if (verificado === 'verificado') verificadoBool = true;
            else if (verificado === 'no') verificadoBool = false;
            else return res.status(400).json({ mensaje: "El campo verificado debe ser 'verificado' o 'no'." });
        } else {
            return res.status(400).json({ mensaje: "El campo verificado debe ser 'verificado' o 'no'." });
        }

        // Hash password if provided
        let hashedPassword = contraseña;
        if (contraseña && contraseña.length >= 6) {
            hashedPassword = await bcrypt.hash(contraseña, 10);
        }

        const result = await pool.query(
            `UPDATE usuarios SET nombres=$1, edad=$2, ubicacion=$3, fecha_nacimiento=$4, correo=$5, contraseña=$6, verificado=$7 WHERE id=$8 RETURNING *`,
            [nombres, edad, ubicacion, fecha_nacimiento, correo, hashedPassword, verificadoBool, id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }
        let usuario = result.rows[0];
        usuario.verificado = usuario.verificado ? 'verificado' : 'no';
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

// Endpoint para obtener el total de usuarios online (conectados)
// Debes ajustar la lógica según cómo determines si un usuario está online
router.get('/online', async (req, res) => {
    try {
        // Ejemplo: si tienes una columna 'online' booleana en la tabla usuarios
        // const result = await pool.query("SELECT COUNT(*) AS total FROM usuarios WHERE online = true");

        // Si no tienes columna, aquí va una lógica temporal (todos verificados cuentan como online)
        const result = await pool.query("SELECT COUNT(*) AS total FROM usuarios WHERE verificado = true");
        const total = parseInt(result.rows[0].total, 10);
        res.json({ total });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
