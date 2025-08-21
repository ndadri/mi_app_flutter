import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'session_manager.dart';

class EventoService {
  static const String baseUrl = 'http://192.168.1.24:3004';
  
  // Cache de eventos para mejorar rendimiento
  static List<Map<String, dynamic>>? _eventosCache;
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 2);

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
  
  // Verificar si el cache es válido
  static bool _isCacheValid() {
    if (_eventosCache == null || _lastCacheUpdate == null) {
      return false;
    }
    
    final now = DateTime.now();
    final timeDifference = now.difference(_lastCacheUpdate!);
    return timeDifference < _cacheValidDuration;
  }
  
  // Limpiar cache
  static void clearCache() {
    _eventosCache = null;
    _lastCacheUpdate = null;
  }
  
  // Obtener todos los eventos con asistencia del usuario (OPTIMIZADO CON CACHE)
  static Future<Map<String, dynamic>> obtenerEventos({bool forceRefresh = false}) async {
    try {
      // Usar cache si es válido y no se fuerza refresh
      if (!forceRefresh && _isCacheValid()) {
        return {
          'success': true,
          'eventos': _eventosCache,
          'fromCache': true
        };
      }
      
      final userId = await _getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Usuario no autenticado'
        };
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/eventos/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5)); // Timeout reducido para carga más rápida
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Actualizar cache
        if (data['success'] && data['eventos'] != null) {
          _eventosCache = List<Map<String, dynamic>>.from(data['eventos']);
          _lastCacheUpdate = DateTime.now();
        }
        
        return data;
      } else {
        // Manejo específico de códigos de error HTTP
        String errorMessage;
        switch (response.statusCode) {
          case 401:
            errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
            break;
          case 403:
            errorMessage = 'No tienes permisos para acceder a este recurso.';
            break;
          case 404:
            errorMessage = 'Servicio no encontrado. Verifica tu conexión.';
            break;
          case 500:
            errorMessage = 'Error temporal del servidor. Reintentando...';
            break;
          default:
            errorMessage = 'Error del servidor: ${response.statusCode}';
        }
        
        // Para errores 500 (servidor), devolver cache si está disponible
        if (response.statusCode == 500 && _eventosCache != null) {
          return {
            'success': true,
            'eventos': _eventosCache,
            'fromCache': true,
            'warning': 'Error del servidor. Mostrando datos guardados.'
          };
        }
        
        // NO hacer logout automático en errores de servidor
        final shouldLogout = SessionManager.shouldLogoutOnError(response.statusCode, errorMessage);
        
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
          'shouldLogout': shouldLogout
        };
      }
    } catch (e) {
      // Mensaje de error más específico según el tipo de excepción
      String errorMessage;
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Conexión lenta. Verifica tu internet.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Sin conexión a internet. Verifica tu WiFi.';
      } else if (e.toString().contains('HttpException')) {
        errorMessage = 'Error de conexión con el servidor.';
      } else {
        errorMessage = 'Error de conexión: ${e.toString()}';
      }
      
      // Si hay error y tenemos cache, devolver cache con advertencia
      if (_eventosCache != null) {
        return {
          'success': true,
          'eventos': _eventosCache,
          'fromCache': true,
          'warning': 'Sin conexión. Mostrando datos guardados.',
          'canRetry': true
        };
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'canRetry': true,
        'shouldLogout': false // Los errores de conexión NO deben causar logout
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
        Uri.parse('$baseUrl/api/eventos'),
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
        Uri.parse('$baseUrl/api/eventos/$eventoId/asistencia'),
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
        Uri.parse('$baseUrl/api/eventos/$eventoId/asistentes'),
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
        Uri.parse('$baseUrl/api/eventos/$eventoId'),
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
