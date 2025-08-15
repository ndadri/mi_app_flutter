const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configuración de base de datos
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Configuración de multer para subir imágenes
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

// GET - Obtener todos los eventos con información de asistencia del usuario
router.get('/eventos/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const query = `
      SELECT 
        e.*,
        ea.asistira,
        COUNT(ea2.id) as total_asistentes
      FROM eventos e
      LEFT JOIN evento_asistencias ea ON e.id = ea.evento_id AND ea.usuario_id = $1
      LEFT JOIN evento_asistencias ea2 ON e.id = ea2.evento_id AND ea2.asistira = true
      GROUP BY e.id, ea.asistira
      ORDER BY e.fecha_creacion DESC
    `;
    
    const result = await pool.query(query, [userId]);
    
    res.json({
      success: true,
      eventos: result.rows
    });
  } catch (error) {
    console.error('Error al obtener eventos:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener eventos',
      error: error.message
    });
  }
});

// POST - Crear nuevo evento (VERSIÓN SIMPLIFICADA)
router.post('/eventos', upload.single('imagen'), async (req, res) => {
  console.log('� === CREAR EVENTO - VERSIÓN SIMPLIFICADA ===');
  
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
    
    console.log('Insertando con valores:', {
      nombre, fecha, hora, lugar, userId, imagen
    });
    
    // Query simplificada
    const result = await pool.query(`
      INSERT INTO eventos (nombre, fecha, hora, lugar, imagen, creado_por)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, nombre
    `, [nombre, fecha, hora, lugar, imagen, userId]);
    
    console.log('✅ EVENTO CREADO EXITOSAMENTE:', result.rows[0]);
    
    return res.status(200).json({
      success: true,
      message: 'Evento creado exitosamente',
      evento: result.rows[0]
    });
    
  } catch (error) {
    console.error('💥 ERROR COMPLETO:');
    console.error('Message:', error.message);
    console.error('Code:', error.code);
    console.error('Detail:', error.detail);
    console.error('Stack:', error.stack);
    
    return res.status(500).json({
      success: false,
      message: 'Error interno del servidor',
      error: error.message,
      code: error.code
    });
  }
});

// POST - Marcar asistencia a evento
router.post('/eventos/:eventoId/asistencia', async (req, res) => {
  try {
    const { eventoId } = req.params;
    const { usuario_id, asistira } = req.body;
    
    if (!usuario_id || asistira === undefined) {
      return res.status(400).json({
        success: false,
        message: 'usuario_id y asistira son requeridos'
      });
    }
    
    const query = `
      INSERT INTO evento_asistencias (evento_id, usuario_id, asistira)
      VALUES ($1, $2, $3)
      ON CONFLICT (evento_id, usuario_id) 
      DO UPDATE SET asistira = EXCLUDED.asistira, fecha_respuesta = CURRENT_TIMESTAMP
    `;
    
    await pool.query(query, [eventoId, usuario_id, asistira]);
    
    res.json({
      success: true,
      message: asistira ? 'Confirmaste tu asistencia' : 'Marcaste que no asistirás'
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

// GET - Obtener asistentes de un evento
router.get('/eventos/:eventoId/asistentes', async (req, res) => {
  try {
    const { eventoId } = req.params;
    
    const query = `
      SELECT 
        u.id,
        u.nombre,
        u.email,
        ea.asistira,
        ea.fecha_respuesta
      FROM evento_asistencias ea
      JOIN usuarios u ON ea.usuario_id = u.id
      WHERE ea.evento_id = $1
      ORDER BY ea.fecha_respuesta DESC
    `;
    
    const result = await pool.query(query, [eventoId]);
    
    res.json({
      success: true,
      asistentes: result.rows
    });
  } catch (error) {
    console.error('Error al obtener asistentes:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener asistentes',
      error: error.message
    });
  }
});

// DELETE - Eliminar evento (solo el creador)
router.delete('/eventos/:eventoId', async (req, res) => {
  try {
    const { eventoId } = req.params;
    const { usuario_id } = req.body;
    
    // Verificar que el usuario sea el creador del evento
    const eventoResult = await pool.query(
      'SELECT creado_por, imagen FROM eventos WHERE id = $1', 
      [eventoId]
    );
    
    if (eventoResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Evento no encontrado'
      });
    }
    
    const evento = eventoResult.rows[0];
    
    if (evento.creado_por !== parseInt(usuario_id)) {
      return res.status(403).json({
        success: false,
        message: 'Solo el creador puede eliminar el evento'
      });
    }
    
    // Eliminar imagen si existe
    if (evento.imagen) {
      const imagePath = path.join(__dirname, '..', evento.imagen);
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }
    
    // Eliminar evento (las asistencias se eliminan automáticamente por CASCADE)
    await pool.query('DELETE FROM eventos WHERE id = $1', [eventoId]);
    
    res.json({
      success: true,
      message: 'Evento eliminado exitosamente'
    });
  } catch (error) {
    console.error('Error al eliminar evento:', error);
    res.status(500).json({
      success: false,
      message: 'Error al eliminar evento',
      error: error.message
    });
  }
});

module.exports = router;
