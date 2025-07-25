const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

const createMissingTables = async () => {
    const client = await pool.connect();
    
    try {
        console.log('🔧 Creando tablas faltantes...');
        
        // Crear tabla matching_preferences
        await client.query(`
            CREATE TABLE IF NOT EXISTS matching_preferences (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                estado_relacion VARCHAR(20) NOT NULL DEFAULT 'soltero' CHECK (estado_relacion IN ('soltero', 'buscando_pareja', 'no_disponible')),
                distancia_maxima INTEGER DEFAULT 50,
                edad_minima INTEGER DEFAULT 1,
                edad_maxima INTEGER DEFAULT 20,
                especies_preferidas TEXT[],
                genero_preferido VARCHAR(20) DEFAULT 'ambos' CHECK (genero_preferido IN ('macho', 'hembra', 'ambos')),
                max_distance_km INTEGER DEFAULT 50,
                age_min INTEGER DEFAULT 0,
                age_max INTEGER DEFAULT 20,
                species_preference TEXT[],
                gender_preference VARCHAR(20),
                looking_for VARCHAR(20) DEFAULT 'friendship',
                fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id)
            );
        `);
        console.log('✅ Tabla matching_preferences creada');
        
        // Crear tabla matches
        await client.query(`
            DROP TABLE IF EXISTS matches CASCADE;
            CREATE TABLE matches (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                pet_id INTEGER NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
                owner_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
                decision VARCHAR(10) NOT NULL CHECK (decision IN ('like', 'dislike')),
                distancia_km DECIMAL(10,2),
                fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id, pet_id)
            );
        `);
        console.log('✅ Tabla matches creada');
        
        // Crear tabla mutual_matches
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
            );
        `);
        console.log('✅ Tabla mutual_matches creada');
        
        // Crear índices
        await client.query(`
            CREATE INDEX IF NOT EXISTS idx_matching_preferences_user_id ON matching_preferences(user_id);
            CREATE INDEX IF NOT EXISTS idx_matches_user_id ON matches(user_id);
            CREATE INDEX IF NOT EXISTS idx_matches_pet_id ON matches(pet_id);
            CREATE INDEX IF NOT EXISTS idx_matches_owner_id ON matches(owner_id);
            CREATE INDEX IF NOT EXISTS idx_matches_decision ON matches(decision);
            CREATE INDEX IF NOT EXISTS idx_mutual_matches_users ON mutual_matches(user1_id, user2_id);
        `);
        console.log('✅ Índices creados');
        
        // Insertar preferencias por defecto para usuarios existentes
        await client.query(`
            INSERT INTO matching_preferences (user_id, estado_relacion, distancia_maxima, genero_preferido, max_distance_km, age_min, age_max, looking_for)
            SELECT 
                id, 
                'soltero', 
                50, 
                'ambos', 
                50, 
                0, 
                20, 
                'friendship'
            FROM usuarios
            WHERE id NOT IN (SELECT user_id FROM matching_preferences);
        `);
        console.log('✅ Preferencias por defecto insertadas');
        
        console.log('🎉 Todas las tablas creadas exitosamente');
        
    } catch (error) {
        console.error('❌ Error creando tablas:', error);
        throw error;
    } finally {
        client.release();
    }
};

// Ejecutar si es llamado directamente
if (require.main === module) {
    require('dotenv').config();
    createMissingTables()
        .then(() => {
            console.log('🎉 Proceso completado exitosamente');
            process.exit(0);
        })
        .catch((error) => {
            console.error('💥 Error en el proceso:', error);
            process.exit(1);
        });
}

module.exports = createMissingTables;
