import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class SimpleLogin {
  // Login solo con backend - SIN GOOGLE
  static Future<Map<String, dynamic>?> loginWithEmail(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Login exitoso',
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': 'Email o contraseña incorrectos',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Registro solo con backend - SIN GOOGLE
  static Future<Map<String, dynamic>?> registerWithEmail(
    String email, 
    String password, 
    String name
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Registro exitoso',
          'user': data['user'],
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
