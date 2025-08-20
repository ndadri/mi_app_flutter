const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://anderson:123456@localhost:5432/petmatch',
});

async function arreglarNotificaciones() {
    try {
        console.log('🔧 ARREGLANDO EL PROBLEMA DE NOTIFICACIONES...\n');
        
        // 1. Verificar la foreign key actual
        console.log('🔍 Verificando foreign keys de notificaciones:');
        const fkQuery = `
            SELECT 
                tc.constraint_name,
                tc.table_name,
                kcu.column_name,
                ccu.table_name AS referenced_table,
                ccu.column_name AS referenced_column
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu 
                ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage ccu 
                ON ccu.constraint_name = tc.constraint_name
            WHERE tc.table_name = 'notificaciones' AND tc.constraint_type = 'FOREIGN KEY'
        `;
        
        const fkResult = await pool.query(fkQuery);
        fkResult.rows.forEach(fk => {
            console.log(`  ${fk.constraint_name}: ${fk.table_name}.${fk.column_name} → ${fk.referenced_table}.${fk.referenced_column}`);
        });
        
        // 2. Verificar si la foreign key apunta a 'matches' en lugar de 'mutual_matches'
        const problemFK = fkResult.rows.find(fk => 
            fk.column_name === 'match_id' && fk.referenced_table === 'matches'
        );
        
        if (problemFK) {
            console.log(`\n⚠️ PROBLEMA ENCONTRADO: La FK ${problemFK.constraint_name} apunta a 'matches' en lugar de 'mutual_matches'`);
            
            // 3. Eliminar la foreign key problemática
            console.log('🗑️ Eliminando foreign key incorrecta...');
            await pool.query(`ALTER TABLE notificaciones DROP CONSTRAINT ${problemFK.constraint_name}`);
            console.log('✅ Foreign key eliminada');
            
            // 4. Crear la foreign key correcta hacia mutual_matches
            console.log('🔗 Creando foreign key correcta hacia mutual_matches...');
            await pool.query(`
                ALTER TABLE notificaciones 
                ADD CONSTRAINT notificaciones_match_id_fkey 
                FOREIGN KEY (match_id) REFERENCES mutual_matches(id)
            `);
            console.log('✅ Foreign key correcta creada');
            
        } else {
            console.log('✅ La foreign key ya está configurada correctamente');
        }
        
        // 5. Ahora crear las notificaciones que faltaron
        console.log('\n📧 Creando notificaciones para matches existentes...');
        
        const matchesQuery = `
            SELECT 
                mm.id as match_id,
                mm.user1_id,
                mm.user2_id,
                m1.nombre as pet1_nombre,
                m2.nombre as pet2_nombre
            FROM mutual_matches mm
            JOIN mascotas m1 ON mm.pet1_id = m1.id
            JOIN mascotas m2 ON mm.pet2_id = m2.id
            WHERE mm.activo = true
            AND NOT EXISTS (
                SELECT 1 FROM notificaciones n 
                WHERE n.match_id = mm.id
            )
        `;
        
        const matchesResult = await pool.query(matchesQuery);
        
        for (const match of matchesResult.rows) {
            // Crear notificaciones para ambos usuarios
            const notificaciones = [
                {
                    usuario_id: match.user1_id,
                    tipo: 'match',
                    titulo: '¡Nuevo Match! 🎉',
                    mensaje: `Tu mascota ${match.pet1_nombre} hizo match con ${match.pet2_nombre}`,
                    match_id: match.match_id
                },
                {
                    usuario_id: match.user2_id,
                    tipo: 'match',
                    titulo: '¡Nuevo Match! 🎉',
                    mensaje: `Tu mascota ${match.pet2_nombre} hizo match con ${match.pet1_nombre}`,
                    match_id: match.match_id
                }
            ];
            
            for (const notif of notificaciones) {
                try {
                    await pool.query(`
                        INSERT INTO notificaciones (usuario_id, tipo, titulo, mensaje, match_id)
                        VALUES ($1, $2, $3, $4, $5)
                    `, [
                        notif.usuario_id,
                        notif.tipo,
                        notif.titulo,
                        notif.mensaje,
                        notif.match_id
                    ]);
                    
                    console.log(`✅ Notificación creada para usuario ${notif.usuario_id} (Match ID: ${notif.match_id})`);
                } catch (error) {
                    console.log(`❌ Error creando notificación: ${error.message}`);
                }
            }
        }
        
        // 6. Verificar estado final
        console.log('\n📊 === ESTADO FINAL ===');
        
        const totalMatches = await pool.query('SELECT COUNT(*) FROM mutual_matches WHERE activo = true');
        const totalNotificaciones = await pool.query('SELECT COUNT(*) FROM notificaciones WHERE tipo = \'match\'');
        
        console.log(`💕 Matches activos: ${totalMatches.rows[0].count}`);
        console.log(`📧 Notificaciones de match: ${totalNotificaciones.rows[0].count}`);
        
        // Mostrar notificaciones creadas
        const notifQuery = `
            SELECT 
                n.id,
                n.usuario_id,
                n.titulo,
                n.mensaje,
                u.nombres
            FROM notificaciones n
            JOIN usuarios u ON n.usuario_id = u.id
            WHERE n.tipo = 'match'
        `;
        
        const notifResult = await pool.query(notifQuery);
        
        if (notifResult.rows.length > 0) {
            console.log('\n📧 NOTIFICACIONES CREADAS:');
            notifResult.rows.forEach(notif => {
                console.log(`  ${notif.nombres}: ${notif.titulo} - ${notif.mensaje}`);
            });
        }
        
        console.log('\n🎉 ¡PROBLEMA DE NOTIFICACIONES ARREGLADO!');
        console.log('✅ Ahora el sistema de matches está completamente funcional');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error('Stack:', error.stack);
    } finally {
        await pool.end();
    }
}

arreglarNotificaciones();
