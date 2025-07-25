const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const express = require('express');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors({
  origin: function (origin, callback) {
    // Permitir localhost en cualquier puerto para desarrollo
    if (!origin || origin.includes('localhost') || origin.includes('127.0.0.1')) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
app.use(express.json());

// Importar y usar las rutas de autenticación
const authRoutes = require('../routes/authRoutes');
app.use('/api/auth', authRoutes);

app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

const petRoutes = require('../routes/petRoutes');
app.use('/api/mascotas', petRoutes);

// Importar y usar las rutas del chat
const chatRoutes = require('../routes/chatRoutes');
app.use('/api/chat', chatRoutes);

// Importar y usar las rutas de reportes
const reportRoutes = require('../routes/reportRoutes');
app.use('/api/reports', reportRoutes);

// Ruta de estado del servidor
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Pet Match API Server is running',
    timestamp: new Date().toISOString(),
    endpoints: [
      '/api/auth',
      '/api/mascotas',
      '/api/chat',
      '/api/reports'
    ]
  });
});

// Ruta de diagnóstico
app.get('/health', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    environment: {
      nodeEnv: process.env.NODE_ENV,
      port: process.env.PORT,
      hasDbHost: !!process.env.DB_HOST,
      hasDbUser: !!process.env.DB_USER,
      hasJwtSecret: !!process.env.JWT_SECRET
    },
    timestamp: new Date().toISOString()
  });
});

// Ruta de prueba simple (sin base de datos)
app.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'Backend funcionando correctamente - Sin base de datos',
    serverTime: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Manejo de rutas no encontradas
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Ruta no encontrada'
  });
});

// Manejo global de errores
app.use((err, req, res, next) => {
  console.error('❌ Error global:', err.stack);
  res.status(500).json({
    success: false,
    message: 'Error interno del servidor'
  });
});

// Iniciar servidor
// Fixed frontend dependency issue - backend only serves API endpoints
const PORT = process.env.PORT || 3001;

// Validar variables de entorno críticas
const requiredEnvVars = ['JWT_SECRET'];
const missingEnvVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingEnvVars.length > 0) {
  console.error(`❌ Variables de entorno faltantes: ${missingEnvVars.join(', ')}`);
  console.log('📝 Variables disponibles:', {
    NODE_ENV: process.env.NODE_ENV,
    PORT: process.env.PORT,
    DB_HOST: process.env.DB_HOST ? 'SET' : 'NOT SET',
    JWT_SECRET: process.env.JWT_SECRET ? 'SET' : 'NOT SET'
  });
}

app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
  console.log(`📧 Email configurado: ${process.env.EMAIL_USER ? '✅' : '❌'}`);
  console.log(`🗄️ Base de datos: ${process.env.DATABASE_URL ? '✅' : '❌'}`);
  console.log(`🔑 JWT Secret: ${process.env.JWT_SECRET ? '✅' : '❌'}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
});