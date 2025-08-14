const http = require('http');

// Datos de prueba
const testData = {
    correo: 'andersonsoto102@gmail.com'
};

const postData = JSON.stringify(testData);

const options = {
    hostname: 'localhost',
    port: 3002,
    path: '/api/forgot-password',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
    }
};

console.log('🧪 Probando endpoint de recuperación de contraseña...');
console.log('📍 URL:', `http://${options.hostname}:${options.port}${options.path}`);
console.log('📦 Datos:', testData);

const req = http.request(options, (res) => {
    console.log(`📊 Status Code: ${res.statusCode}`);
    console.log(`📝 Headers:`, res.headers);

    let responseBody = '';
    res.on('data', (chunk) => {
        responseBody += chunk;
    });

    res.on('end', () => {
        console.log('📄 Respuesta del servidor:');
        try {
            const parsedResponse = JSON.parse(responseBody);
            console.log(JSON.stringify(parsedResponse, null, 2));
        } catch (error) {
            console.log('Respuesta (texto):', responseBody);
        }
    });
});

req.on('error', (error) => {
    console.error('❌ Error en la petición:', error);
});

// Enviar datos
req.write(postData);
req.end();
