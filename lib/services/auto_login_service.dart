import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AutoLoginService {
  // Lista de IPs para probar automáticamente
  static const List<String> ipsToTry = [
    'http://192.168.1.24:3002',
    'http://192.168.56.1:3002',
    'http://192.168.11.1:3002',
    'http://192.168.52.1:3002',
  ];
  
  static String? _workingIP;
  
  // Función para encontrar automáticamente la IP que funciona
  static Future<String?> findWorkingIP() async {
    if (_workingIP != null) {
      print('✅ Usando IP ya encontrada: $_workingIP');
      return _workingIP;
    }
    
    print('🔍 Buscando IP que funcione...');
    
    for (String ip in ipsToTry) {
      try {
        print('🧪 Probando: $ip');
        
        final response = await http.get(
          Uri.parse('$ip/mobile-test'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'PetMatch Mobile App',
          },
        ).timeout(Duration(seconds: 3));
        
        if (response.statusCode == 200) {
          _workingIP = ip;
          print('🎯 ¡IP FUNCIONANDO ENCONTRADA: $ip!');
          return ip;
        } else {
          print('❌ $ip respondió pero con error: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ $ip no funciona: $e');
        continue;
      }
    }
    
    print('💥 NINGUNA IP FUNCIONA - Verifica:');
    print('   • Mismo WiFi en teléfono y PC');
    print('   • Servidor corriendo con: node src/index.js');
    print('   • Firewall no está bloqueando');
    return null;
  }
  
  // Login automático que encuentra la IP correcta
  static Future<Map<String, dynamic>> autoLogin(String email, String password) async {
    try {
      print('🚀 INICIANDO LOGIN AUTOMÁTICO');
      print('📧 Email: $email');
      
      // Paso 1: Encontrar IP que funcione
      final workingIP = await findWorkingIP();
      
      if (workingIP == null) {
        return {
          'success': false,
          'message': 'No se pudo conectar al servidor.\n\n'
                    'Verifica que:\n'
                    '• Tu teléfono y PC estén en la misma WiFi\n'
                    '• El servidor esté funcionando\n'
                    '• El firewall no esté bloqueando'
        };
      }
      
      // Paso 2: Hacer login con la IP que funciona
      print('🔐 Haciendo login con IP: $workingIP');
      
      final response = await http.post(
        Uri.parse('$workingIP/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'PetMatch Mobile App',
        },
        body: jsonEncode({
          'username': email.trim(),
          'password': password,
        }),
      ).timeout(Duration(seconds: 15));
      
      print('📡 Respuesta del servidor: ${response.statusCode}');
      print('📄 Contenido: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          print('🎉 ¡LOGIN EXITOSO!');
          return {
            'success': true,
            'message': 'Login exitoso',
            'user': data['user'],
            'token': data['token'],
            'workingIP': workingIP, // Guardamos la IP que funcionó
          };
        } else {
          print('❌ Login falló: ${data['message']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Error de autenticación',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        print('❌ Error del servidor: ${errorData['message']}');
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error del servidor',
        };
      }
      
    } on SocketException catch (e) {
      print('💥 Error de red: $e');
      return {
        'success': false,
        'message': 'Error de conexión de red.\n\n'
                  'Verifica tu conexión WiFi y que estés en la misma red que tu PC.'
      };
    } on HttpException catch (e) {
      print('💥 Error HTTP: $e');
      return {
        'success': false,
        'message': 'Error de protocolo HTTP.'
      };
    } catch (e) {
      print('💥 Error inesperado: $e');
      return {
        'success': false,
        'message': 'Error inesperado: ${e.toString()}'
      };
    }
  }
  
  // Función para probar conexión rápida
  static Future<bool> quickConnectionTest() async {
    print('⚡ Prueba rápida de conexión...');
    final ip = await findWorkingIP();
    return ip != null;
  }
}
