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

        // Trim and normalize all string fields
        nombre = typeof nombre === 'string' ? nombre.trim() : '';
        tipo_animal = typeof tipo_animal === 'string' ? tipo_animal.trim().toLowerCase() : '';
        raza = typeof raza === 'string' ? raza.trim() : '';
        foto_url = typeof foto_url === 'string' ? foto_url.trim() : '';
        // Accept state as string or boolean (for flexibility)
        if (typeof state === 'boolean') {
            // Already boolean, do nothing
        } else if (typeof state === 'string') {
            state = state.trim().toLowerCase();
        } else {
            state = '';
        }

        // Validation
        // nombre: only letters and spaces, 2-50 chars
        if (!nombre || !/^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]{2,50}$/.test(nombre)) {
            return res.status(400).json({ mensaje: 'El nombre debe tener entre 2 y 50 letras y solo puede contener letras y espacios.' });
        }
        // edad: integer 1-30
        const edadNum = Number(edad);
        if (!edad || isNaN(edadNum) || !Number.isInteger(edadNum) || edadNum <= 0 || edadNum > 30) {
            return res.status(400).json({ mensaje: 'La edad debe ser un número entero positivo menor o igual a 30.' });
        }
        // tipo_animal: only 'perro' or 'gato'
        if (!tipo_animal || !['perro', 'gato'].includes(tipo_animal)) {
            return res.status(400).json({ mensaje: "El tipo de animal debe ser 'perro' o 'gato'." });
        }
        // raza: only letters, spaces, 2-50 chars
        if (!raza || !/^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]{2,50}$/.test(raza)) {
            return res.status(400).json({ mensaje: 'La raza debe tener entre 2 y 50 letras y solo puede contener letras y espacios.' });
        }
        // foto_url: must be valid URL and end with image extension
        const urlRegex = /^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?\.(jpg|jpeg|png|gif)$/i;
        if (!foto_url || typeof foto_url !== 'string' || foto_url.length === 0 || !urlRegex.test(foto_url)) {
            return res.status(400).json({ mensaje: 'La URL de la foto debe ser válida y terminar en .jpg, .jpeg, .png o .gif.' });
        }
        // id_duenio: positive integer
        const idDuenioNum = Number(id_duenio);
        if (!id_duenio || isNaN(idDuenioNum) || !Number.isInteger(idDuenioNum) || idDuenioNum <= 0) {
            return res.status(400).json({ mensaje: 'El id_duenio debe ser un número entero positivo.' });
        }
        // state: boolean or string
        let stateBool;
        if (typeof state === 'boolean') {
            stateBool = state;
        } else if (state === 'buscando pareja') {
            stateBool = true;
        } else if (state === 'soltero') {
            stateBool = false;
        } else {
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
            stateBool
        ];

        const result = await pool.query(query, values);

        // Respond with the registered pet info, converting state back to string for clarity
        const mascota = result.rows[0];
        mascota.state = mascota.state ? 'buscando pareja' : 'soltero';

        res.status(201).json({
            mensaje: 'Mascota registrada exitosamente.',
            mascota
        });
    } catch (error) {
        console.error('Error al registrar mascota:', error);
        res.status(500).json({ mensaje: 'Error interno del servidor.' });
    }
});

module.exports = router;