require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const authRoutes = require('./routes/authRoutes');
const petRoutes = require('./routes/petRoutes');
const crudUsuario = require('./crudUsuario');
const crudMascota = require('./crudMascota');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Main API routes
app.use('/api/auth', authRoutes);
app.use('/api/pets', petRoutes);
app.use('/api/usuarios', crudUsuario);
app.use('/api/mascotas', crudMascota);

app.get('/', (req, res) => {
  res.send('API is running');
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
