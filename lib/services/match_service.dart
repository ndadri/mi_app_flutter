import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MatchService {
  static const String baseUrl = 'http://192.168.1.24:3004';

  // Obtener ID de usuario
  static Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    
    final regularUserId = prefs.getInt('user_id');
    if (regularUserId != null) {
      return regularUserId.toString();
    }
    
    final googleUserId = prefs.getString('user_id_google');
    if (googleUserId != null) {
      return googleUserId;
    }
    
    return null;
  }

  // Dar like o dislike a una mascota
  static Future<Map<String, dynamic>> darLike({
    required int mascotaId,
    required bool isLike,
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
        Uri.parse('$baseUrl/api/matches/like'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'usuario_id': int.parse(userId),
          'mascota_id': mascotaId,
          'is_like': isLike,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  // Obtener matches del usuario
  static Future<Map<String, dynamic>> obtenerMatches() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado'
        };
      }

      print('🔍 Buscando matches para usuario: $userId');
      print('🌐 URL: $baseUrl/api/matches/matches/$userId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/matches/matches/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      print('📡 Respuesta matches: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        // Si no encuentra la ruta, devolver lista vacía en lugar de error
        return {
          'success': true,
          'matches': [],
          'message': 'No hay matches disponibles aún'
        };
      } else if (response.statusCode == 500) {
        // Para error 500, devolver matches vacíos en lugar de fallar
        return {
          'success': true,
          'matches': [],
          'warning': 'Servicio de matches temporalmente no disponible'
        };
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      print('❌ Error obteniendo matches: $e');
      
      // En caso de error de conexión, devolver matches vacíos
      return {
        'success': true,
        'matches': [],
        'warning': 'Sin conexión. Verifica tu internet.',
        'canRetry': true
      };
    }
  }

  // Obtener notificaciones del usuario
  static Future<Map<String, dynamic>> obtenerNotificaciones() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado'
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/matches/notificaciones/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  // Marcar notificación como leída
  static Future<Map<String, dynamic>> marcarNotificacionLeida(int notificacionId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/matches/notificaciones/$notificacionId/leer'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}'
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
