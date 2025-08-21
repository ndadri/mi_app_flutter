require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const authRoutes = require('./routes/authRoutes');
const petRoutes = require('./routes/petRoutes');
const eventoRoutes = require('./routes/eventoRoutes_simple');
const crudUsuario = require('./crudUsuario');
const crudMascota = require('./crudMascota');

const app = express();

// Middleware de logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('Body:', JSON.stringify(req.body, null, 2));
  }
  next();
});

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Servir archivos estáticos de uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Main API routes
app.use('/api/auth', authRoutes);
app.use('/api/pets', petRoutes);
app.use('/api/eventos', eventoRoutes);
app.use('/api/usuarios', crudUsuario);
app.use('/api/mascotas', crudMascota);

app.get('/', (req, res) => {
  res.send('API is running');
});

const PORT = process.env.PORT || 3004;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`✅ Eventos API disponible en http://localhost:${PORT}/api/eventos`);
  console.log(`📁 Uploads disponibles en http://localhost:${PORT}/uploads`);
});
