const http = require('http');
const FormData = require('form-data');

// Datos de prueba para crear un evento
const testData = {
  nombre: 'Evento de Prueba',
  fecha: '2025-08-15',
  hora: '10:00',
  lugar: 'Parque Central',
  creado_por: '2'  // Usando el ID del admin
};

console.log('🧪 Probando endpoint crear evento...');
console.log('Datos a enviar:', testData);

const form = new FormData();
Object.keys(testData).forEach(key => {
  form.append(key, testData[key]);
});

const options = {
  hostname: '192.168.1.24',
  port: 3002,
  path: '/api/eventos',
  method: 'POST',
  headers: form.getHeaders()
};

const req = http.request(options, (res) => {
  console.log('📊 Status Code:', res.statusCode);
  console.log('📋 Headers:', res.headers);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('📄 Response:', data);
    try {
      const parsed = JSON.parse(data);
      console.log('✅ Parsed Response:', JSON.stringify(parsed, null, 2));
    } catch (e) {
      console.log('❌ No se pudo parsear respuesta como JSON');
    }
  });
});

req.on('error', (e) => {
  console.error('❌ Error en request:', e.message);
});

form.pipe(req);
