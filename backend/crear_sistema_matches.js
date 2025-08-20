const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://anderson:123456@localhost:5432/petmatch',
});

async function crearTablasMatches() {
    try {
        console.log('🚀 Creando sistema de matches...');
        
        // Tabla para likes/dislikes
        const tableLikes = `
            CREATE TABLE IF NOT EXISTS pet_likes (
                id SERIAL PRIMARY KEY,
                usuario_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                mascota_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                is_like BOOLEAN NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT NOW(),
                UNIQUE(usuario_id, mascota_id)
            );
        `;
        
        // Tabla para matches (cuando dos usuarios se gustan mutuamente)
        const tableMatches = `
            CREATE TABLE IF NOT EXISTS matches (
                id SERIAL PRIMARY KEY,
                usuario_1 INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                usuario_2 INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                mascota_1 INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                mascota_2 INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                fecha_match TIMESTAMP DEFAULT NOW(),
                activo BOOLEAN DEFAULT true,
                UNIQUE(usuario_1, usuario_2, mascota_1, mascota_2)
            );
        `;
        
        // Tabla para mensajes de matches
        const tableMessages = `
            CREATE TABLE IF NOT EXISTS match_messages (
                id SERIAL PRIMARY KEY,
                match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
                usuario_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                mensaje TEXT NOT NULL,
                fecha_envio TIMESTAMP DEFAULT NOW(),
                leido BOOLEAN DEFAULT false
            );
        `;
        
        // Tabla para notificaciones
        const tableNotifications = `
            CREATE TABLE IF NOT EXISTS notificaciones (
                id SERIAL PRIMARY KEY,
                usuario_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                tipo VARCHAR(50) NOT NULL,
                titulo VARCHAR(200) NOT NULL,
                mensaje TEXT NOT NULL,
                match_id INTEGER REFERENCES matches(id) ON DELETE SET NULL,
                leida BOOLEAN DEFAULT false,
                fecha_creacion TIMESTAMP DEFAULT NOW()
            );
        `;
        
        await pool.query(tableLikes);
        console.log('✅ Tabla pet_likes creada');
        
        await pool.query(tableMatches);
        console.log('✅ Tabla matches creada');
        
        await pool.query(tableMessages);
        console.log('✅ Tabla match_messages creada');
        
        await pool.query(tableNotifications);
        console.log('✅ Tabla notificaciones creada');
        
        // Crear índices para mejor rendimiento (sin referencias problemáticas)
        const indices = [
            'CREATE INDEX IF NOT EXISTS idx_pet_likes_usuario ON pet_likes(usuario_id);',
            'CREATE INDEX IF NOT EXISTS idx_pet_likes_mascota ON pet_likes(mascota_id);',
            'CREATE INDEX IF NOT EXISTS idx_matches_fecha ON matches(fecha_match);',
            'CREATE INDEX IF NOT EXISTS idx_messages_match ON match_messages(match_id);',
            'CREATE INDEX IF NOT EXISTS idx_notifications_usuario ON notificaciones(usuario_id);',
        ];
        
        for (const indice of indices) {
            await pool.query(indice);
        }
        console.log('✅ Índices creados');
        
        console.log('🎉 Sistema de matches configurado correctamente');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

crearTablasMatches();
