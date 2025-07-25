const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function createMatchingSystem() {
    const client = await pool.connect();
    
    try {
        console.log('🔄 Creando sistema completo de matching...');
        
        // 1. Crear tabla de matches
        await client.query(`
            CREATE TABLE IF NOT EXISTS matches (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                pet_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                decision VARCHAR(10) NOT NULL CHECK (decision IN ('like', 'dislike')),
                fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id, pet_id)
            )
        `);
        
        // 2. Crear tabla de preferencias de matching
        await client.query(`
            CREATE TABLE IF NOT EXISTS matching_preferences (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                max_distance_km INTEGER DEFAULT 50,
                species_preference VARCHAR(50)[],
                age_min INTEGER DEFAULT 0,
                age_max INTEGER DEFAULT 20,
                gender_preference VARCHAR(10),
                looking_for VARCHAR(20) DEFAULT 'friendship' CHECK (looking_for IN ('friendship', 'breeding', 'both')),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id)
            )
        `);

        // 3. Crear tabla de matches mutuos
        await client.query(`
            CREATE TABLE IF NOT EXISTS mutual_matches (
                id SERIAL PRIMARY KEY,
                user1_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                user2_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                pet1_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                pet2_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                match_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'blocked', 'expired')),
                UNIQUE(user1_id, user2_id, pet1_id, pet2_id)
            )
        `);

        // 4. Agregar columna de estado de relación a mascotas si no existe
        await client.query(`
            ALTER TABLE mascotas 
            ADD COLUMN IF NOT EXISTS relationship_status VARCHAR(20) DEFAULT 'available' 
            CHECK (relationship_status IN ('available', 'looking_for_partner', 'not_available'))
        `);

        // 5. Crear índices para optimizar consultas
        await client.query(`CREATE INDEX IF NOT EXISTS idx_matches_user_id ON matches(user_id)`);
        await client.query(`CREATE INDEX IF NOT EXISTS idx_matches_pet_id ON matches(pet_id)`);
        await client.query(`CREATE INDEX IF NOT EXISTS idx_matches_decision ON matches(decision)`);
        await client.query(`CREATE INDEX IF NOT EXISTS idx_matching_preferences_user_id ON matching_preferences(user_id)`);
        await client.query(`CREATE INDEX IF NOT EXISTS idx_mutual_matches_users ON mutual_matches(user1_id, user2_id)`);
        await client.query(`CREATE INDEX IF NOT EXISTS idx_mascotas_relationship_status ON mascotas(relationship_status)`);

        // 6. Insertar preferencias por defecto para usuarios existentes
        await client.query(`
            INSERT INTO matching_preferences (user_id, max_distance_km, looking_for)
            SELECT id, 50, 'friendship'
            FROM usuarios
            WHERE id NOT IN (SELECT user_id FROM matching_preferences)
        `);
        
        console.log('✅ Sistema de matching creado exitosamente');
        console.log('📊 Tablas creadas:');
        console.log('   - matches');
        console.log('   - matching_preferences');
        console.log('   - mutual_matches');
        console.log('   - mascotas (actualizada con relationship_status)');
        
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
