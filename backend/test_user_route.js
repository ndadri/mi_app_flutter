const http = require('http');

async function testUserRoute(userId) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 3001,
            path: `/api/auth/user/${userId}`,
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        };

        const req = http.request(options, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                try {
                    const response = JSON.parse(data);
                    resolve({ status: res.statusCode, data: response });
                } catch (e) {
                    resolve({ status: res.statusCode, data: data });
                }
            });
        });

        req.on('error', (err) => {
            reject(err);
        });

        req.end();
    });
}

async function testAllUsers() {
    console.log('🧪 Probando la nueva ruta /api/auth/user/:id');
    
    const userIds = [2, 3, 4, 99]; // Incluimos 99 para probar un ID que no existe
    
    for (const userId of userIds) {
        try {
            console.log(`\n📡 Probando ID: ${userId}`);
            const result = await testUserRoute(userId);
            
            if (result.status === 200) {
                console.log(`✅ Usuario encontrado:`);
                console.log(`   - ID: ${result.data.user.id}`);
                console.log(`   - Nombre: ${result.data.user.nombres} ${result.data.user.apellidos}`);
                console.log(`   - Email: ${result.data.user.correo}`);
                console.log(`   - Ubicación: ${result.data.user.ubicacion}`);
            } else {
                console.log(`❌ Error ${result.status}: ${result.data.message || result.data}`);
            }
        } catch (err) {
            console.log(`❌ Error de conexión: ${err.message}`);
        }
    }
}

testAllUsers();
