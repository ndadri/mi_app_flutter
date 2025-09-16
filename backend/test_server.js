const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'application/json'});
  res.end(JSON.stringify({message: 'Servidor de prueba funcionando', timestamp: new Date().toISOString()}));
});

server.listen(3003, '0.0.0.0', () => {
  console.log('🚀 Servidor de prueba corriendo en puerto 3003');
  console.log('🌐 Prueba con: http://localhost:3003');
});
