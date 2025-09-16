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
        ).timeout(const Duration(seconds: 3));
        
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
    
    print('❌ No se encontró ninguna IP funcionando');
    return null;
  }
  
  // Obtener la URL base
  static Future<String?> getBaseUrl() async {
    final ip = await findWorkingIP();
    return ip != null ? 'http://$ip' : null;
  }
}

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // 1. Encontrar IP que funciona
      final baseUrl = await ApiConfig.getBaseUrl();
      if (baseUrl == null) {
        return {
          'success': false,
          'message': 'No se pudo conectar al servidor. Verifica que estés en la misma red WiFi.'
        };
      }
      
      print('📡 Conectando a: $baseUrl');
      
      // 2. Hacer petición de login
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'PetMatch Mobile App',
        },
        body: jsonEncode({
          'username': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15)); // Timeout más largo
      
      print('📡 Respuesta recibida: ${response.statusCode}');
      print('📡 Contenido: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Login exitoso'
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error de login'
        };
      }
      
    } on SocketException catch (e) {
      print('❌ Error de conexión: $e');
      return {
        'success': false,
        'message': 'Error de red. Verifica tu conexión WiFi y que el servidor esté funcionando.'
      };
    } on HttpException catch (e) {
      print('❌ Error HTTP: $e');
      return {
        'success': false,
        'message': 'Error de conexión HTTP.'
      };
    } on FormatException catch (e) {
      print('❌ Error de formato: $e');
      return {
        'success': false,
        'message': 'Error al procesar respuesta del servidor.'
      };
    } catch (e) {
      print('❌ Error general: $e');
      return {
        'success': false,
        'message': 'Error inesperado: ${e.toString()}'
      };
    }
  }
  
  // Función para probar la conexión
  static Future<bool> testConnection() async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      if (baseUrl == null) return false;
      
      final response = await http.get(
        Uri.parse('$baseUrl/mobile-test'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Test de conexión falló: $e');
      return false;
    }
  }
}

// INSTRUCCIONES DE USO:
// 1. Reemplaza tu servicio de autenticación actual con este código
// 2. Antes de hacer login, llama a AuthService.testConnection() para verificar
// 3. Usa AuthService.login(email, password) para el login
// 4. El código automáticamente encontrará la IP correcta

// EJEMPLO DE USO EN TU PANTALLA DE LOGIN:
/*
void _handleLogin() async {
  setState(() {
    _isLoading = true;
  });
  
  // Probar conexión primero
  final canConnect = await AuthService.testConnection();
  if (!canConnect) {
    setState(() {
      _isLoading = false;
    });
    _showError('No se pudo conectar al servidor. Verifica tu conexión WiFi.');
    return;
  }
  
  // Intentar login
  final result = await AuthService.login(
    _emailController.text,
    _passwordController.text,
  );
  
  setState(() {
    _isLoading = false;
  });
  
  if (result['success']) {
    // Login exitoso
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    // Mostrar error
    _showError(result['message']);
  }
}
*/
