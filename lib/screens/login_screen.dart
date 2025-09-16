import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'admin_panel_screen.dart';
import '../services/enhanced_google_auth.dart';
import '../services/auto_login_service.dart'; // Nuestro nuevo servicio automático
import '../services/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Método para manejar el inicio de sesión - AUTO DETECT IP
  Future<void> loginUsuario(String username, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🚀 Iniciando proceso de login...');
      
      // Verificar credenciales de administrador rápidamente
      if (username == 'andersonsoto102@gmail.com' && password == 'Andersonsoto10') {
        setState(() {
          _isLoading = false;
        });
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
        );
        return;
      }

      // Usar el servicio automático que encuentra la IP correcta
      final result = await AutoLoginService.autoLogin(username, password);

      if (result['success']) {
        // Guardar información del usuario en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.setInt('user_id', result['user']['id']),
          prefs.setString('user_email', result['user']['correo']),
          prefs.setString('user_token', result['token']),
        ]);
        
        // Marcar sesión como activa usando SessionManager
        await SessionManager.markAsLoggedIn();
        
        // Si encontramos una IP que funciona, guardarla para futuros usos
        if (result['workingIP'] != null) {
          await prefs.setString('working_ip', result['workingIP']);
          print('💾 IP guardada para futuros usos: ${result['workingIP']}');
        }
        
        setState(() {
          _isLoading = false;
        });
        
        print('🎉 Login exitoso, navegando a home...');
        
        // Mostrar mensaje de éxito brevemente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Login exitoso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        
        // Navegación a home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'];
        });
        
        print('❌ Login falló: ${result['message']}');
      }
    } catch (e) {
      print('💥 Error inesperado en login: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error inesperado: $e';
      });
    }
  }

  // Función para probar conexión (debug)
  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🧪 Iniciando prueba de conexión...');
      
      final canConnect = await AutoLoginService.quickConnectionTest();
      
      setState(() {
        _isLoading = false;
      });
      
      if (canConnect) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Conexión exitosa! El servidor está accesible.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        print('✅ Prueba de conexión exitosa');
      } else {
        setState(() {
          _errorMessage = 'No se pudo conectar al servidor.\n\n'
                         'Verifica que:\n'
                         '• Tu teléfono y PC estén en la misma WiFi\n'
                         '• El servidor esté corriendo\n'
                         '• No haya firewall bloqueando';
        });
        print('❌ Prueba de conexión falló');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error en prueba de conexión: $e';
      });
      print('💥 Error en prueba: $e');
    }
  }

  // Login con Google - CON SINCRONIZACIÓN BACKEND
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Paso 1: Login con Google + Firebase
      final result = await EnhancedGoogleAuth.signInWithGoogle();
      
      if (result != null && result['success']) {
        final userData = result['user'];
        
        // Paso 2: Sincronizar con el backend para obtener datos completos
        print('🔄 Sincronizando con backend para obtener datos completos...');
        
        try {
          // Usar el endpoint de social-login del backend
          final response = await http.post(
            Uri.parse('http://192.168.1.24:3004/api/auth/social-login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': userData['email'],
              'name': userData['displayName'],
              'provider': 'google',
              'photoURL': userData['photoURL'] ?? '',
            }),
          ).timeout(const Duration(seconds: 10));
          
          if (response.statusCode == 200) {
            final backendData = jsonDecode(response.body);
            print('✅ Sincronización exitosa con backend');
            print('📄 Datos del backend: ${response.body}');
            
            // Guardar toda la información (Google + Backend)
            final prefs = await SharedPreferences.getInstance();
            final backendUser = backendData['user'];
            
            await Future.wait([
              // Datos de Google/Firebase
              prefs.setString('user_id_google', userData['uid']),
              prefs.setString('user_email', userData['email']),
              prefs.setString('user_name', userData['displayName']),
              prefs.setString('login_type', 'google'),
              prefs.setString('user_token', backendData['token']),
              
              // Datos completos del backend
              prefs.setInt('user_id', backendUser['id']),
              prefs.setString('profile_nombres', backendUser['nombres'] ?? ''),
              prefs.setString('profile_apellidos', backendUser['apellidos'] ?? ''),
              prefs.setString('profile_genero', backendUser['genero'] ?? ''),
              prefs.setString('profile_ubicacion', backendUser['ubicacion'] ?? ''),
              prefs.setString('profile_fecha_nacimiento', backendUser['fecha_nacimiento'] ?? ''),
            ]);
            
            print('💾 Datos completos guardados en SharedPreferences');
            
          } else {
            print('⚠️ Error en sincronización con backend: ${response.statusCode}');
            print('📄 Respuesta: ${response.body}');
            
            // Continuar con solo los datos de Google
            final prefs = await SharedPreferences.getInstance();
            await Future.wait([
              prefs.setString('user_id_google', userData['uid']),
              prefs.setString('user_email', userData['email']),
              prefs.setString('user_name', userData['displayName']),
              prefs.setString('login_type', 'google'),
            ]);
          }
          
        } catch (e) {
          print('⚠️ Error al sincronizar con backend: $e');
          
          // Continuar con solo los datos de Google
          final prefs = await SharedPreferences.getInstance();
          await Future.wait([
            prefs.setString('user_id_google', userData['uid']),
            prefs.setString('user_email', userData['email']),
            prefs.setString('user_name', userData['displayName']),
            prefs.setString('login_type', 'google'),
          ]);
        }
        
        // Marcar sesión como activa usando SessionManager
        await SessionManager.markAsLoggedIn();
        
        setState(() {
          _isLoading = false;
        });
        
        // Navegación inmediata sin snackbar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result?['message'] ?? 'Error en login con Google';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error inesperado: $e';
      });
    }
  }

  // Login con Facebook - temporalmente deshabilitado
  Future<void> _loginWithFacebook() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ Facebook login temporalmente deshabilitado para diagnóstico'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final hasKeyboard = keyboardHeight > 0;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      resizeToAvoidBottomInset: false, // Evita el overflow amarillo
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // HEADER QUE OCUPA TODA LA PARTE SUPERIOR INCLUIDA LA BARRA DE ESTADO
                  Container(
                    height: (hasKeyboard ? (isSmallScreen ? 80 : 100) : 120) + MediaQuery.of(context).padding.top,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A45D1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                    child: SafeArea(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(
                          bottom: hasKeyboard 
                            ? (isSmallScreen ? 8 : (screenWidth >= 600 ? 12 : 16))
                            : (screenWidth < 400 ? 16 : (screenWidth >= 600 ? 20 : 24)),
                        ),
                        child: Text(
                          'PET MATCH',
                          style: TextStyle(
                            fontFamily: 'AntonSC',
                            fontSize: hasKeyboard 
                              ? (isSmallScreen ? 24 : (screenWidth >= 600 ? 28 : 32))
                              : (screenWidth < 400 ? 34 : (screenWidth >= 600 ? 38 : 42)),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                    
                    // Espaciado
                    SizedBox(height: hasKeyboard ? (isSmallScreen ? 20 : 30) : 50),
                    
                    // Formulario de login
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: EdgeInsets.all(hasKeyboard ? (isSmallScreen ? 16 : 20) : 28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Iniciar Sesión',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'AntonSC',
                                fontSize: hasKeyboard ? (isSmallScreen ? 16 : 18) : 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: hasKeyboard ? (isSmallScreen ? 16 : 18) : 24),
                            
                            // Campo de usuario
                            TextField(
                              controller: _usernameController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Usuario o Correo',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: hasKeyboard ? (isSmallScreen ? 10 : 12) : 16,
                                ),
                              ),
                            ),
                            SizedBox(height: hasKeyboard ? (isSmallScreen ? 12 : 14) : 18),
                            
                            // Campo de contraseña
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: hasKeyboard ? (isSmallScreen ? 10 : 12) : 16,
                                ),
                              ),
                            ),
                            SizedBox(height: hasKeyboard ? (isSmallScreen ? 16 : 18) : 24),
                            
                            // Botón de login
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7A45D1),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: hasKeyboard ? (isSmallScreen ? 12 : 14) : 16,
                                ),
                                minimumSize: Size.fromHeight(hasKeyboard ? (isSmallScreen ? 44 : 48) : 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: (_usernameController.text.trim().isNotEmpty && 
                                         _passwordController.text.trim().isNotEmpty && 
                                         !_isLoading)
                                  ? () {
                                      final username = _usernameController.text.trim();
                                      final password = _passwordController.text.trim();
                                      loginUsuario(username, password);
                                    }
                                  : null,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: hasKeyboard ? (isSmallScreen ? 14 : 15) : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            SizedBox(height: hasKeyboard ? (isSmallScreen ? 8 : 10) : 12),
                            
                            // Link de contraseña olvidada
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                'Olvidaste tu Contraseña?',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: hasKeyboard ? (isSmallScreen ? 12 : 13) : 14,
                                ),
                              ),
                            ),
                            
                            // Mensaje de error
                            if (_errorMessage != null) ...[
                              SizedBox(height: hasKeyboard ? (isSmallScreen ? 8 : 10) : 12),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: hasKeyboard ? (isSmallScreen ? 12 : 13) : 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // Solo mostrar botones sociales si no hay teclado activo
                    if (!hasKeyboard) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Sign In with',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      
                      // Botón de Facebook
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            minimumSize: const Size.fromHeight(44),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.facebook, color: Color(0xFF1877F3)),
                          label: const Text('Continue with Facebook'),
                          onPressed: _isLoading ? null : _loginWithFacebook,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Botón de prueba de conexión (solo para debug)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.wifi_find),
                          label: const Text('🧪 Probar Conexión'),
                          onPressed: _isLoading ? null : _testConnection,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Botón de Google
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            minimumSize: const Size.fromHeight(44),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          icon: Image.asset(
                            'assets/google_icon.png',
                            height: 22,
                            width: 22,
                          ),
                          label: const Text('Continue with Google'),
                          onPressed: _isLoading ? null : _loginWithGoogle,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Enlace de registro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New Member? ',
                            style: TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Sign up Here',
                              style: TextStyle(
                                color: Color(0xFF7A45D1),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Espaciado final
                    SizedBox(height: hasKeyboard ? 20 : 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}