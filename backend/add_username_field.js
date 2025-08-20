const { Pool } = require('pg');

const pool = new Pool({
    connectionString: 'postgresql://Alexis:123@localhost:5432/petmatch',
});

async function addUsernameField() {
    try {
        console.log('🔧 Agregando campo username a la tabla usuarios...');
        
        // Agregar columna username
        await pool.query(`
            ALTER TABLE usuarios 
            ADD COLUMN IF NOT EXISTS username VARCHAR(50) UNIQUE;
        `);
        
        console.log('✅ Campo username agregado exitosamente');
        
        // Crear usernames automáticamente para usuarios existentes basados en nombres
        console.log('🔄 Generando usernames para usuarios existentes...');
        
        const existingUsers = await pool.query('SELECT id, nombres, correo FROM usuarios WHERE username IS NULL');
        
        for (const user of existingUsers.rows) {
            // Generar username basado en nombres (sin espacios y en minúsculas)
            let baseUsername = user.nombres.toLowerCase().replace(/\s+/g, '');
            let username = baseUsername;
            let counter = 1;
            
            // Verificar si el username ya existe y agregar número si es necesario
            while (true) {
                const existingUsername = await pool.query('SELECT id FROM usuarios WHERE username = $1', [username]);
                if (existingUsername.rows.length === 0) {
                    break;
                }
                username = `${baseUsername}${counter}`;
                counter++;
            }
            
            // Actualizar el usuario con el nuevo username
            await pool.query('UPDATE usuarios SET username = $1 WHERE id = $2', [username, user.id]);
            console.log(`  ✅ Usuario ${user.correo} -> username: ${username}`);
        }
        
        console.log('🎉 Proceso completado exitosamente');
        await pool.end();
    } catch (error) {
        console.error('❌ Error:', error.message);
        await pool.end();
    }
}

addUsernameField();
