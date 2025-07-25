const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function createReportSystem() {
    const client = await pool.connect();
    
    try {
        console.log('🔄 Creando sistema de reportes...');
        
        // 1. Crear tabla de reportes
        await client.query(`
            CREATE TABLE IF NOT EXISTS user_reports (
                id SERIAL PRIMARY KEY,
                reporter_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                reported_user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                reported_pet_id INTEGER REFERENCES mascotas(id) ON DELETE CASCADE,
                report_type VARCHAR(50) NOT NULL CHECK (report_type IN (
                    'inappropriate_content', 
                    'fake_profile', 
                    'harassment', 
                    'spam', 
                    'offensive_behavior',
                    'inappropriate_pet_image',
                    'other'
                )),
                reason TEXT NOT NULL,
                additional_details TEXT,
                status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
                admin_notes TEXT,
                reviewed_by INTEGER REFERENCES usuarios(id),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                reviewed_at TIMESTAMP,
                UNIQUE(reporter_id, reported_user_id, report_type)
            );
        `);
        console.log('✅ Tabla user_reports creada');

        // 2. Crear tabla de acciones administrativas
        await client.query(`
            CREATE TABLE IF NOT EXISTS admin_actions (
                id SERIAL PRIMARY KEY,
                admin_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                target_user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                action_type VARCHAR(30) NOT NULL CHECK (action_type IN (
                    'warning', 
                    'temporary_ban', 
                    'permanent_ban', 
                    'profile_restriction',
                    'chat_restriction',
                    'account_verified'
                )),
                reason TEXT NOT NULL,
                duration_hours INTEGER, -- Para bans temporales
                expires_at TIMESTAMP,
                is_active BOOLEAN DEFAULT TRUE,
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log('✅ Tabla admin_actions creada');

        // 3. Crear tabla de estado de usuario (para bans, warnings, etc.)
        await client.query(`
            CREATE TABLE IF NOT EXISTS user_status (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE UNIQUE,
                is_banned BOOLEAN DEFAULT FALSE,
                ban_expires_at TIMESTAMP,
                chat_restricted BOOLEAN DEFAULT FALSE,
                chat_restriction_expires_at TIMESTAMP,
                warning_count INTEGER DEFAULT 0,
                last_warning_at TIMESTAMP,
                is_verified BOOLEAN DEFAULT FALSE,
                reputation_score INTEGER DEFAULT 100,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log('✅ Tabla user_status creada');

        // 4. Crear índices
        await client.query(`
            CREATE INDEX IF NOT EXISTS idx_user_reports_reported_user ON user_reports(reported_user_id);
            CREATE INDEX IF NOT EXISTS idx_user_reports_status ON user_reports(status);
            CREATE INDEX IF NOT EXISTS idx_user_reports_type ON user_reports(report_type);
            CREATE INDEX IF NOT EXISTS idx_admin_actions_target_user ON admin_actions(target_user_id);
            CREATE INDEX IF NOT EXISTS idx_admin_actions_active ON admin_actions(is_active);
            CREATE INDEX IF NOT EXISTS idx_user_status_user_id ON user_status(user_id);
        `);
        console.log('✅ Índices creados');

        // 5. Insertar estado inicial para usuarios existentes
        await client.query(`
            INSERT INTO user_status (user_id)
            SELECT id FROM usuarios
            WHERE id NOT IN (SELECT user_id FROM user_status);
        `);
        console.log('✅ Estados iniciales creados para usuarios existentes');

        console.log('🎉 Sistema de reportes creado exitosamente');
        
    } catch (error) {
        console.error('❌ Error creando sistema de reportes:', error);
        throw error;
    } finally {
        client.release();
    }
}

// Ejecutar si se llama directamente
if (require.main === module) {
    createReportSystem()
        .then(() => {
            console.log('🎉 Sistema de reportes completado');
            process.exit(0);
        })
        .catch((error) => {
            console.error('💥 Error:', error);
            process.exit(1);
        });
}

module.exports = createReportSystem;
