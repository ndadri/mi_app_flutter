import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventoService {
  static const String baseUrl = 'http://192.168.1.24:3002/api';
  
  // Obtener ID de usuario
  static Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Verificar si hay un user_id normal (login regular)
    final regularUserId = prefs.getInt('user_id');
    if (regularUserId != null) {
      return regularUserId.toString();
    }
    
    // Verificar si hay un user_id de Google
    final googleUserId = prefs.getString('user_id_google');
    if (googleUserId != null) {
      return googleUserId;
    }
    
    return null;
  }
  
  // Obtener todos los eventos con asistencia del usuario
  static Future<Map<String, dynamic>> obtenerEventos() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado'
        };
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/eventos/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error al obtener eventos: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }
  
  // Crear nuevo evento (VERSIÓN MEJORADA)
  static Future<Map<String, dynamic>> crearEvento({
    required String nombre,
    required String fecha,
    required String hora,
    required String lugar,
    File? imagen,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado'
        };
      }
      
      // Validar que todos los campos estén completos
      if (nombre.trim().isEmpty || fecha.trim().isEmpty || 
          hora.trim().isEmpty || lugar.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Todos los campos son requeridos'
        };
      }
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/eventos'),
      );
      
      // Agregar campos de texto con validación
      request.fields['nombre'] = nombre.trim();
      request.fields['fecha'] = fecha.trim();
      request.fields['hora'] = hora.trim();
      request.fields['lugar'] = lugar.trim();
      request.fields['creado_por'] = userId;
      
      print('📤 Enviando datos: ${request.fields}');
      
      // Agregar imagen si existe
      if (imagen != null && imagen.existsSync()) {
        var imageFile = await http.MultipartFile.fromPath(
          'imagen',
          imagen.path,
        );
        request.files.add(imageFile);
        print('📷 Imagen agregada: ${imagen.path}');
      }
      
      // Agregar headers
      request.headers['Content-Type'] = 'multipart/form-data';
      
      print('🚀 Enviando petición a: ${request.url}');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      print('📥 Respuesta del servidor: $responseBody');
      print('📊 Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
          'details': responseBody
        };
      }
    } catch (e) {
      print('❌ Error en crearEvento: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }
  
  // Marcar asistencia a evento
  static Future<Map<String, dynamic>> marcarAsistencia({
    required int eventoId,
    required bool asistira,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado'
        };
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/eventos/$eventoId/asistencia'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'usuario_id': userId,
          'asistira': asistira,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error al marcar asistencia: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }
  
  // Obtener asistentes de un evento
  static Future<Map<String, dynamic>> obtenerAsistentes(int eventoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/eventos/$eventoId/asistentes'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error al obtener asistentes: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }
  
  // Eliminar evento (solo el creador)
  static Future<Map<String, dynamic>> eliminarEvento(int eventoId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado'
        };
      }
      
      final response = await http.delete(
        Uri.parse('$baseUrl/eventos/$eventoId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'usuario_id': userId,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error al eliminar evento: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }
}
