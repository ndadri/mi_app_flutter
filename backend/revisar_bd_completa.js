const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://Alexis:123@localhost:5432/petmatch',
});

async function revisarBaseDatos() {
    try {
        console.log('🔍 REVISANDO TODA LA BASE DE DATOS DE TU PROYECTO...\n');
        
        // 1. Listar todas las tablas
        console.log('📋 === TODAS LAS TABLAS EN LA BASE DE DATOS ===');
        const tablasQuery = `
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name
        `;
        
        const tablasResult = await pool.query(tablasQuery);
        console.log('Tablas encontradas:');
        tablasResult.rows.forEach((tabla, index) => {
            console.log(`${index + 1}. ${tabla.table_name}`);
        });
        
        console.log('\n' + '='.repeat(60) + '\n');
        
        // 2. Para cada tabla, mostrar su estructura
        for (const tabla of tablasResult.rows) {
            const tableName = tabla.table_name;
            console.log(`📊 ESTRUCTURA DE LA TABLA: ${tableName.toUpperCase()}`);
            
            // Obtener columnas
            const columnasQuery = `
                SELECT 
                    column_name,
                    data_type,
                    is_nullable,
                    column_default,
                    character_maximum_length
                FROM information_schema.columns 
                WHERE table_name = $1 
                ORDER BY ordinal_position
            `;
            
            const columnasResult = await pool.query(columnasQuery, [tableName]);
            
            console.log('Columnas:');
            columnasResult.rows.forEach((col, index) => {
                const nullable = col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL';
                const length = col.character_maximum_length ? `(${col.character_maximum_length})` : '';
                const defaultVal = col.column_default ? ` DEFAULT ${col.column_default}` : '';
                console.log(`  ${index + 1}. ${col.column_name} - ${col.data_type}${length} ${nullable}${defaultVal}`);
            });
            
            // Obtener claves primarias
            const pkQuery = `
                SELECT a.attname
                FROM pg_index i
                JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
                WHERE i.indrelid = $1::regclass AND i.indisprimary
            `;
            
            try {
                const pkResult = await pool.query(pkQuery, [tableName]);
                if (pkResult.rows.length > 0) {
                    console.log('Claves primarias:');
                    pkResult.rows.forEach(pk => {
                        console.log(`  🔑 ${pk.attname}`);
                    });
                }
            } catch (error) {
                // Ignorar errores de PK si no existen
            }
            
            // Contar registros
            try {
                const countQuery = `SELECT COUNT(*) FROM ${tableName}`;
                const countResult = await pool.query(countQuery);
                console.log(`📊 Registros: ${countResult.rows[0].count}`);
            } catch (error) {
                console.log(`📊 No se pudo contar registros: ${error.message}`);
            }
            
            console.log('\n' + '-'.repeat(40) + '\n');
        }
        
        // 3. Mostrar relaciones (foreign keys)
        console.log('🔗 === RELACIONES ENTRE TABLAS (FOREIGN KEYS) ===');
        const fkQuery = `
            SELECT
                tc.table_name, 
                kcu.column_name, 
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name 
            FROM 
                information_schema.table_constraints AS tc 
                JOIN information_schema.key_column_usage AS kcu
                  ON tc.constraint_name = kcu.constraint_name
                  AND tc.table_schema = kcu.table_schema
                JOIN information_schema.constraint_column_usage AS ccu
                  ON ccu.constraint_name = tc.constraint_name
                  AND ccu.table_schema = tc.table_schema
            WHERE tc.constraint_type = 'FOREIGN KEY'
            ORDER BY tc.table_name, kcu.column_name
        `;
        
        const fkResult = await pool.query(fkQuery);
        if (fkResult.rows.length > 0) {
            fkResult.rows.forEach((fk, index) => {
                console.log(`${index + 1}. ${fk.table_name}.${fk.column_name} → ${fk.foreign_table_name}.${fk.foreign_column_name}`);
            });
        } else {
            console.log('No se encontraron foreign keys');
        }
        
        console.log('\n' + '='.repeat(60) + '\n');
        
        // 4. Datos específicos para el sistema de matches
        console.log('🎯 === DATOS ESPECÍFICOS PARA EL SISTEMA DE MATCHES ===');
        
        if (tablasResult.rows.some(t => t.table_name === 'usuarios')) {
            console.log('👥 USUARIOS:');
            const usuariosQuery = `SELECT id, nombres, apellidos, correo FROM usuarios LIMIT 5`;
            const usuariosResult = await pool.query(usuariosQuery);
            usuariosResult.rows.forEach(user => {
                console.log(`  ID: ${user.id} - ${user.nombres} ${user.apellidos} (${user.correo})`);
            });
        }
        
        if (tablasResult.rows.some(t => t.table_name === 'mascotas')) {
            console.log('\n🐕 MASCOTAS:');
            const mascotasQuery = `SELECT id, nombre, id_usuario FROM mascotas LIMIT 5`;
            const mascotasResult = await pool.query(mascotasQuery);
            mascotasResult.rows.forEach(pet => {
                console.log(`  ID: ${pet.id} - ${pet.nombre} (Dueño ID: ${pet.id_usuario})`);
            });
        }
        
        if (tablasResult.rows.some(t => t.table_name === 'pet_likes')) {
            console.log('\n👍 PET_LIKES:');
            const likesQuery = `SELECT * FROM pet_likes LIMIT 5`;
            const likesResult = await pool.query(likesQuery);
            likesResult.rows.forEach(like => {
                console.log(`  Usuario ${like.usuario_id} → Mascota ${like.mascota_id} (${like.is_like ? 'LIKE' : 'DISLIKE'})`);
            });
        }
        
        if (tablasResult.rows.some(t => t.table_name === 'mutual_matches')) {
            console.log('\n💕 MUTUAL_MATCHES:');
            const matchesQuery = `SELECT * FROM mutual_matches LIMIT 5`;
            const matchesResult = await pool.query(matchesQuery);
            if (matchesResult.rows.length > 0) {
                matchesResult.rows.forEach(match => {
                    console.log(`  Match ID: ${match.id} - Usuario ${match.user1_id} ↔ Usuario ${match.user2_id} (Mascotas: ${match.pet1_id} ↔ ${match.pet2_id})`);
                });
            } else {
                console.log('  No hay matches registrados');
            }
        }
        
        if (tablasResult.rows.some(t => t.table_name === 'notificaciones')) {
            console.log('\n🔔 NOTIFICACIONES:');
            const notifsQuery = `SELECT * FROM notificaciones LIMIT 5`;
            const notifsResult = await pool.query(notifsQuery);
            if (notifsResult.rows.length > 0) {
                notifsResult.rows.forEach(notif => {
                    console.log(`  Usuario ${notif.usuario_id}: ${notif.titulo} - ${notif.mensaje}`);
                });
            } else {
                console.log('  No hay notificaciones registradas');
            }
        }
        
        console.log('\n🎉 REVISIÓN COMPLETA DE LA BASE DE DATOS TERMINADA');
        
    } catch (error) {
        console.error('❌ Error revisando la base de datos:', error.message);
        console.error('Stack:', error.stack);
    } finally {
        await pool.end();
    }
}

revisarBaseDatos();
