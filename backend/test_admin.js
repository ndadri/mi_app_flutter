const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function testAdmin() {
    try {
        const result = await pool.query(`
            SELECT u.*, r.nombre as rol_nombre, r.descripcion as rol_descripcion, r.permisos as rol_permisos
            FROM usuarios u
            LEFT JOIN roles r ON u.id_rol = r.id
            WHERE u.correo = 'admin@petmatch.com'
        `);
        
        if (result.rows.length > 0) {
            const user = result.rows[0];
            console.log('Usuario encontrado:');
            console.log('ID:', user.id);
            console.log('Nombres:', user.nombres);
            console.log('Apellidos:', user.apellidos);
            console.log('Correo:', user.correo);
            console.log('Verificado:', user.verificado);
            console.log('Rol:', user.rol_nombre);
            console.log('Permisos:', JSON.stringify(user.rol_permisos, null, 2));
        } else {
            console.log('Usuario no encontrado');
        }
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        pool.end();
    }
}

testAdmin();
