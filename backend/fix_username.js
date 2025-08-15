const { Pool } = require('pg');

async function addUsernameColumn() {
    const pool = new Pool({
        connectionString: 'postgresql://anderson:123456@localhost:5432/petmatch',
    });

    try {
        console.log('🔧 Agregando columna username...');
        
        // Agregar columna username
        await pool.query(`
            ALTER TABLE usuarios 
            ADD COLUMN IF NOT EXISTS username VARCHAR(50) UNIQUE;
        `);
        
        console.log('✅ Columna username agregada');
        
        // Generar usernames para usuarios existentes
        const users = await pool.query('SELECT id, nombres FROM usuarios WHERE username IS NULL');
        console.log(`📝 Actualizando ${users.rows.length} usuarios...`);
        
        for (const user of users.rows) {
            let username = user.nombres.toLowerCase().replace(/\s+/g, '');
            let counter = 1;
            let finalUsername = username;
            
            // Verificar unicidad
            while (true) {
                const exists = await pool.query('SELECT id FROM usuarios WHERE username = $1', [finalUsername]);
                if (exists.rows.length === 0) break;
                finalUsername = `${username}${counter++}`;
            }
            
            await pool.query('UPDATE usuarios SET username = $1 WHERE id = $2', [finalUsername, user.id]);
            console.log(`  ✅ ${user.nombres} -> ${finalUsername}`);
        }
        
        console.log('🎉 ¡Proceso completado!');
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await pool.end();
    }
}

addUsernameColumn();
