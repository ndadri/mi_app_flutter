const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const express = require('express');
const cors = require('cors');

// Importar Pool solo si está disponible
let pool = null;
try {
  const { Pool } = require('pg');
  pool = new Pool({
    connectionString: process.env.DATABASE_URL,
  });
} catch (error) {
  console.warn('⚠️ PostgreSQL no disponible:', error.message);
}

const app = express();

// Función para verificar conexión a base de datos
async function verifyDatabaseConnection() {
    if (!pool) {
        console.error('❌ Pool de base de datos no inicializado');
        return false;
    }
    
    try {
        const client = await pool.connect();
        await client.query('SELECT NOW()');
        client.release();
        console.log('✅ Base de datos conectada exitosamente');
        return true;
    } catch (error) {
        console.error('❌ Error de conexión a base de datos:', error.message);
        return false;
    }
}

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

// Middleware de logging
app.use((req, res, next) => {
  console.log(`📝 ${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Importar y usar las rutas de autenticación
const authRoutes = require('../routes/authRoutes');
const locationRoutes = require('../routes/locationRoutes');
const passwordResetRoutes = require('../routes/passwordResetRoutes');
app.use('/api/auth', authRoutes);
app.use('/api', locationRoutes);
app.use('/api', passwordResetRoutes);

app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));


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
app.get('/health', async (req, res) => {
  let dbConnected = false;
  
  try {
    dbConnected = await verifyDatabaseConnection();
  } catch (error) {
    console.error('Error verificando BD:', error.message);
  }
  
  res.json({
    success: true,
    status: dbConnected ? 'healthy' : 'unhealthy',
    database: {
      connected: dbConnected,
      url: process.env.DATABASE_URL ? 'configured' : 'not_configured',
      poolAvailable: !!pool
    },
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

// Iniciar servidor con verificación de base de datos
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

// Verificar conexión a base de datos al iniciar
async function startServer() {
  console.log('🚀 Iniciando servidor...');
  
  let dbConnected = false;
  try {
    dbConnected = await verifyDatabaseConnection();
  } catch (error) {
    console.error('Error inicial de BD:', error.message);
  }
  
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
    console.log(`🌐 Servidor escuchando en todas las interfaces (0.0.0.0:${PORT})`);
    console.log(`📧 Email configurado: ${process.env.EMAIL_USER ? '✅' : '❌'}`);
    console.log(`🗄️ Base de datos: ${dbConnected ? '✅ Conectada' : '❌ Error de conexión'}`);
    console.log(`🔑 JWT Secret: ${process.env.JWT_SECRET ? '✅' : '❌'}`);
    console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
    
    if (!dbConnected) {
      console.warn('⚠️ ADVERTENCIA: Servidor iniciado sin conexión a base de datos');
      console.warn('⚠️ Algunas funcionalidades pueden no funcionar correctamente');
    }
  });
}

// Iniciar el servidor con manejo de errores
startServer().catch((error) => {
  console.error('❌ Error iniciando servidor:', error.message);
  process.exit(1);
});