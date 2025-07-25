// ================================================
// SCRIPT PARA CONFIGURAR SISTEMA DE ROLES AVANZADO
// Pet Match Flutter App
// ================================================

const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

async function setupRoles() {
    console.log('🚀 Configurando sistema de roles avanzado...');
    
    try {
        // Leer el archivo SQL
        const sqlFilePath = path.join(__dirname, 'create_advanced_roles_system.sql');
        const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
        
        console.log('📁 Archivo SQL leído exitosamente');
        
        // Ejecutar el SQL
        await pool.query(sqlContent);
        
        console.log('✅ Sistema de roles configurado exitosamente');
        
        // Verificar que todo se creó correctamente
        console.log('\n🔍 Verificando configuración...');
        
        // Verificar tabla roles
        const rolesResult = await pool.query('SELECT id, nombre FROM roles ORDER BY id');
        console.log('\n📋 Roles disponibles:');
        rolesResult.rows.forEach(role => {
            console.log(`   ${role.id}. ${role.nombre}`);
        });
        
        // Verificar columna id_rol en usuarios
        const columnCheck = await pool.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'usuarios' AND column_name = 'id_rol'
        `);
        
        if (columnCheck.rows.length > 0) {
            console.log('✅ Columna id_rol agregada a tabla usuarios');
        } else {
            console.log('❌ Error: Columna id_rol no encontrada');
        }
        
        // Verificar vista
        const viewCheck = await pool.query(`
            SELECT viewname 
            FROM pg_views 
            WHERE viewname = 'vista_usuarios_roles'
        `);
        
        if (viewCheck.rows.length > 0) {
            console.log('✅ Vista vista_usuarios_roles creada');
        } else {
            console.log('❌ Error: Vista no encontrada');
        }
        
        console.log('\n🎉 Configuración completada! Ahora puedes ejecutar create_admin.js');
        
    } catch (error) {
        console.error('❌ Error configurando sistema de roles:', error.message);
        
        if (error.code === '42P07') {
            console.log('💡 Algunos elementos ya existían - esto es normal');
        }
    } finally {
        await pool.end();
        console.log('🔌 Conexión cerrada');
    }
}

// Ejecutar el setup
setupRoles();
