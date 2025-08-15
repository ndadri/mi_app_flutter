const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

const pool = new Pool({
	connectionString: process.env.DATABASE_URL,
});

// Helper: validate image URL
function isValidImageUrl(url) {
	return /^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?\.(jpg|jpeg|png|gif)$/i.test(url);
}

// CREATE mascota
router.post('/', async (req, res) => {
	try {
		let { nombre, edad, tipo_animal, raza, foto_url, id_duenio, state } = req.body;

		// Basic validation
		if (!nombre || !edad || !tipo_animal || !raza || !foto_url || !id_duenio || typeof state === 'undefined') {
			return res.status(400).json({ mensaje: 'Todos los campos son requeridos.' });
		}
		if (!['perro', 'gato'].includes(tipo_animal)) {
			return res.status(400).json({ mensaje: "El tipo de animal debe ser 'perro' o 'gato'." });
		}
		if (!isValidImageUrl(foto_url)) {
			return res.status(400).json({ mensaje: 'La URL de la foto debe ser válida y terminar en .jpg, .jpeg, .png o .gif.' });
		}
		// Validate state as boolean or string
		let stateBool;
		if (typeof state === 'boolean') {
			stateBool = state;
		} else if (typeof state === 'string') {
			state = state.trim().toLowerCase();
			if (state === 'buscando pareja') stateBool = true;
			else if (state === 'soltero') stateBool = false;
			else return res.status(400).json({ mensaje: "El estado debe ser 'buscando pareja' o 'soltero'." });
		} else {
			return res.status(400).json({ mensaje: "El estado debe ser 'buscando pareja' o 'soltero'." });
		}

		const result = await pool.query(
			`INSERT INTO mascotas (nombre, edad, tipo_animal, raza, foto_url, id_duenio, state)
			 VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
			[nombre, edad, tipo_animal, raza, foto_url, id_duenio, stateBool]
		);
		let mascota = result.rows[0];
		mascota.state = mascota.state ? 'buscando pareja' : 'soltero';
		res.status(201).json(mascota);
	} catch (error) {
		res.status(500).json({ error: error.message });
	}
});

// READ all mascotas
router.get('/', async (req, res) => {
	try {
		const result = await pool.query('SELECT * FROM mascotas');
		const mascotas = result.rows.map(m => ({ ...m, state: m.state ? 'buscando pareja' : 'soltero' }));
		res.json(mascotas);
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
		let mascota = result.rows[0];
		mascota.state = mascota.state ? 'buscando pareja' : 'soltero';
		res.json(mascota);
	} catch (error) {
		res.status(500).json({ error: error.message });
	}
});

// UPDATE mascota
router.put('/:id', async (req, res) => {
	try {
		const { id } = req.params;
		let { nombre, edad, tipo_animal, raza, foto_url, id_duenio, state } = req.body;

		// Basic validation
		if (!nombre || !edad || !tipo_animal || !raza || !foto_url || !id_duenio || typeof state === 'undefined') {
			return res.status(400).json({ mensaje: 'Todos los campos son requeridos.' });
		}
		if (!['perro', 'gato'].includes(tipo_animal)) {
			return res.status(400).json({ mensaje: "El tipo de animal debe ser 'perro' o 'gato'." });
		}
		if (!isValidImageUrl(foto_url)) {
			return res.status(400).json({ mensaje: 'La URL de la foto debe ser válida y terminar en .jpg, .jpeg, .png o .gif.' });
		}
		// Validate state as boolean or string
		let stateBool;
		if (typeof state === 'boolean') {
			stateBool = state;
		} else if (typeof state === 'string') {
			state = state.trim().toLowerCase();
			if (state === 'buscando pareja') stateBool = true;
			else if (state === 'soltero') stateBool = false;
			else return res.status(400).json({ mensaje: "El estado debe ser 'buscando pareja' o 'soltero'." });
		} else {
			return res.status(400).json({ mensaje: "El estado debe ser 'buscando pareja' o 'soltero'." });
		}

		const result = await pool.query(
			`UPDATE mascotas SET nombre=$1, edad=$2, tipo_animal=$3, raza=$4, foto_url=$5, id_duenio=$6, state=$7 WHERE id=$8 RETURNING *`,
			[nombre, edad, tipo_animal, raza, foto_url, id_duenio, stateBool, id]
		);
		if (result.rows.length === 0) {
			return res.status(404).json({ mensaje: 'Mascota no encontrada' });
		}
		let mascota = result.rows[0];
		mascota.state = mascota.state ? 'buscando pareja' : 'soltero';
		res.json(mascota);
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
		let mascota = result.rows[0];
		mascota.state = mascota.state ? 'buscando pareja' : 'soltero';
		res.json({ mensaje: 'Mascota eliminada', mascota });
	} catch (error) {
		res.status(500).json({ error: error.message });
	}
});

module.exports = router;
