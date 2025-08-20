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
    // Optimizaciones para login más rápido
    max: 20, // Máximo 20 conexiones concurrentes
    idleTimeoutMillis: 30000, // Tiempo de vida de conexiones inactivas
    connectionTimeoutMillis: 5000, // Timeout de conexión 5 segundos
    statement_timeout: 10000, // Timeout de queries 10 segundos
    query_timeout: 10000, // Timeout adicional para queries
    keepAlive: true, // Mantener conexiones vivas
    keepAliveInitialDelayMillis: 10000
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
  origin: true, // Permitir todas las conexiones por ahora
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'Origin', 'X-Requested-With']
}));

// Headers adicionales para móviles
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  
  // Responder a preflight requests
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
    return;
  }
  
  next();
});

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Middleware de logging detallado
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  const clientIP = req.ip || req.connection.remoteAddress || req.socket.remoteAddress || 'unknown';
  
  console.log(`📝 ${timestamp} - ${req.method} ${req.path}`);
  console.log(`🌐 Cliente IP: ${clientIP}`);
  console.log(`📱 User-Agent: ${req.get('User-Agent') || 'No User-Agent'}`);
  console.log(`🔗 Origin: ${req.get('Origin') || 'No Origin'}`);
  
  if (req.method === 'POST' && req.path.includes('/login')) {
    console.log('🔐 PETICIÓN DE LOGIN DETECTADA');
    console.log('Headers:', JSON.stringify(req.headers, null, 2));
    console.log('Body:', JSON.stringify(req.body, null, 2));
  }
  
  if (req.method === 'POST' && req.path.includes('/eventos')) {
    console.log('🎯 PETICIÓN DE CREAR EVENTO DETECTADA');
    console.log('Headers:', req.headers);
    console.log('Body:', req.body);
  }
  
  next();
});

// Importar y usar las rutas de autenticación
const authRoutes = require('../routes/authRoutes');
const eventoRoutes = require('../routes/eventoRoutes');

// Importar matchRoutes con manejo de errores
let matchRoutes = null;
try {
    matchRoutes = require('../routes/matchRoutes');
    console.log('✅ matchRoutes cargado correctamente');
} catch (error) {
    console.error('❌ Error cargando matchRoutes:', error.message);
    console.error('Stack:', error.stack);
}

//const locationRoutes = require('../routes/locationRoutes');
//const passwordResetRoutes = require('../routes/passwordResetRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/eventos', eventoRoutes);

// Solo usar matchRoutes si se cargó correctamente
if (matchRoutes) {
    app.use('/api/matches', matchRoutes);
    console.log('✅ Rutas de matches configuradas en /api/matches');
} else {
    console.error('❌ No se pudieron configurar las rutas de matches');
}

//app.use('/api/location', locationRoutes);
//app.use('/api/password-reset', passwordResetRoutes);

app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));


// Ruta de estado del servidor
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Pet Match API Server is running',
    timestamp: new Date().toISOString(),
    endpoints: [
      '/api/auth',
      '/api/eventos',
      '/api/matches',
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
  const clientIP = req.ip || req.connection.remoteAddress || 'unknown';
  console.log(`🧪 Test endpoint accedido desde: ${clientIP}`);
  
  res.json({
    success: true,
    message: 'Backend funcionando correctamente - Sin base de datos',
    serverTime: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    clientIP: clientIP,
    headers: req.headers
  });
});

// Endpoint específico para probar desde móviles
app.get('/mobile-test', (req, res) => {
  const clientIP = req.ip || req.connection.remoteAddress || 'unknown';
  console.log(`📱 Mobile test endpoint accedido desde: ${clientIP}`);
  
  res.json({
    success: true,
    message: '¡Conexión desde móvil exitosa!',
    timestamp: new Date().toISOString(),
    clientInfo: {
      ip: clientIP,
      userAgent: req.get('User-Agent'),
      origin: req.get('Origin')
    }
  });
});

// Endpoint para probar login sin autenticación real
app.post('/test-login', (req, res) => {
  const clientIP = req.ip || req.connection.remoteAddress || 'unknown';
  console.log(`🔐 Test login desde: ${clientIP}`);
  console.log('Body recibido:', req.body);
  
  res.json({
    success: true,
    message: 'Test login exitoso',
    timestamp: new Date().toISOString(),
    receivedData: req.body,
    clientIP: clientIP
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

// Iniciar el servidor con verificación de base de datos
const PORT = process.env.PORT || 3002;

// Función simple para iniciar el servidor
function startServer() {
  console.log('🚀 Iniciando servidor...');
  
  const server = app.listen(PORT, '0.0.0.0', () => {
    console.log('\n🚀 ===== SERVIDOR PETMATCH INICIADO ===== 🚀');
    console.log(`📡 Puerto: ${PORT}`);
    console.log(`🌐 Servidor escuchando en TODAS las interfaces de red`);
    console.log('\n📱 ACCESO DESDE DISPOSITIVOS:');
    console.log(`   🖥️  Local: http://localhost:${PORT}`);
    console.log(`   🖥️  Local: http://127.0.0.1:${PORT}`);
    console.log(`   📱 Red Local: http://192.168.1.24:${PORT}`);
    console.log(`   � Para tu app Flutter: 192.168.1.24:${PORT}`);
    console.log('\n✅ ¡Servidor listo para recibir conexiones!\n');
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.error(`❌ Puerto ${PORT} ya está en uso`);
      console.log('💡 Prueba con: taskkill /f /im node.exe');
    } else {
      console.error('❌ Error del servidor:', err);
    }
    process.exit(1);
  });

  return server;
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
  
  // Obtener todas las interfaces de red disponibles
  const os = require('os');
  const networkInterfaces = os.networkInterfaces();
  const ips = [];
  
  Object.keys(networkInterfaces).forEach((interfaceName) => {
    networkInterfaces[interfaceName].forEach((iface) => {
      if (iface.family === 'IPv4' && !iface.internal) {
        ips.push(iface.address);
      }
    });
  });
  
  app.listen(PORT, '0.0.0.0', () => {
    console.log('\n🚀 ===== SERVIDOR PETMATCH INICIADO ===== 🚀');
    console.log(`📡 Puerto: ${PORT}`);
    console.log(`🌐 Servidor escuchando en TODAS las interfaces de red`);
    console.log('\n📱 ACCESO DESDE DISPOSITIVOS:');
    console.log(`   🖥️  Local: http://localhost:${PORT}`);
    console.log(`   🖥️  Local: http://127.0.0.1:${PORT}`);
    
    if (ips.length > 0) {
      ips.forEach(ip => {
        console.log(`   📱 Red Local: http://${ip}:${PORT}`);
        console.log(`   � Para tu app Flutter: ${ip}:${PORT}`);
      });
    }
    
    console.log('\n🔧 ESTADO DEL SISTEMA:');
    console.log(`   📧 Email: ${process.env.EMAIL_USER ? '✅ Configurado' : '❌ No configurado'}`);
    console.log(`   🗄️  Base de datos: ${dbConnected ? '✅ Conectada' : '❌ Error de conexión'}`);
    console.log(`   🔑 JWT Secret: ${process.env.JWT_SECRET ? '✅ Configurado' : '❌ No configurado'}`);
    console.log(`   🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
    
    console.log('\n🔗 ENDPOINTS DISPONIBLES:');
    console.log('   📋 GET  / - Estado del servidor');
    console.log('   🏥 GET  /health - Diagnóstico completo');
    console.log('   🧪 GET  /test - Prueba sin BD');
    console.log('   👤 POST /api/auth/registrar - Registro de usuarios');
    console.log('   🔐 POST /api/auth/login - Iniciar sesión');
    console.log('   📱 POST /api/auth/social-login - Login social');
    console.log('   🎉 POST /api/eventos/* - Gestión de eventos');
    
    if (!dbConnected) {
      console.warn('\n⚠️  ADVERTENCIA: Servidor iniciado sin conexión a base de datos');
      console.warn('⚠️  Algunas funcionalidades pueden no funcionar correctamente');
    }
    
    console.log('\n✅ ¡Servidor listo para recibir conexiones desde cualquier dispositivo!\n');
  });
}

// Iniciar el servidor
startServer();