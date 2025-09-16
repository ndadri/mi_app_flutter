const { Pool } = require('pg');
const bcrypt = require('bcrypt');

const pool = new Pool({
    connectionString: 'postgresql://Alexis:123@localhost:5432/petmatch'
});

async function crearUsuarioPrueba() {
    try {
        console.log('🔧 Creando usuario de prueba...');
        
        // Verificar si ya existe
        const existingUser = await pool.query('SELECT id FROM usuarios WHERE correo = $1', ['admin@test.com']);
        
        if (existingUser.rows.length > 0) {
            console.log('✅ El usuario admin@test.com ya existe!');
            console.log('📧 Email: admin@test.com');
            console.log('🔐 Contraseña: admin123');
            await pool.end();
            return;
        }
        
        // Encriptar contraseña
        const hashedPassword = await bcrypt.hash('admin123', 10);
        
        // Crear usuario
        const query = `
            INSERT INTO usuarios (nombres, apellidos, correo, contraseña, genero, ubicacion, fecha_nacimiento)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING id, nombres, apellidos, correo
        `;
        
        const values = [
            'Admin',
            'Test',
            'admin@test.com',
            hashedPassword,
            'Prefiero no decirlo',
            'Ciudad de Prueba',
            '1990-01-01'
        ];
        
        const result = await pool.query(query, values);
        
        console.log('✅ Usuario de prueba creado exitosamente!');
        console.log('📧 Email: admin@test.com');
        console.log('🔐 Contraseña: admin123');
        console.log('👤 Usuario:', result.rows[0]);
        
        await pool.end();
    } catch (error) {
        console.error('❌ Error creando usuario:', error.message);
        await pool.end();
    }
}

crearUsuarioPrueba();
