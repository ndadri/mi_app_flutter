// Configuración del backend para la app Flutter
// Copia esta configuración en tu app de Flutter

class BackendConfig {
  // IPs disponibles para conectar desde dispositivos móviles
  static const List<String> availableIPs = [
    '192.168.56.1:3002',  // VirtualBox Network
    '192.168.11.1:3002',  // Red adicional 1
    '192.168.52.1:3002',  // Red adicional 2
    '192.168.1.24:3002',  // Red principal WiFi
  ];
  
  // IP principal recomendada (tu red WiFi)
  static const String primaryIP = '192.168.1.24:3002';
  
  // URLs base para usar en tu app
  static const String baseUrl = 'http://192.168.1.24:3002';
  static const String apiUrl = 'http://192.168.1.24:3002/api';
  
  // Endpoints principales
  static const String authEndpoint = '/api/auth';
  static const String eventosEndpoint = '/api/eventos';
  
  // URLs completas
  static const String loginUrl = '$apiUrl/auth/login';
  static const String registerUrl = '$apiUrl/auth/registrar';
  static const String socialLoginUrl = '$apiUrl/auth/social-login';
}

// INSTRUCCIONES DE USO:
// 1. En tu app Flutter, usa BackendConfig.baseUrl como URL base
// 2. Si no funciona con la IP principal, prueba las otras IPs disponibles
// 3. Asegúrate de que tu teléfono esté en la misma red WiFi que tu computadora

// EJEMPLO DE USO EN FLUTTER:
/*
import 'package:http/http.dart' as http;

// Para login:
final response = await http.post(
  Uri.parse(BackendConfig.loginUrl),
  ...
);
*/
