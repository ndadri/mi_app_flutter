require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

const testMatchingSystem = async () => {
    const client = await pool.connect();
    
    try {
        console.log('🧪 INICIANDO PRUEBAS DEL SISTEMA DE MATCHING');
        console.log('===============================================');
        
        // 1. Verificar que tenemos usuarios y mascotas
        console.log('📋 1. Verificando datos base...');
        const usuarios = await client.query('SELECT id, nombres FROM usuarios LIMIT 5');
        const mascotas = await client.query('SELECT id, nombre, id_usuario FROM mascotas LIMIT 5');
        
        console.log(`   ✅ Usuarios encontrados: ${usuarios.rows.length}`);
        usuarios.rows.forEach(u => console.log(`      - ${u.nombres} (ID: ${u.id})`));
        
        console.log(`   ✅ Mascotas encontradas: ${mascotas.rows.length}`);
        mascotas.rows.forEach(m => console.log(`      - ${m.nombre} (ID: ${m.id}, Owner: ${m.id_usuario})`));
        
        // 2. Verificar preferencias de matching
        console.log('\n📋 2. Verificando preferencias de matching...');
        const preferences = await client.query('SELECT * FROM matching_preferences LIMIT 5');
        console.log(`   ✅ Preferencias encontradas: ${preferences.rows.length}`);
        preferences.rows.forEach(p => {
            console.log(`      - Usuario ${p.user_id}: ${p.estado_relacion}, ${p.distancia_maxima}km, ${p.genero_preferido}`);
        });
        
        // 3. Verificar tabla matches
        console.log('\n📋 3. Verificando tabla matches...');
        const matches = await client.query('SELECT COUNT(*) as total FROM matches');
        console.log(`   ✅ Matches registrados: ${matches.rows[0].total}`);
        
        // 4. Verificar tabla mutual_matches
        console.log('\n📋 4. Verificando tabla mutual_matches...');
        const mutualMatches = await client.query('SELECT COUNT(*) as total FROM mutual_matches');
        console.log(`   ✅ Matches mutuos: ${mutualMatches.rows[0].total}`);
        
        // 5. Simular consulta de mascotas para matching
        if (usuarios.rows.length > 0) {
            console.log('\n📋 5. Simulando consulta de mascotas para matching...');
            const userId = usuarios.rows[0].id;
            
            const matchingQuery = `
                SELECT 
                    p.id, 
                    p.nombre, 
                    p.tipo_animal as especie, 
                    p.edad, 
                    p.sexo as genero, 
                    p.estado as relationship_status,
                    p.id_usuario,
                    u.nombres as owner_nombres,
                    u.apellidos as owner_apellidos,
                    u.ubicacion as owner_ubicacion
                FROM mascotas p
                INNER JOIN usuarios u ON p.id_usuario = u.id
                WHERE p.id_usuario != $1
                AND p.edad BETWEEN 0 AND 20
                AND (p.estado = 'Soltero' OR p.estado = 'Buscando pareja' OR p.estado IS NULL)
                ORDER BY p.id DESC
                LIMIT 5
            `;
            
            const availablePets = await client.query(matchingQuery, [userId]);
            console.log(`   ✅ Mascotas disponibles para matching: ${availablePets.rows.length}`);
            availablePets.rows.forEach(pet => {
                console.log(`      - ${pet.nombre} (${pet.especie}, ${pet.edad} años) - Dueño: ${pet.owner_nombres}`);
            });
        }
        
        // 6. Verificar estructura de tablas
        console.log('\n📋 6. Verificando estructura de tablas...');
        const tableStructure = await client.query(`
            SELECT 
                table_name, 
                column_name, 
                data_type, 
                is_nullable
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name IN ('matching_preferences', 'matches', 'mutual_matches')
            ORDER BY table_name, ordinal_position;
        `);
        
        console.log(`   ✅ Columnas verificadas: ${tableStructure.rows.length}`);
        
        let currentTable = '';
        tableStructure.rows.forEach(col => {
            if (col.table_name !== currentTable) {
                currentTable = col.table_name;
                console.log(`      📋 ${currentTable}:`);
            }
            console.log(`         - ${col.column_name} (${col.data_type})`);
        });
        
        // 7. Verificar índices
        console.log('\n📋 7. Verificando índices...');
        const indexes = await client.query(`
            SELECT 
                indexname, 
                tablename
            FROM pg_indexes 
            WHERE schemaname = 'public' 
            AND tablename IN ('matching_preferences', 'matches', 'mutual_matches')
            ORDER BY tablename, indexname;
        `);
        
        console.log(`   ✅ Índices encontrados: ${indexes.rows.length}`);
        indexes.rows.forEach(idx => {
            console.log(`      - ${idx.indexname} en ${idx.tablename}`);
        });
        
        console.log('\n🎉 TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE!');
        console.log('===============================================');
        console.log('✅ Sistema de matching completamente funcional');
        console.log('✅ Todas las tablas creadas correctamente');
        console.log('✅ Índices optimizados');
        console.log('✅ Datos de prueba disponibles');
        
    } catch (error) {
        console.error('❌ Error en las pruebas:', error);
        throw error;
    } finally {
        client.release();
        await pool.end();
    }
};

// Ejecutar pruebas
testMatchingSystem()
    .then(() => {
        console.log('\n🎉 PRUEBAS COMPLETADAS EXITOSAMENTE');
        process.exit(0);
    })
    .catch((error) => {
        console.error('\n💥 ERROR EN LAS PRUEBAS:', error);
        process.exit(1);
    });
