// ================================================
// SCRIPT DE PRUEBAS DE SEGURIDAD - SISTEMA DE ROLES
// Pet Match Flutter App
// ================================================

const http = require('http');

// Datos de prueba
const testUser = {
    nombres: 'Carlos',
    apellidos: 'Rodriguez',
    correo: `carlos_security_${Date.now()}@example.com`,
    contraseña: 'test123456',
    genero: 'Masculino',
    ubicacion: 'Ciudad de México',
    edad: 25,
    fecha_nacimiento: '1999-01-01'
};

console.log('🔒 INICIANDO PRUEBAS DE SEGURIDAD DEL SISTEMA DE ROLES');
console.log('=' .repeat(60));

// Función para hacer POST requests
function makePostRequest(path, data) {
    return new Promise((resolve, reject) => {
        const postData = JSON.stringify(data);
        
        const options = {
            hostname: 'localhost',
            port: 3000,
            path: path,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            }
        };

        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => {
                body += chunk;
            });
            res.on('end', () => {
                try {
                    const response = JSON.parse(body);
                    resolve({ statusCode: res.statusCode, data: response });
                } catch (e) {
                    resolve({ statusCode: res.statusCode, data: { error: body } });
                }
            });
        });

        req.on('error', (e) => {
            reject(e);
        });

        req.write(postData);
        req.end();
    });
}

async function runSecurityTests() {
    console.log('\n1️⃣ PRUEBA: Registro normal (debería crear usuario con rol = 1)');
    console.log('-'.repeat(50));
    
    try {
        const response1 = await makePostRequest('/api/auth/register', testUser);
        console.log(`📊 Status: ${response1.statusCode}`);
        console.log(`📝 Response:`, response1.data);
        
        if (response1.data.success && response1.data.user) {
            const userId = response1.data.user.id;
            const userRole = response1.data.user.id_rol;
            console.log(`✅ Usuario creado con ID: ${userId}`);
            console.log(`🎯 Rol asignado: ${userRole} ${userRole === 1 ? '(✅ CORRECTO - Usuario normal)' : '(❌ ERROR - Rol incorrecto)'}`);
        } else {
            console.log('❌ Error en registro normal:', response1.data.message);
        }
    } catch (error) {
        console.log('❌ Error de conexión:', error.message);
    }

    console.log('\n2️⃣ PRUEBA: Intento de registro con rol administrador (debería fallar)');
    console.log('-'.repeat(50));
    
    const maliciousUser = {
        ...testUser,
        correo: `malicious_${Date.now()}@example.com`,
        rol: 'administrador', // Intento malicioso
        id_rol: 2 // Intento malicioso
    };

    try {
        const response2 = await makePostRequest('/api/auth/register', maliciousUser);
        console.log(`📊 Status: ${response2.statusCode}`);
        console.log(`📝 Response:`, response2.data);
        
        if (response2.statusCode === 400 && response2.data.message === 'Parámetros no válidos en el registro') {
            console.log('✅ SEGURIDAD CORRECTA: Intento de escalación de privilegios bloqueado');
        } else if (response2.data.success && response2.data.user) {
            const userRole = response2.data.user.id_rol;
            if (userRole === 1) {
                console.log('⚠️ PARCIALMENTE SEGURO: Usuario creado pero con rol correcto (1)');
            } else {
                console.log('🚨 FALLO DE SEGURIDAD CRÍTICO: Usuario creado con rol elevado!');
            }
        } else {
            console.log('❓ Respuesta inesperada');
        }
    } catch (error) {
        console.log('❌ Error de conexión:', error.message);
    }

    console.log('\n3️⃣ PRUEBA: Intento con campo "role" (debería fallar)');
    console.log('-'.repeat(50));
    
    const maliciousUser2 = {
        ...testUser,
        correo: `malicious2_${Date.now()}@example.com`,
        role: 'admin' // Otro intento malicioso
    };

    try {
        const response3 = await makePostRequest('/api/auth/register', maliciousUser2);
        console.log(`📊 Status: ${response3.statusCode}`);
        console.log(`📝 Response:`, response3.data);
        
        if (response3.statusCode === 400 && response3.data.message === 'Parámetros no válidos en el registro') {
            console.log('✅ SEGURIDAD CORRECTA: Segundo intento de escalación bloqueado');
        } else {
            console.log('⚠️ Revisar seguridad');
        }
    } catch (error) {
        console.log('❌ Error de conexión:', error.message);
    }

    console.log('\n' + '='.repeat(60));
    console.log('🏁 PRUEBAS DE SEGURIDAD COMPLETADAS');
    console.log('='.repeat(60));
}

// Ejecutar las pruebas
runSecurityTests().catch(console.error);
