#!/usr/bin/env node

/**
 * DIAGNÓSTICO COMPLETO DEL PROYECTO PET MATCH
 * 
 * Este script verifica el estado completo del proyecto incluyendo:
 * - Backend (Node.js/Express)
 * - Frontend (Flutter)
 * - Base de datos (PostgreSQL)
 * - Configuración y archivos necesarios
 */

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

// Colores para la consola
const colors = {
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m',
    white: '\x1b[37m',
    reset: '\x1b[0m'
};

const log = (message, color = 'white') => {
    console.log(colors[color] + message + colors.reset);
};

const checkSection = (title) => {
    log(`\n${'='.repeat(60)}`, 'cyan');
    log(`${title}`, 'cyan');
    log(`${'='.repeat(60)}`, 'cyan');
};

const checkItem = (item, status, details = '') => {
    const symbol = status ? '✅' : '❌';
    const color = status ? 'green' : 'red';
    log(`${symbol} ${item}`, color);
    if (details) {
        log(`   ${details}`, 'yellow');
    }
};

const checkWarning = (item, details = '') => {
    log(`⚠️  ${item}`, 'yellow');
    if (details) {
        log(`   ${details}`, 'yellow');
    }
};

const diagnosticoPetMatch = async () => {
    log('🔍 INICIANDO DIAGNÓSTICO DEL PROYECTO PET MATCH', 'magenta');
    log('📅 Fecha: ' + new Date().toLocaleString(), 'magenta');
    
    const issues = [];
    const warnings = [];
    
    // Moverse al directorio padre para acceder a todos los archivos
    const rootPath = path.join(__dirname, '..');
    
    // ===============================
    // 1. VERIFICAR ESTRUCTURA DE ARCHIVOS
    // ===============================
    checkSection('1. ESTRUCTURA DE ARCHIVOS');
    
    const requiredFiles = [
        'backend/package.json',
        'backend/src/index.js',
        'backend/routes/authRoutes.js',
        'backend/routes/petRoutes.js',
        'pubspec.yaml',
        'lib/main.dart',
        'lib/auth_provider.dart',
        'lib/login_page.dart',
        'lib/register_page.dart',
        'lib/home_page.dart'
    ];
    
    for (const file of requiredFiles) {
        const fullPath = path.join(rootPath, file);
        const exists = fs.existsSync(fullPath);
        checkItem(file, exists);
        if (!exists) {
            issues.push(`Archivo faltante: ${file}`);
        }
    }
    
    // ===============================
    // 2. VERIFICAR CONFIGURACIÓN DEL BACKEND
    // ===============================
    checkSection('2. CONFIGURACIÓN DEL BACKEND');
    
    // Verificar package.json
    try {
        const packageJsonPath = path.join(rootPath, 'backend/package.json');
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
        checkItem('package.json válido', true);
        
        const requiredDeps = [
            'express', 'pg', 'bcryptjs', 'nodemailer', 'multer', 'cors', 'dotenv'
        ];
        
        for (const dep of requiredDeps) {
            const exists = packageJson.dependencies && packageJson.dependencies[dep];
            checkItem(`Dependencia: ${dep}`, exists);
            if (!exists) {
                issues.push(`Dependencia faltante: ${dep}`);
            }
        }
        
    } catch (error) {
        checkItem('package.json válido', false, error.message);
        issues.push('Error en package.json: ' + error.message);
    }
    
    // Verificar variables de entorno
    checkItem('DATABASE_URL', !!process.env.DATABASE_URL);
    checkItem('EMAIL_USER', !!process.env.EMAIL_USER);
    checkItem('EMAIL_PASS', !!process.env.EMAIL_PASS);
    
    if (!process.env.DATABASE_URL) {
        issues.push('Variable DATABASE_URL no configurada');
    }
    if (!process.env.EMAIL_USER) {
        warnings.push('Variable EMAIL_USER no configurada - funcionalidad de email limitada');
    }
    if (!process.env.EMAIL_PASS) {
        warnings.push('Variable EMAIL_PASS no configurada - funcionalidad de email limitada');
    }
    
    // ===============================
    // 3. VERIFICAR BASE DE DATOS
    // ===============================
    checkSection('3. BASE DE DATOS');
    
    if (process.env.DATABASE_URL) {
        const pool = new Pool({
            connectionString: process.env.DATABASE_URL,
        });
        
        try {
            const client = await pool.connect();
            checkItem('Conexión a base de datos', true);
            
            // Verificar tablas requeridas
            const requiredTables = [
                'usuarios', 'mascotas', 'roles', 'matching_preferences', 'matches', 'mutual_matches'
            ];
            
            for (const table of requiredTables) {
                try {
                    const result = await client.query(`
                        SELECT EXISTS (
                            SELECT FROM information_schema.tables 
                            WHERE table_schema = 'public' 
                            AND table_name = $1
                        );
                    `, [table]);
                    
                    const exists = result.rows[0].exists;
                    checkItem(`Tabla: ${table}`, exists);
                    
                    if (!exists) {
                        issues.push(`Tabla faltante: ${table}`);
                    }
                } catch (err) {
                    checkItem(`Tabla: ${table}`, false, err.message);
                    issues.push(`Error verificando tabla ${table}: ${err.message}`);
                }
            }
            
            // Verificar integridad de datos
            try {
                const userCount = await client.query('SELECT COUNT(*) FROM usuarios');
                const petCount = await client.query('SELECT COUNT(*) FROM mascotas');
                const roleCount = await client.query('SELECT COUNT(*) FROM roles');
                
                log(`📊 Estadísticas de la base de datos:`, 'blue');
                log(`   Usuarios: ${userCount.rows[0].count}`, 'blue');
                log(`   Mascotas: ${petCount.rows[0].count}`, 'blue');
                log(`   Roles: ${roleCount.rows[0].count}`, 'blue');
                
                if (roleCount.rows[0].count == 0) {
                    warnings.push('No hay roles configurados en la base de datos');
                }
                
            } catch (err) {
                checkWarning('Error obteniendo estadísticas', err.message);
            }
            
            client.release();
            await pool.end();
            
        } catch (error) {
            checkItem('Conexión a base de datos', false, error.message);
            issues.push('Error de base de datos: ' + error.message);
        }
    } else {
        checkItem('Configuración de base de datos', false, 'DATABASE_URL no configurada');
        issues.push('DATABASE_URL no configurada');
    }
    
    // ===============================
    // 4. VERIFICAR CONFIGURACIÓN DE FLUTTER
    // ===============================
    checkSection('4. CONFIGURACIÓN DE FLUTTER');
    
    try {
        const pubspecPath = path.join(rootPath, 'pubspec.yaml');
        const pubspecContent = fs.readFileSync(pubspecPath, 'utf8');
        checkItem('pubspec.yaml válido', true);
        
        const requiredDeps = [
            'flutter:', 'http:', 'provider:', 'intl:', 'image_picker:', 'fl_chart:'
        ];
        
        for (const dep of requiredDeps) {
            const exists = pubspecContent.includes(dep);
            checkItem(`Dependencia Flutter: ${dep.replace(':', '')}`, exists);
            if (!exists) {
                issues.push(`Dependencia Flutter faltante: ${dep}`);
            }
        }
        
    } catch (error) {
        checkItem('pubspec.yaml válido', false, error.message);
        issues.push('Error en pubspec.yaml: ' + error.message);
    }
    
    // ===============================
    // 5. VERIFICAR ARCHIVOS DE ASSETS
    // ===============================
    checkSection('5. ARCHIVOS DE ASSETS');
    
    const assetDirs = [
        path.join(rootPath, 'assets/images'),
        path.join(rootPath, 'backend/uploads')
    ];
    
    for (const dir of assetDirs) {
        const exists = fs.existsSync(dir);
        const relativePath = path.relative(rootPath, dir);
        checkItem(`Directorio: ${relativePath}`, exists);
        if (!exists) {
            warnings.push(`Directorio faltante: ${relativePath}`);
        }
    }
    
    // ===============================
    // 6. VERIFICAR CONFIGURACIÓN DE RUTAS
    // ===============================
    checkSection('6. VERIFICACIÓN DE RUTAS');
    
    try {
        const authRoutesPath = path.join(rootPath, 'backend/routes/authRoutes.js');
        const authRoutesContent = fs.readFileSync(authRoutesPath, 'utf8');
        
        const requiredRoutes = [
            'router.post(\'/register\'',
            'router.post(\'/login\'',
            'router.post(\'/verify\'',
            'router.post(\'/upload\'',
            'router.get(\'/pets/for-matching',
            'router.post(\'/match-decision\''
        ];
        
        for (const route of requiredRoutes) {
            const exists = authRoutesContent.includes(route);
            checkItem(`Ruta: ${route}`, exists);
            if (!exists) {
                issues.push(`Ruta faltante: ${route}`);
            }
        }
        
    } catch (error) {
        checkItem('Verificación de rutas', false, error.message);
        issues.push('Error verificando rutas: ' + error.message);
    }
    
    // ===============================
    // 7. VERIFICAR PÁGINAS DE FLUTTER
    // ===============================
    checkSection('7. PÁGINAS DE FLUTTER');
    
    const flutterPages = [
        'lib/login_page.dart',
        'lib/register_page.dart',
        'lib/home_page.dart',
        'lib/profile_page.dart',
        'lib/pet_register.dart',
        'lib/my_pets_page.dart',
        'lib/PetMatchTab.dart',
        'lib/admin_panel.dart'
    ];
    
    for (const page of flutterPages) {
        const fullPath = path.join(rootPath, page);
        const exists = fs.existsSync(fullPath);
        checkItem(`Página: ${page}`, exists);
        if (!exists) {
            warnings.push(`Página faltante: ${page}`);
        }
    }
    
    // ===============================
    // RESUMEN FINAL
    // ===============================
    checkSection('RESUMEN DEL DIAGNÓSTICO');
    
    log(`\n📋 RESUMEN:`, 'magenta');
    log(`   Errores críticos: ${issues.length}`, issues.length > 0 ? 'red' : 'green');
    log(`   Advertencias: ${warnings.length}`, warnings.length > 0 ? 'yellow' : 'green');
    
    if (issues.length > 0) {
        log(`\n🚨 ERRORES CRÍTICOS QUE DEBEN SOLUCIONARSE:`, 'red');
        issues.forEach((issue, index) => {
            log(`   ${index + 1}. ${issue}`, 'red');
        });
    }
    
    if (warnings.length > 0) {
        log(`\n⚠️  ADVERTENCIAS (RECOMENDADO SOLUCIONAR):`, 'yellow');
        warnings.forEach((warning, index) => {
            log(`   ${index + 1}. ${warning}`, 'yellow');
        });
    }
    
    if (issues.length === 0 && warnings.length === 0) {
        log(`\n🎉 ¡PROYECTO EN PERFECTO ESTADO!`, 'green');
        log(`   Todos los componentes están configurados correctamente.`, 'green');
    } else if (issues.length === 0) {
        log(`\n✅ PROYECTO FUNCIONAL`, 'green');
        log(`   No hay errores críticos. Solo advertencias menores.`, 'green');
    } else {
        log(`\n❌ PROYECTO REQUIERE ATENCIÓN`, 'red');
        log(`   Hay errores críticos que deben solucionarse.`, 'red');
    }
    
    // ===============================
    // RECOMENDACIONES
    // ===============================
    log(`\n💡 RECOMENDACIONES:`, 'cyan');
    
    if (issues.length > 0) {
        log(`   1. Ejecutar: node fix_database_structure.js`, 'cyan');
        log(`   2. Verificar variables de entorno en .env`, 'cyan');
        log(`   3. Instalar dependencias faltantes: npm install`, 'cyan');
        log(`   4. Ejecutar: flutter pub get`, 'cyan');
    }
    
    if (!fs.existsSync(path.join(rootPath, 'backend/uploads'))) {
        log(`   5. Crear directorio uploads: mkdir backend/uploads`, 'cyan');
    }
    
    log(`\n📚 COMANDOS ÚTILES:`, 'blue');
    log(`   Backend: npm run dev`, 'blue');
    log(`   Frontend: flutter run -d chrome --web-renderer html`, 'blue');
    log(`   Base de datos: node fix_database_structure.js`, 'blue');
    log(`   Diagnóstico: node diagnostic_petmatch.js`, 'blue');
    
    return {
        issues: issues.length,
        warnings: warnings.length,
        success: issues.length === 0
    };
};

// Ejecutar diagnóstico
diagnosticoPetMatch()
    .then((result) => {
        log(`\n🏁 DIAGNÓSTICO COMPLETADO`, 'magenta');
        process.exit(result.success ? 0 : 1);
    })
    .catch((error) => {
        log(`\n💥 ERROR EN DIAGNÓSTICO: ${error.message}`, 'red');
        process.exit(1);
    });
