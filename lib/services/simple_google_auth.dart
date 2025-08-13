import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SimpleGoogleAuth {
  // Configuración usando Firebase Auth + Google Sign-In con Web Client ID específico
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Usando el Web Client ID de Firebase petmatch-1004e
    clientId: '610643579092-dddce346e5bee71787eb41.apps.googleusercontent.com',
  );
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔄 === FIREBASE + GOOGLE SIGN-IN ===');
      
      // 1. Estado inicial
      bool isSignedIn = await _googleSignIn.isSignedIn();
      print('👤 Ya logueado en Google: $isSignedIn');
      
      // 2. Limpiar sesión
      if (isSignedIn) {
        await _googleSignIn.signOut();
        await _auth.signOut();
        print('🔄 Sesiones limpiadas');
      }
      
      // 3. Intentar login con Google
      print('🚀 Iniciando Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Login cancelado');
        return {'success': false, 'message': 'Login cancelado'};
      }

      print('✅ Google login exitoso: ${googleUser.email}');
      
      // 4. Obtener credenciales de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // 5. Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // 6. Autenticar con Firebase
      print('🔥 Autenticando con Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        print('✅ Firebase auth exitoso: ${user.email}');
        
        return {
          'success': true,
          'message': 'Login exitoso con Google + Firebase',
          'user': {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName ?? 'Usuario',
            'photoURL': user.photoURL,
            'provider': 'google',
          },
        };
      } else {
        print('❌ Error: Usuario Firebase es null');
        return {'success': false, 'message': 'Error en autenticación Firebase'};
      }
      
    } catch (e) {
      print('❌ Error: $e');
      String message = 'Error en autenticación';
      
      if (e.toString().contains('PlatformException')) {
        message = 'Error de plataforma: ${e.toString()}';
      } else if (e.toString().contains('FirebaseAuth')) {
        message = 'Error de Firebase: ${e.toString()}';
      }
      
      return {'success': false, 'message': message};
    }
  }
}
