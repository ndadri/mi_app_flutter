// ================================================
// SCRIPT PARA CREAR ADMINISTRADOR CON SISTEMA DE ROLES AVANZADO
// Pet Match Flutter App - Sistema de Roles V2
// ================================================

const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function createAdmin() {
    console.log('🔐 Creando usuario administrador con sistema de roles avanzado...');
    
    // ⚠️ CAMBIA ESTOS DATOS POR LOS QUE QUIERAS
    const adminData = {
        nombres: 'Super',
        apellidos: 'Admin',
        correo: 'admin@petmatch.com', // 🚨 CAMBIA ESTE EMAIL
        contraseña: 'admin123456', // 🚨 CAMBIA ESTA CONTRASEÑA
        genero: 'Otro',
        ubicacion: 'Sistema',
        edad: 30,
        fecha_nacimiento: '1994-01-01'
    };
    
    try {
        // Verificar que el sistema de roles esté configurado
        console.log('🔍 Verificando sistema de roles...');
        const rolesResult = await pool.query('SELECT id, nombre FROM roles WHERE nombre = $1', ['administrador']);
        
        if (rolesResult.rows.length === 0) {
            console.log('❌ Error: Sistema de roles no configurado');
            console.log('💡 Primero ejecuta: create_advanced_roles_system.sql');
            return;
        }
        
        const adminRoleId = rolesResult.rows[0].id;
        console.log(`✅ Rol administrador encontrado (ID: ${adminRoleId})`);
        
        // Verificar si el usuario ya existe
        const existeAdmin = await pool.query(
            'SELECT id, id_rol FROM usuarios WHERE correo = $1',
            [adminData.correo]
        );
        
        if (existeAdmin.rows.length > 0) {
            console.log('⚠️ Ya existe un usuario con este correo');
            console.log('💡 Convertiendo usuario existente en administrador...');
            
            await pool.query(
                'UPDATE usuarios SET id_rol = $1 WHERE correo = $2',
                [adminRoleId, adminData.correo]
            );
            
            console.log('✅ Usuario convertido a administrador exitosamente');
            return;
        }
        
        // Hashear la contraseña
        console.log('🔐 Hasheando contraseña...');
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(adminData.contraseña, salt);
        
        // Crear el usuario administrador
        console.log('👤 Creando usuario administrador...');
        const result = await pool.query(`
            INSERT INTO usuarios (
                nombres, apellidos, correo, contraseña, genero, 
                ubicacion, edad, fecha_nacimiento, id_rol, verificado, codigo_verificacion
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
            RETURNING id, nombres, apellidos, correo
        `, [
            adminData.nombres,
            adminData.apellidos, 
            adminData.correo,
            hashedPassword,
            adminData.genero,
            adminData.ubicacion,
            adminData.edad,
            adminData.fecha_nacimiento,
            adminRoleId, // ID del rol administrador (normalmente 2)
            true, // Ya verificado
            '000000' // Código dummy
        ]);
        
        const admin = result.rows[0];
        
        // Obtener información completa del admin con rol
        const adminComplete = await pool.query(`
            SELECT u.*, r.nombre as rol_nombre, r.descripcion as rol_descripcion
            FROM usuarios u
            JOIN roles r ON u.id_rol = r.id
            WHERE u.id = $1
        `, [admin.id]);
        
        const adminInfo = adminComplete.rows[0];
        
        console.log('🎉 ¡Administrador creado exitosamente!');
        console.log('📋 Detalles:');
        console.log(`   ID: ${adminInfo.id}`);
        console.log(`   Nombre: ${adminInfo.nombres} ${adminInfo.apellidos}`);
        console.log(`   Email: ${adminInfo.correo}`);
        console.log(`   Rol: ${adminInfo.rol_nombre} (ID: ${adminInfo.id_rol})`);
        console.log(`   Descripción: ${adminInfo.rol_descripcion}`);
        console.log('');
        console.log('🔑 Credenciales de acceso:');
        console.log(`   Email: ${adminData.correo}`);
        console.log(`   Contraseña: ${adminData.contraseña}`);
        console.log('');
        console.log('⚠️ IMPORTANTE: Cambia la contraseña después del primer login');
        console.log('');
        console.log('🔧 Permisos del administrador:');
        
        // Mostrar permisos
        const permisos = await pool.query(`
            SELECT r.permisos
            FROM usuarios u
            JOIN roles r ON u.id_rol = r.id
            WHERE u.id = $1
        `, [admin.id]);
        
        if (permisos.rows.length > 0) {
            console.log(JSON.stringify(permisos.rows[0].permisos, null, 2));
        }
        
    } catch (error) {
        console.error('❌ Error al crear administrador:', error.message);
        
        if (error.code === '23505') {
            console.log('💡 El correo ya está registrado');
        } else if (error.code === '42703') {
            console.log('💡 Primero ejecuta el script SQL: create_advanced_roles_system.sql');
        } else if (error.code === '23503') {
            console.log('💡 Error de clave foránea - Verifica que la tabla roles esté creada');
        }
    } finally {
        await pool.end();
        console.log('🔌 Conexión cerrada');
    }
}

// Ejecutar el script
createAdmin();
