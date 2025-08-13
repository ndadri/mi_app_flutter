import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnhancedGoogleAuth {
  // Configuración robusta para resolver ApiException: 10
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    // Usando Web Client ID del nuevo proyecto Firebase petmach-2596f
    serverClientId: '1033930402349-d064hi1k9hefcf0op18cqk5tahlb7cta.apps.googleusercontent.com',
    hostedDomain: null,
    forceCodeForRefreshToken: true,
  );
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔧 === ENHANCED GOOGLE SIGN-IN ===');
      
      // 1. Verificar estado y limpiar si es necesario
      bool isSignedIn = await _googleSignIn.isSignedIn();
      print('📋 Estado inicial - Google: $isSignedIn, Firebase: ${_auth.currentUser != null}');
      
      if (isSignedIn || _auth.currentUser != null) {
        print('🧹 Limpiando sesiones anteriores...');
        await _googleSignIn.signOut();
        await _auth.signOut();
        print('✅ Sesiones limpiadas');
      }
      
      // 2. Verificar configuración de Google Sign-In
      print('🔍 Verificando configuración...');
      
      // 3. Intentar login con Google
      print('🚀 Iniciando Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Login cancelado por el usuario');
        return {
          'success': false, 
          'message': 'Login cancelado por el usuario',
          'error_type': 'user_cancelled'
        };
      }

      print('✅ Google login exitoso');
      print('📧 Email: ${googleUser.email}');
      print('👤 Nombre: ${googleUser.displayName}');
      
      // 4. Obtener tokens de Google
      print('🔑 Obteniendo tokens de autenticación...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ Error: Tokens de Google son null');
        print('🔍 Access Token: ${googleAuth.accessToken != null ? 'OK' : 'NULL'}');
        print('🔍 ID Token: ${googleAuth.idToken != null ? 'OK' : 'NULL'}');
        return {
          'success': false, 
          'message': 'Error obteniendo tokens de Google',
          'error_type': 'token_error'
        };
      }
      
      print('✅ Tokens obtenidos correctamente');
      
      // 5. Crear credencial para Firebase
      print('🔥 Creando credencial para Firebase...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // 6. Autenticar con Firebase
      print('🔐 Autenticando con Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        print('🎉 ¡ÉXITO! Firebase auth completado');
        print('🆔 UID: ${user.uid}');
        print('📧 Email: ${user.email}');
        print('👤 Nombre: ${user.displayName}');
        
        return {
          'success': true,
          'message': 'Login exitoso con Google + Firebase',
          'user': {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName ?? 'Usuario',
            'photoURL': user.photoURL,
            'provider': 'google',
            'emailVerified': user.emailVerified,
            'creationTime': user.metadata.creationTime?.toIso8601String(),
            'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
          },
        };
      } else {
        print('❌ Error: Usuario Firebase es null después de autenticación');
        return {
          'success': false, 
          'message': 'Error en autenticación Firebase - Usuario null',
          'error_type': 'firebase_user_null'
        };
      }
      
    } catch (e) {
      print('💥 ERROR CAPTURADO: $e');
      
      String errorMessage = 'Error desconocido en autenticación';
      String errorType = 'unknown_error';
      
      if (e.toString().contains('PlatformException')) {
        print('🔍 Error de plataforma detectado');
        if (e.toString().contains('sign_in_failed')) {
          if (e.toString().contains('ApiException: 10')) {
            errorMessage = 'Error de configuración de Google Sign-In. Verifique SHA-1 fingerprint en Firebase Console.';
            errorType = 'api_exception_10';
            print('🚨 ApiException: 10 - Problema de configuración SHA-1');
          } else {
            errorMessage = 'Error en Google Sign-In: ${e.toString()}';
            errorType = 'google_signin_error';
          }
        } else {
          errorMessage = 'Error de plataforma: ${e.toString()}';
          errorType = 'platform_exception';
        }
      } else if (e.toString().contains('FirebaseAuth')) {
        errorMessage = 'Error de Firebase Auth: ${e.toString()}';
        errorType = 'firebase_auth_error';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión de red';
        errorType = 'network_error';
      }
      
      print('📝 Error categorizado: $errorType');
      print('💬 Mensaje: $errorMessage');
      
      return {
        'success': false, 
        'message': errorMessage,
        'error_type': errorType,
        'raw_error': e.toString()
      };
    }
  }

  // Método para obtener información del usuario actual
  static Map<String, dynamic>? getCurrentUser() {
    final User? user = _auth.currentUser;
    final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
    
    if (user != null) {
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? 'Usuario',
        'photoURL': user.photoURL,
        'provider': 'google',
        'emailVerified': user.emailVerified,
        'googleSignedIn': googleUser != null,
      };
    }
    
    return null;
  }

  // Método para cerrar sesión
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
    }
  }
}
