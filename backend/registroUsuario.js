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
  user: 'TU_USUARIO',      // Cambia por tu usuario de PostgreSQL
  host: 'localhost',
  database: 'TU_BASE',     // Cambia por el nombre de tu base de datos
  password: 'TU_PASSWORD', // Cambia por tu contraseña
  port: 5432,
});

// Ruta para registrar usuario
app.post('/api/register', async (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ message: 'Todos los campos son requeridos.' });
  }

  try {
    // Verifica si el usuario ya existe
    const existe = await pool.query(
      'SELECT * FROM usuarios WHERE email = $1 OR username = $2',
      [email, username]
    );
    if (existe.rows.length > 0) {
      return res.status(409).json({ message: 'El usuario ya existe.' });
    }

    // Encripta la contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Inserta el usuario en la base de datos
    await pool.query(
      'INSERT INTO usuarios (username, email, password) VALUES ($1, $2, $3)',
      [username, email, hashedPassword]
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