const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Configura tu conexión a PostgreSQL
const pool = new Pool({
  user: 'edison',      // Cambia por tu usuario de PostgreSQL
  host: 'localhost',
  database: 'basefinalcreo',     // Cambia por el nombre de tu base de datos
  password: '1234', // Cambia por tu contraseña
  port: 5432,
});

app.post('/api/register', async (req, res) => {
  const { nombres, apellidos, correo, contraseña, genero, ubicacion, fecha_nacimiento } = req.body;

  if (
    !nombres ||
    !apellidos ||
    !correo ||
    !contraseña ||
    !genero ||
    !ubicacion ||
    !fecha_nacimiento
  ) {
    return res.status(400).json({ message: 'Todos los campos son requeridos.' });
  }

  try {
    // Verifica si el usuario ya existe
    const existe = await pool.query(
      'SELECT * FROM usuarios WHERE correo = $1',
      [correo]
    );
    if (existe.rows.length > 0) {
      return res.status(409).json({ message: 'El usuario ya existe.' });
    }

    // Encripta la contraseña
    const hashedPassword = await bcrypt.hash(contraseña, 10);

    // Inserta el usuario en la base de datos
    await pool.query(
      'INSERT INTO usuarios (nombres, apellidos, correo, contraseña, genero, ubicacion, fecha_nacimiento) VALUES ($1, $2, $3, $4, $5, $6, $7)',
      [nombres, apellidos, correo, hashedPassword, genero, ubicacion, fecha_nacimiento]
    );

    res.status(200).json({ message: 'Usuario registrado exitosamente.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error en el servidor.' });
  }
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);
});