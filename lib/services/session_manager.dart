import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SessionManager {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _lastActivityKey = 'last_activity';
  static const String _userIdKey = 'user_id';
  static const String _userIdGoogleKey = 'user_id_google';
  
  // Duración máxima de inactividad (24 horas)
  static const Duration _sessionTimeout = Duration(hours: 24);
  
  // Verificar si hay una sesión válida
  static Future<bool> hasValidSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Verificar si está marcado como logueado
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) return false;
      
      // Verificar si hay un user ID válido
      final hasUserId = prefs.containsKey(_userIdKey) || prefs.containsKey(_userIdGoogleKey);
      if (!hasUserId) return false;
      
      // Verificar timeout de sesión
      final lastActivityString = prefs.getString(_lastActivityKey);
      if (lastActivityString != null) {
        final lastActivity = DateTime.parse(lastActivityString);
        final now = DateTime.now();
        if (now.difference(lastActivity) > _sessionTimeout) {
          // Sesión expirada
          await clearSession();
          return false;
        }
      }
      
      // Actualizar última actividad
      await updateLastActivity();
      return true;
    } catch (e) {
      print('❌ Error verificando sesión: $e');
      return false;
    }
  }
  
  // Marcar como logueado
  static Future<void> markAsLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await updateLastActivity();
      print('✅ Sesión marcada como activa');
    } catch (e) {
      print('❌ Error marcando sesión: $e');
    }
  }
  
  // Actualizar última actividad
  static Future<void> updateLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('❌ Error actualizando actividad: $e');
    }
  }
  
  // Limpiar sesión
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_lastActivityKey);
      // No eliminar user_id automáticamente, solo marcar como no logueado
      print('✅ Sesión limpiada');
    } catch (e) {
      print('❌ Error limpiando sesión: $e');
    }
  }
  
  // Logout completo (elimina todo)
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_lastActivityKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userIdGoogleKey);
      print('✅ Logout completo realizado');
    } catch (e) {
      print('❌ Error en logout: $e');
    }
  }
  
  // Verificar si un error debe causar logout
  static bool shouldLogoutOnError(int? statusCode, String? errorMessage) {
    // Solo hacer logout en errores específicos de autenticación
    if (statusCode == 401) return true; // Unauthorized
    if (statusCode == 403) return true; // Forbidden
    
    // NO hacer logout en errores de servidor (500, 502, 503, etc.)
    if (statusCode != null && statusCode >= 500) return false;
    
    // Verificar mensajes específicos de autenticación
    if (errorMessage != null) {
      final lowerMessage = errorMessage.toLowerCase();
      if (lowerMessage.contains('token') && lowerMessage.contains('expired')) return true;
      if (lowerMessage.contains('unauthorized')) return true;
      if (lowerMessage.contains('forbidden')) return true;
    }
    
    return false; // Por defecto, no hacer logout
  }
  
  // Manejar error de manera inteligente
  static Future<bool> handleError(BuildContext? context, int? statusCode, String? errorMessage) async {
    final shouldLogout = shouldLogoutOnError(statusCode, errorMessage);
    
    if (shouldLogout) {
      await logout();
      if (context != null && context.mounted) {
        // Solo redirigir al login si realmente es un error de autenticación
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        
        // Mostrar mensaje específico
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Sesión expirada. Por favor, inicia sesión nuevamente.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return true; // Se hizo logout
    }
    
    return false; // No se hizo logout
  }
}
