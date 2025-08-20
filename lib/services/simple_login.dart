import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../config/api_config.dart';

class SimpleLogin {
  // Login solo con backend - SIN GOOGLE
  static Future<Map<String, dynamic>?> loginWithEmail(String email, String password) async {
    try {
      print('🔐 Intentando login con: $email');
      print('🌐 URL: ${ApiConfig.baseUrl}/api/auth/login');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'PetMatch Mobile App',
        },
        body: jsonEncode({
          'username': email.trim(), // Cambiado de 'email' a 'username'
          'password': password,
        }),
      ).timeout(Duration(seconds: 15)); // Timeout más largo

      print('📡 Respuesta recibida: ${response.statusCode}');
      print('📄 Contenido: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Login exitoso',
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error de login',
        };
      }
    } on SocketException catch (e) {
      print('❌ Error de red: $e');
      return {
        'success': false,
        'message': 'Error de conexión de red. Verifica que estés en la misma WiFi que tu PC.',
      };
    } on HttpException catch (e) {
      print('❌ Error HTTP: $e');
      return {
        'success': false,
        'message': 'Error HTTP de conexión.',
      };
    } on FormatException catch (e) {
      print('❌ Error de formato: $e');
      return {
        'success': false,
        'message': 'Error al procesar respuesta del servidor.',
      };
    } catch (e) {
      print('❌ Error general: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Función para probar la conexión antes del login
  static Future<bool> testConnection() async {
    try {
      print('🧪 Probando conexión a: ${ApiConfig.baseUrl}/mobile-test');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/mobile-test'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 5));
      
      print('🧪 Test resultado: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Test de conexión falló: $e');
      return false;
    }
  }

  // Registro solo con backend - SIN GOOGLE
  static Future<Map<String, dynamic>?> registerWithEmail(
    String nombres,
    String apellidos,
    String correo,
    String contrasena,
    String genero,
    String ubicacion,
    String fechaNacimiento,
    {Map<String, dynamic>? coordenadas}
  ) async {
    try {
      final Map<String, dynamic> data = {
        'nombres': nombres,
        'apellidos': apellidos,
        'correo': correo,
        'contrasena': contrasena,
        'genero': genero,
        'ubicacion': ubicacion,
        'fecha_nacimiento': fechaNacimiento,
        if (coordenadas != null) 'coordenadas': coordenadas,
      };
      print('📤 JSON enviado al backend: ${jsonEncode(data)}');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Registro exitoso',
          'user': data['usuario'],
        };
      } else {
        return {
          'success': false,
          'message': 'Error en registro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
