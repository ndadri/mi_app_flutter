const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configuración simple de multer
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadPath = 'uploads/eventos/';
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'evento-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB límite
  fileFilter: function (req, file, cb) {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Solo se permiten imágenes (jpeg, jpg, png, gif)'));
    }
  }
});

// Array temporal para almacenar eventos (simulando base de datos)
let eventos = [
  {
    id: 1,
    nombre: 'Evento de prueba',
    fecha: '2025-08-25',
    hora: '15:00',
    lugar: 'Parque Central',
    imagen: null,
    creado_por: '2',
    fecha_creacion: new Date(),
    asistira: null,
    total_asistentes: 0
  }
];

// GET - Obtener todos los eventos
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    console.log(`📋 Obteniendo eventos para usuario: ${userId}`);
    
    res.json({
      success: true,
      eventos: eventos,
      message: 'Eventos obtenidos exitosamente (modo simulado)'
    });
  } catch (error) {
    console.error('❌ Error al obtener eventos:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener eventos',
      error: error.message
    });
  }
});

// POST - Crear nuevo evento (VERSIÓN SIMULADA)
router.post('/', upload.single('imagen'), async (req, res) => {
  console.log('🎉 === CREAR EVENTO - VERSIÓN SIMULADA ===');
  
  try {
    // Log de todo lo que llega
    console.log('Body completo:', JSON.stringify(req.body, null, 2));
    console.log('Archivo:', req.file);
    
    const { nombre, fecha, hora, lugar, creado_por } = req.body;
    
    // Validar campos básicos
    if (!nombre || !fecha || !hora || !lugar) {
      console.log('❌ Campos faltantes');
      return res.status(400).json({
        success: false,
        message: 'Faltan campos requeridos',
        received: { nombre, fecha, hora, lugar, creado_por }
      });
    }
    
    // Usar ID por defecto si no viene creado_por
    const userId = creado_por || '2';
    const imagen = req.file ? `/uploads/eventos/${req.file.filename}` : null;
    
    console.log('Creando evento con valores:', {
      nombre, fecha, hora, lugar, userId, imagen
    });
    
    // Crear nuevo evento
    const nuevoEvento = {
      id: eventos.length + 1,
      nombre,
      fecha,
      hora,
      lugar,
      imagen,
      creado_por: userId,
      fecha_creacion: new Date(),
      asistira: null,
      total_asistentes: 0
    };
    
    eventos.push(nuevoEvento);
    
    console.log('✅ EVENTO CREADO EXITOSAMENTE:', nuevoEvento);
    
    return res.status(200).json({
      success: true,
      message: 'Evento creado exitosamente (modo simulado)',
      evento: {
        id: nuevoEvento.id,
        nombre: nuevoEvento.nombre
      }
    });
    
  } catch (error) {
    console.error('💥 ERROR COMPLETO:');
    console.error('Message:', error.message);
    console.error('Stack:', error.stack);
    
    return res.status(500).json({
      success: false,
      message: 'Error interno del servidor',
      error: error.message
    });
  }
});

// POST - Marcar asistencia a evento (SIMULADO)
router.post('/:eventoId/asistencia', async (req, res) => {
  try {
    const { eventoId } = req.params;
    const { usuario_id, asistira } = req.body;
    
    console.log(`👥 Marcando asistencia - Evento: ${eventoId}, Usuario: ${usuario_id}, Asistirá: ${asistira}`);
    
    if (!usuario_id || asistira === undefined) {
      return res.status(400).json({
        success: false,
        message: 'usuario_id y asistira son requeridos'
      });
    }
    
    // Simular marcado de asistencia
    const evento = eventos.find(e => e.id == eventoId);
    if (evento) {
      evento.asistira = asistira;
      if (asistira) {
        evento.total_asistentes++;
      }
    }
    
    res.json({
      success: true,
      message: asistira ? 'Confirmaste tu asistencia (simulado)' : 'Marcaste que no asistirás (simulado)'
    });
  } catch (error) {
    console.error('Error al marcar asistencia:', error);
    res.status(500).json({
      success: false,
      message: 'Error al marcar asistencia',
      error: error.message
    });
  }
});

module.exports = router;
