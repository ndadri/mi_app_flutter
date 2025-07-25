const express = require('express');
const app = express();
const port = 3002;

app.use(express.json());

// Ruta de prueba para mascotas
app.post('/test-mascotas', (req, res) => {
    console.log('📦 Datos recibidos:', req.body);
    console.log('📋 Headers:', req.headers);
    
    res.json({
        success: true,
        message: 'Datos recibidos correctamente',
        data: req.body
    });
});

app.listen(port, () => {
    console.log(`🧪 Servidor de prueba corriendo en http://localhost:${port}`);
    console.log('📡 Prueba con: curl -X POST http://localhost:3002/test-mascotas -H "Content-Type: application/json" -d "{\\"test\\":\\"data\\"}"');
});
