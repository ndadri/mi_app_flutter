const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

// Configura tu conexión a la base de datos
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Ruta POST para registrar una mascota
router.post('/registrar', async (req, res) => {
    try {
        let { nombre, edad, tipo_animal, raza, foto_url, id_duenio, state } = req.body;

        // Trim all string fields if they exist
        nombre = typeof nombre === 'string' ? nombre.trim() : '';
        tipo_animal = typeof tipo_animal === 'string' ? tipo_animal.trim().toLowerCase() : '';
        raza = typeof raza === 'string' ? raza.trim() : '';
        foto_url = typeof foto_url === 'string' ? foto_url.trim() : '';
        state = typeof state === 'string' ? state.trim().toLowerCase() : '';

        // Validate nombre
        if (!nombre || typeof nombre !== 'string' || nombre.length === 0) {
            return res.status(400).json({ mensaje: 'El nombre de la mascota es obligatorio y debe ser un texto válido.' });
        }
        // Validate edad
        const edadNum = Number(edad);
        if (!edad || isNaN(edadNum) || !Number.isInteger(edadNum) || edadNum <= 0) {
            return res.status(400).json({ mensaje: 'La edad debe ser un número entero positivo.' });
        }
        // Validate tipo_animal
        if (!tipo_animal || !['perro', 'gato'].includes(tipo_animal)) {
            return res.status(400).json({ mensaje: "El tipo de animal debe ser 'perro' o 'gato'." });
        }
        // Validate raza
        if (!raza || typeof raza !== 'string' || raza.length === 0) {
            return res.status(400).json({ mensaje: 'La raza es obligatoria y debe ser un texto válido.' });
        }
        // Validate foto_url (basic URL check)
        const urlRegex = /^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$/i;
        if (!foto_url || typeof foto_url !== 'string' || foto_url.length === 0 || !urlRegex.test(foto_url)) {
            return res.status(400).json({ mensaje: 'La URL de la foto es obligatoria y debe ser válida.' });
        }
        // Validate id_duenio
        const idDuenioNum = Number(id_duenio);
        if (!id_duenio || isNaN(idDuenioNum) || !Number.isInteger(idDuenioNum) || idDuenioNum <= 0) {
            return res.status(400).json({ mensaje: 'El id_duenio debe ser un número entero positivo.' });
        }
        // Validate state
        if (!['buscando pareja', 'soltero'].includes(state)) {
            return res.status(400).json({ mensaje: "El estado debe ser 'buscando pareja' o 'soltero'." });
        }

        // Insertar la mascota en la base de datos
        const query = `
            INSERT INTO mascotas (nombre, edad, tipo_animal, raza, foto_url, id_duenio, state)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *
        `;
        const values = [
            nombre,
            edadNum,
            tipo_animal,
            raza,
            foto_url,
            idDuenioNum,
            state
        ];

        const result = await pool.query(query, values);

        res.status(201).json({
            mensaje: 'Mascota registrada exitosamente.',
            mascota: result.rows[0]
        });
    } catch (error) {
        console.error('Error al registrar mascota:', error);
        res.status(500).json({ mensaje: 'Error interno del servidor.' });
    }
});

module.exports = router;