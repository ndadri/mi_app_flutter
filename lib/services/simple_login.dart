import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class SimpleLogin {
  // Login solo con backend - SIN GOOGLE
  static Future<Map<String, dynamic>?> loginWithEmail(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
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
      print('📤 JSON enviado al backend: ' + jsonEncode(data));
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
