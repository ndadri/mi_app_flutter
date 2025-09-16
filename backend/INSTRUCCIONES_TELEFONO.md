# 📱 INSTRUCCIONES PARA USAR EL BACKEND DESDE TU TELÉFONO

## 🚀 Tu backend ya está funcionando y listo para usar desde cualquier dispositivo!

### 📊 Estado del Servidor:
- ✅ Servidor funcionando en puerto 3002
- ✅ Base de datos conectada
- ✅ CORS configurado para permitir cualquier dispositivo
- ✅ Firewall configurado
- ✅ Escuchando en todas las interfaces de red (0.0.0.0)

### 🌐 IPs Disponibles para Conectar:
```
📱 IP Principal (WiFi): http://192.168.1.24:3002
📱 Red VirtualBox: http://192.168.56.1:3002
📱 Red Adicional 1: http://192.168.11.1:3002
📱 Red Adicional 2: http://192.168.52.1:3002
```

### 🔧 Comandos para Controlar el Backend:

#### Iniciar el servidor:
```bash
cd C:\Users\ander\Documents\GitHub\mi_app_flutter\backend
node src/index.js
```

#### O usar el script automático:
```bash
start_server.bat
```

### 📱 Configuración en tu App Flutter:

1. **Asegúrate de que tu teléfono esté en la misma red WiFi que tu computadora**

2. **En tu app Flutter, usa esta URL base:**
   ```dart
   const String baseUrl = 'http://192.168.1.24:3002';
   ```

3. **Endpoints principales:**
   ```
   POST /api/auth/registrar    - Registro de usuarios
   POST /api/auth/login        - Iniciar sesión
   POST /api/auth/social-login - Login con Google/Facebook
   GET  /api/auth/usuarios/:id - Obtener info de usuario
   POST /api/eventos/*         - Gestión de eventos
   ```

### 🧪 Pruebas de Conectividad:

#### Desde tu navegador (en cualquier dispositivo):
```
http://192.168.1.24:3002/         - Estado del servidor
http://192.168.1.24:3002/health   - Diagnóstico completo
http://192.168.1.24:3002/test     - Prueba simple
```

#### Desde tu app móvil (ejemplo de login):
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> testLogin() async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.24:3002/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': 'test@ejemplo.com',
        'password': 'password123'
      }),
    );
    
    if (response.statusCode == 200) {
      print('✅ Conectado al backend exitosamente!');
      print('Respuesta: ${response.body}');
    } else {
      print('❌ Error: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error de conexión: $e');
  }
}
```

### 🔧 Solución de Problemas:

#### Si no puedes conectar desde el teléfono:

1. **Verifica la red WiFi:**
   - Tu computadora y teléfono DEBEN estar en la misma red WiFi
   - Desactiva datos móviles en el teléfono

2. **Prueba diferentes IPs:**
   - Si `192.168.1.24` no funciona, prueba las otras IPs listadas arriba

3. **Verifica el firewall:**
   - El puerto 3002 debería estar permitido (ya lo configuramos)

4. **Reinicia el servidor si es necesario:**
   ```bash
   Ctrl+C (para detener)
   node src/index.js (para reiniciar)
   ```

### 📋 Logs del Servidor:
El servidor mostrará logs detallados de todas las peticiones:
```
📝 2025-08-19T... - POST /api/auth/login
🎯 PETICIÓN DETECTADA desde [IP del dispositivo]
```

### ✅ Todo Listo!
Tu backend está configurado para funcionar desde cualquier dispositivo en tu red. ¡Solo asegúrate de que estén en la misma WiFi y usa la IP correcta en tu app Flutter!
