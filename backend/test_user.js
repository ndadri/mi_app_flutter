const { Pool } = require('pg');

const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'flutter_app',
    password: 'password',
    port: 5432,
});

async function createTestUser() {
    try {
        // Verificar usuarios existentes
        const existingUsers = await pool.query('SELECT * FROM usuarios');
        console.log('👥 Usuarios existentes:', existingUsers.rows.length);
        
        if (existingUsers.rows.length > 0) {
            console.log('📋 Usuarios encontrados:');
            existingUsers.rows.forEach(user => {
                console.log(`  - ID: ${user.id}, Nombres: ${user.nombres}, Email: ${user.correo}`);
            });
        } else {
            console.log('🚫 No hay usuarios en la base de datos');
            
            // Crear usuario de prueba
            const testUser = await pool.query(`
                INSERT INTO usuarios (nombres, apellidos, correo, contraseña, genero, ubicacion, fecha_nacimiento)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                RETURNING *
            `, [
                'Test',
                'Usuario',
                'test@test.com',
                '$2b$10$hashedpassword', // contraseña hasheada
                'Hombre',
                'Test Ciudad',
                '1990-01-01'
            ]);
            
            console.log('✅ Usuario de prueba creado:', testUser.rows[0]);
        }
        
        await pool.end();
    } catch (error) {
        console.error('❌ Error:', error);
        await pool.end();
    }
}

createTestUser();
