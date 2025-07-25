const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

// Configuración directa para desarrollo local (compatibilidad)
const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'matchpet',
    user: 'admin',
    password: '12345'
});

// 🔥 Ruta de prueba simple
router.get('/test', (req, res) => {
    res.json({
        success: true,
        message: 'Ruta de reportes funcionando correctamente',
        timestamp: new Date().toISOString()
    });
});

// 📌 Ruta POST para reportar usuario/mascota
router.post('/report-user', async (req, res) => {
    const {
        reporter_id,
        reported_user_id,
        reported_pet_id,
        report_type,
        reason,
        additional_details
    } = req.body;

    try {
        // Validación de campos obligatorios
        if (!reporter_id || !reported_user_id || !report_type || !reason) {
            return res.status(400).json({
                success: false,
                message: 'Faltan campos obligatorios: reporter_id, reported_user_id, report_type, reason'
            });
        }

        // Verificar que no se auto-reporte
        if (reporter_id === reported_user_id) {
            return res.status(400).json({
                success: false,
                message: 'No puedes reportarte a ti mismo'
            });
        }

        // Verificar si ya existe un reporte del mismo tipo
        const existingReport = await pool.query(
            'SELECT id FROM reportes WHERE usuario_reportador_id = $1 AND usuario_reportado_id = $2 AND tipo_reporte = $3',
            [reporter_id, reported_user_id, report_type]
        );

        if (existingReport.rows.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'Ya has reportado a este usuario por esta razón'
            });
        }

        // Crear descripción combinada
        const descripcion_completa = additional_details 
            ? `${reason}\n\nDetalles adicionales: ${additional_details}`
            : reason;

        // Insertar reporte usando la tabla 'reportes' existente
        const result = await pool.query(
            `INSERT INTO reportes 
             (usuario_reportador_id, usuario_reportado_id, tipo_reporte, descripcion, estado, fecha_reporte)
             VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
             RETURNING *`,
            [reporter_id, reported_user_id, report_type, descripcion_completa, 'pendiente']
        );

        console.log('✅ Reporte creado:', result.rows[0]);

        res.json({
            success: true,
            message: 'Reporte enviado exitosamente',
            report: result.rows[0]
        });

    } catch (err) {
        console.error('❌ Error al crear reporte:', err);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// 📌 Ruta GET para obtener reportes
router.get('/', async (req, res) => {
    const { status, page = 1, limit = 20 } = req.query;

    try {
        const offset = (page - 1) * limit;
        let whereClause = '';
        let queryParams = [limit, offset];
        let paramCount = 2;

        if (status) {
            whereClause = 'WHERE r.estado = $3';
            queryParams.push(status);
            paramCount++;
        }

        const query = `
            SELECT 
                r.*,
                reporter.nombres as reporter_name,
                reported.nombres as reported_name
            FROM reportes r
            LEFT JOIN usuarios reporter ON r.usuario_reportador_id = reporter.id
            LEFT JOIN usuarios reported ON r.usuario_reportado_id = reported.id
            ${whereClause}
            ORDER BY r.fecha_reporte DESC
            LIMIT $1 OFFSET $2
        `;

        const reports = await pool.query(query, queryParams);
        
        // Contar total
        const countQuery = `SELECT COUNT(*) FROM reportes r ${whereClause}`;
        const countParams = queryParams.slice(2); // Solo status si existe
        const totalReports = await pool.query(countQuery, countParams);

        res.json({
            success: true,
            reports: reports.rows,
            pagination: {
                total: parseInt(totalReports.rows[0].count),
                page: parseInt(page),
                limit: parseInt(limit),
                totalPages: Math.ceil(totalReports.rows[0].count / limit)
            }
        });

    } catch (err) {
        console.error('❌ Error al obtener reportes:', err);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// 📌 Ruta POST para tomar acción administrativa
router.post('/admin-action', async (req, res) => {
    const {
        admin_id,
        target_user_id,
        action_type,
        reason,
        duration_hours,
        report_ids
    } = req.body;

    try {
        // Verificar que es admin
        const adminCheck = await pool.query(
            'SELECT r.nombre FROM usuarios u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id WHERE u.id = $1 AND r.nombre = $2',
            [admin_id, 'admin']
        );

        if (adminCheck.rows.length === 0) {
            return res.status(403).json({
                success: false,
                message: 'Acceso denegado: Se requieren permisos de administrador'
            });
        }

        const client = await pool.connect();
        
        try {
            await client.query('BEGIN');

            // Crear acción administrativa
            const expires_at = duration_hours ? 
                new Date(Date.now() + (duration_hours * 60 * 60 * 1000)) : null;

            const actionResult = await client.query(
                `INSERT INTO admin_actions 
                 (admin_id, target_user_id, action_type, reason, duration_hours, expires_at)
                 VALUES ($1, $2, $3, $4, $5, $6)
                 RETURNING *`,
                [admin_id, target_user_id, action_type, reason, duration_hours, expires_at]
            );

            // Actualizar estado del usuario según la acción
            switch (action_type) {
                case 'warning':
                    await client.query(`
                        UPDATE user_status 
                        SET warning_count = warning_count + 1,
                            last_warning_at = CURRENT_TIMESTAMP,
                            reputation_score = GREATEST(reputation_score - 25, 0),
                            updated_at = CURRENT_TIMESTAMP
                        WHERE user_id = $1
                    `, [target_user_id]);
                    break;

                case 'temporary_ban':
                    await client.query(`
                        UPDATE user_status 
                        SET is_banned = TRUE,
                            ban_expires_at = $2,
                            reputation_score = GREATEST(reputation_score - 50, 0),
                            updated_at = CURRENT_TIMESTAMP
                        WHERE user_id = $1
                    `, [target_user_id, expires_at]);
                    break;

                case 'permanent_ban':
                    await client.query(`
                        UPDATE user_status 
                        SET is_banned = TRUE,
                            ban_expires_at = NULL,
                            reputation_score = 0,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE user_id = $1
                    `, [target_user_id]);
                    break;

                case 'chat_restriction':
                    await client.query(`
                        UPDATE user_status 
                        SET chat_restricted = TRUE,
                            chat_restriction_expires_at = $2,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE user_id = $1
                    `, [target_user_id, expires_at]);
                    break;

                case 'account_verified':
                    await client.query(`
                        UPDATE user_status 
                        SET is_verified = TRUE,
                            reputation_score = LEAST(reputation_score + 25, 100),
                            updated_at = CURRENT_TIMESTAMP
                        WHERE user_id = $1
                    `, [target_user_id]);
                    break;
            }

            // Marcar reportes como revisados si se proporcionaron IDs
            if (report_ids && report_ids.length > 0) {
                await client.query(`
                    UPDATE reportes 
                    SET estado = 'revisado',
                        resuelto_por = $1,
                        fecha_resolucion = CURRENT_TIMESTAMP
                    WHERE id = ANY($2)
                `, [admin_id, report_ids]);
            }

            await client.query('COMMIT');

            console.log('✅ Acción administrativa aplicada:', actionResult.rows[0]);

            res.json({
                success: true,
                message: 'Acción administrativa aplicada exitosamente',
                action: actionResult.rows[0]
            });

        } catch (err) {
            await client.query('ROLLBACK');
            throw err;
        } finally {
            client.release();
        }

    } catch (err) {
        console.error('❌ Error al aplicar acción administrativa:', err);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// 📌 Ruta GET para verificar estado del usuario
router.get('/user-status/:user_id', async (req, res) => {
    const { user_id } = req.params;

    try {
        const result = await pool.query(`
            SELECT 
                us.*,
                CASE 
                    WHEN us.is_banned AND (us.ban_expires_at IS NULL OR us.ban_expires_at > CURRENT_TIMESTAMP) 
                    THEN TRUE 
                    ELSE FALSE 
                END as currently_banned,
                CASE 
                    WHEN us.chat_restricted AND (us.chat_restriction_expires_at IS NULL OR us.chat_restriction_expires_at > CURRENT_TIMESTAMP) 
                    THEN TRUE 
                    ELSE FALSE 
                END as currently_chat_restricted
            FROM user_status us
            WHERE us.user_id = $1
        `, [user_id]);

        if (result.rows.length === 0) {
            // Crear estado inicial si no existe
            await pool.query(`
                INSERT INTO user_status (user_id) VALUES ($1)
            `, [user_id]);

            return res.json({
                success: true,
                status: {
                    user_id: parseInt(user_id),
                    is_banned: false,
                    currently_banned: false,
                    chat_restricted: false,
                    currently_chat_restricted: false,
                    warning_count: 0,
                    is_verified: false,
                    reputation_score: 100
                }
            });
        }

        res.json({
            success: true,
            status: result.rows[0]
        });

    } catch (err) {
        console.error('❌ Error al obtener estado del usuario:', err);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// 📌 Ruta GET para estadísticas de reportes (admin)
router.get('/stats', async (req, res) => {
    try {
        // Obtener estadísticas básicas usando la tabla 'reportes' existente
        const stats = await pool.query(`
            SELECT 
                COUNT(*) as total_reports,
                COUNT(CASE WHEN estado = 'pendiente' THEN 1 END) as pending_reports,
                COUNT(CASE WHEN estado = 'revisado' THEN 1 END) as reviewed_reports,
                COUNT(CASE WHEN estado = 'resuelto' THEN 1 END) as resolved_reports,
                COUNT(CASE WHEN estado = 'descartado' THEN 1 END) as dismissed_reports,
                COUNT(CASE WHEN tipo_reporte = 'inappropriate_content' THEN 1 END) as inappropriate_content,
                COUNT(CASE WHEN tipo_reporte = 'fake_profile' THEN 1 END) as fake_profile,
                COUNT(CASE WHEN tipo_reporte = 'harassment' THEN 1 END) as harassment,
                COUNT(CASE WHEN tipo_reporte = 'spam' THEN 1 END) as spam,
                COUNT(CASE WHEN fecha_reporte > CURRENT_DATE - INTERVAL '7 days' THEN 1 END) as reports_last_week,
                COUNT(CASE WHEN fecha_reporte > CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as reports_last_month
            FROM reportes
        `);

        const userStats = await pool.query(`
            SELECT 
                COUNT(*) as total_users,
                COUNT(CASE WHEN is_banned = TRUE THEN 1 END) as banned_users,
                COUNT(CASE WHEN chat_restricted = TRUE THEN 1 END) as chat_restricted_users,
                COUNT(CASE WHEN is_verified = TRUE THEN 1 END) as verified_users,
                AVG(reputation_score) as avg_reputation
            FROM user_status
        `);

        res.json({
            success: true,
            report_stats: stats.rows[0],
            user_stats: userStats.rows[0]
        });

    } catch (err) {
        console.error('❌ Error al obtener estadísticas:', err);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

module.exports = router;
