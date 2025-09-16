const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

// Configurar conexión a la base de datos
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Endpoint para obtener usuarios cercanos por ubicación
router.get('/usuarios-cercanos', async (req, res) => {
    try {
        const { latitud, longitud, radio = 10 } = req.query;

        if (!latitud || !longitud) {
            return res.status(400).json({ 
                mensaje: 'Se requieren latitud y longitud' 
            });
        }

        const lat = parseFloat(latitud);
        const lng = parseFloat(longitud);
        const radiusKm = parseFloat(radio);

        if (isNaN(lat) || isNaN(lng) || isNaN(radiusKm)) {
            return res.status(400).json({ 
                mensaje: 'Coordenadas o radio inválidos' 
            });
        }

        // Consulta usando fórmula de Haversine para calcular distancia
        const query = `
            SELECT 
                id,
                nombres,
                apellidos,
                ubicacion,
                latitud,
                longitud,
                (
                    6371 * acos(
                        cos(radians($1)) * 
                        cos(radians(latitud)) * 
                        cos(radians(longitud) - radians($2)) + 
                        sin(radians($1)) * 
                        sin(radians(latitud))
                    )
                ) AS distancia
            FROM usuarios 
            WHERE latitud IS NOT NULL 
            AND longitud IS NOT NULL
            HAVING distancia <= $3
            ORDER BY distancia ASC
            LIMIT 50
        `;

        const result = await pool.query(query, [lat, lng, radiusKm]);

        res.json({
            usuarios: result.rows,
            total: result.rows.length
        });

    } catch (error) {
        console.error('Error en usuarios-cercanos:', error);
        res.status(500).json({ 
            mensaje: 'Error interno del servidor' 
        });
    }
});

// Endpoint para actualizar ubicación de usuario
router.put('/actualizar-ubicacion/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { ubicacion, latitud, longitud } = req.body;

        if (!ubicacion) {
            return res.status(400).json({ 
                mensaje: 'La ubicación es requerida' 
            });
        }

        let query, values;

        if (latitud && longitud) {
            // Actualizar con coordenadas
            query = `
                UPDATE usuarios 
                SET ubicacion = $1, latitud = $2, longitud = $3, updated_at = NOW()
                WHERE id = $4
                RETURNING id, nombres, apellidos, ubicacion, latitud, longitud
            `;
            values = [ubicacion, parseFloat(latitud), parseFloat(longitud), id];
        } else {
            // Actualizar solo ubicación de texto
            query = `
                UPDATE usuarios 
                SET ubicacion = $1, updated_at = NOW()
                WHERE id = $2
                RETURNING id, nombres, apellidos, ubicacion, latitud, longitud
            `;
            values = [ubicacion, id];
        }

        const result = await pool.query(query, values);

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                mensaje: 'Usuario no encontrado' 
            });
        }

        res.json({
            mensaje: 'Ubicación actualizada correctamente',
            usuario: result.rows[0]
        });

    } catch (error) {
        console.error('Error actualizando ubicación:', error);
        res.status(500).json({ 
            mensaje: 'Error interno del servidor' 
        });
    }
});

module.exports = router;
