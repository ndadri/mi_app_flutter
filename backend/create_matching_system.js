const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function createMatchingSystem() {
    const client = await pool.connect();
    
    try {
        console.log('🔄 Creando sistema de matching completo...');
        
        // Crear tabla de preferencias de matching
        await client.query(`
            CREATE TABLE IF NOT EXISTS matching_preferences (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                estado_relacion VARCHAR(20) NOT NULL CHECK (estado_relacion IN ('soltero', 'buscando_pareja', 'no_disponible')),
                distancia_maxima INTEGER DEFAULT 50,
                edad_minima INTEGER DEFAULT 1,
                edad_maxima INTEGER DEFAULT 20,
                especies_preferidas TEXT[],
                genero_preferido VARCHAR(20) CHECK (genero_preferido IN ('macho', 'hembra', 'ambos')),
                fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id)
            )
        `);
        
        // Eliminar tabla de matches anterior si existe y crear la nueva
        await client.query(`DROP TABLE IF EXISTS matches CASCADE`);
        await client.query(`
            CREATE TABLE matches (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                pet_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                owner_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                decision VARCHAR(10) NOT NULL CHECK (decision IN ('like', 'dislike')),
                distancia_km DECIMAL(10,2),
                fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id, pet_id)
            )
        `);
        
        // Crear tabla de matches mutuos
        await client.query(`
            CREATE TABLE IF NOT EXISTS mutual_matches (
                id SERIAL PRIMARY KEY,
                user1_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                user2_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                pet1_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                pet2_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                fecha_match TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                activo BOOLEAN DEFAULT TRUE,
                UNIQUE(user1_id, user2_id, pet1_id, pet2_id)
            )
        `);
        
        // Crear índices
        const indices = [
            'CREATE INDEX IF NOT EXISTS idx_matching_preferences_user_id ON matching_preferences(user_id)',
            'CREATE INDEX IF NOT EXISTS idx_matching_preferences_estado ON matching_preferences(estado_relacion)',
            'CREATE INDEX IF NOT EXISTS idx_matches_user_id ON matches(user_id)',
            'CREATE INDEX IF NOT EXISTS idx_matches_pet_id ON matches(pet_id)',
            'CREATE INDEX IF NOT EXISTS idx_matches_owner_id ON matches(owner_id)',
            'CREATE INDEX IF NOT EXISTS idx_matches_decision ON matches(decision)',
            'CREATE INDEX IF NOT EXISTS idx_mutual_matches_users ON mutual_matches(user1_id, user2_id)'
        ];
        
        for (const index of indices) {
            await client.query(index);
        }
        
        // Insertar preferencias por defecto para usuarios existentes
        await client.query(`
            INSERT INTO matching_preferences (user_id, estado_relacion, distancia_maxima, genero_preferido)
            SELECT id, 'soltero', 50, 'ambos'
            FROM usuarios
            WHERE id NOT IN (SELECT user_id FROM matching_preferences)
        `);
        
        console.log('✅ Sistema de matching creado exitosamente');
        
    } catch (error) {
        console.error('❌ Error creando sistema de matching:', error);
        throw error;
    } finally {
        client.release();
    }
}

// Ejecutar si se llama directamente
if (require.main === module) {
    createMatchingSystem()
        .then(() => {
            console.log('🎉 Sistema de matching completado');
            process.exit(0);
        })
        .catch((error) => {
            console.error('💥 Error:', error);
            process.exit(1);
        });
}

module.exports = createMatchingSystem;
