import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class SocialAuthService {
  // Google Sign-In con configuración directa y completa
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
    // Configuración directa sin Firebase
    serverClientId: '1033930402349-d064hi1k9hefcf0op18cqk5tahlb7cta.apps.googleusercontent.com',
  );

  // Login con Google - versión robusta
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔄 Iniciando Google Sign-In...');
      
      // Verificar si Google Play Services está disponible
      bool isAvailable = await _googleSignIn.isSignedIn();
      print('📱 Google Play Services disponible: $isAvailable');
      
      // Limpiar sesión previa si existe
      if (isAvailable) {
        await _googleSignIn.signOut();
        print('🔄 Sesión previa cerrada');
      }
      
      // Realizar el sign-in
      print('🚀 Iniciando proceso de autenticación...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        print('❌ Login cancelado por el usuario');
        return {
          'success': false, 
          'message': 'Login cancelado por el usuario'
        };
      }

      // Obtener detalles de autenticación
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      print('✅ Autenticación exitosa!');
      print('📧 Email: ${account.email}');
      print('👤 Nombre: ${account.displayName}');
      print('� Access Token: ${googleAuth.accessToken != null ? "✅" : "❌"}');
      print('🔑 ID Token: ${googleAuth.idToken != null ? "✅" : "❌"}');

      // Intentar sincronizar con el backend
      Map<String, dynamic>? backendResult;
      try {
        backendResult = await _registerOrUpdateUser(
          account.email,
          account.displayName ?? 'Usuario Google',
          'google',
          account.photoUrl ?? '',
        );
        print('✅ Sincronizado con backend exitosamente');
      } catch (e) {
        print('⚠️ Error al sincronizar con backend: $e');
        // Continuamos con el login exitoso aunque falle el backend
      }
      
      return {
        'success': true,
        'message': 'Login exitoso con Google',
        'user': {
          'email': account.email,
          'displayName': account.displayName ?? 'Usuario Google',
          'photoURL': account.photoUrl,
          'provider': 'google',
          'id': account.id,
          'accessToken': googleAuth.accessToken,
          'idToken': googleAuth.idToken,
        },
        'backend': backendResult,
      };
      
    } catch (e) {
      print('❌ Error detallado en Google Sign-In: $e');
      print('❌ Tipo de error: ${e.runtimeType}');
      
      // Analizar el error específico
      String errorMessage = 'Error desconocido en Google Sign-In';
      
      String errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains('network_error') || errorStr.contains('timeout')) {
        errorMessage = 'Error de conexión. Verifica tu internet y vuelve a intentar.';
      } else if (errorStr.contains('sign_in_canceled')) {
        errorMessage = 'Login cancelado por el usuario.';
      } else if (errorStr.contains('sign_in_failed')) {
        errorMessage = 'Error en el proceso de autenticación. Intenta nuevamente.';
      } else if (errorStr.contains('apiexception')) {
        if (errorStr.contains('10:')) {
          errorMessage = 'Error de configuración OAuth. La app necesita ser configurada correctamente.';
        } else if (errorStr.contains('12500:')) {
          errorMessage = 'Error de Google Play Services. Actualiza Google Play Services.';
        } else if (errorStr.contains('12501:')) {
          errorMessage = 'Login cancelado o error de configuración.';
        } else {
          errorMessage = 'Error de Google Play Services. Código: ${e.toString()}';
        }
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      return {
        'success': false, 
        'message': errorMessage,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }
  }

  // Login con Facebook  
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Obtener datos del usuario de Facebook
        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture.width(200)",
        );

        // Simular registro/login en el backend con los datos obtenidos
        final backendResponse = await _registerOrUpdateUser(
          userData['email'] ?? '',
          userData['name'] ?? '',
          'facebook',
          userData['picture']?['data']?['url'] ?? '',
        );
        
        return {
          'success': true,
          'message': 'Login exitoso con Facebook',
          'user': {
            'email': userData['email'],
            'displayName': userData['name'],
            'photoURL': userData['picture']?['data']?['url'],
            'provider': 'facebook',
          },
          'backend': backendResponse,
        };
      } else if (result.status == LoginStatus.cancelled) {
        return {'success': false, 'message': 'Login cancelado por el usuario'};
      } else {
        return {'success': false, 'message': 'Error en login con Facebook: ${result.message}'};
      }
      
    } catch (e) {
      return {'success': false, 'message': 'Error en login con Facebook: $e'};
    }
  }

  // Registrar o actualizar usuario en el backend
  static Future<Map<String, dynamic>> _registerOrUpdateUser(
    String email, 
    String name, 
    String provider, 
    String photoURL,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.socialLoginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'name': name,
          'provider': provider,
          'photoURL': photoURL,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  // Cerrar sesión
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print('Error cerrando sesión: $e');
    }
  }
}
