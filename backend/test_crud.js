const http = require('http');

// Configuración de la petición
const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/admin/users',
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
    'X-User-ID': '2'
  }
};

// Hacer la petición
const req = http.request(options, (res) => {
  console.log(`Status: ${res.statusCode}`);
  console.log(`Headers: ${JSON.stringify(res.headers)}`);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    try {
      const result = JSON.parse(data);
      console.log('Respuesta exitosa:');
      console.log('Success:', result.success);
      console.log('Total usuarios:', result.total);
      console.log('Usuarios encontrados:', result.users.length);
      
      if (result.users && result.users.length > 0) {
        console.log('\nPrimeros usuarios:');
        result.users.slice(0, 2).forEach((user, index) => {
          console.log(`${index + 1}. ${user.nombres} ${user.apellidos} (${user.correo})`);
          console.log(`   Verificado: ${user.verificado}`);
          console.log(`   Mascotas: ${user.mascotas}, Matches: ${user.match}`);
        });
      }
    } catch (error) {
      console.error('Error parseando JSON:', error.message);
      console.log('Raw data:', data);
    }
  });
});

req.on('error', (error) => {
  console.error('Error en la petición:', error.message);
});

req.end();
