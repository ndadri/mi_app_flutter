// CONFIGURACIÓN CORREGIDA PARA FLUTTER - SOLUCIÓN AL TIMEOUT
// Copia este código en tu servicio de autenticación en Flutter

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiConfig {
  // IPs para probar en orden de prioridad
  static const List<String> possibleIPs = [
    '192.168.1.24:3002',
    '192.168.56.1:3002', 
    '192.168.11.1:3002',
    '192.168.52.1:3002',
  ];
  
  static String? _workingIP;
  
  // Función para encontrar la IP que funciona
  static Future<String?> findWorkingIP() async {
    if (_workingIP != null) return _workingIP;
    
    for (String ip in possibleIPs) {
      try {
        print('🔍 Probando IP: $ip');
        final response = await http.get(
          Uri.parse('http://$ip/mobile-test'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(Duration(seconds: 3));
        
        if (response.statusCode == 200) {
          _workingIP = ip;
          print('✅ IP funcionando encontrada: $ip');
          return ip;
        }
      } catch (e) {
        print('❌ IP $ip no funciona: $e');
        continue;
      }
    }
    print('💥 NINGUNA IP FUNCIONA');
    return null;
  }

  // Ejemplo de login usando la IP encontrada
  static Future<bool> login(String email, String password) async {
    final ip = await findWorkingIP();
    if (ip == null) return false;
    final url = 'http://$ip/api/auth/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'correo': email,
          'contraseña': password,
        }),
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error en login: $e');
      return false;
    }
  }
}
