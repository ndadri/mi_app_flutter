import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'admin_panel_screen.dart';
import '../config/api_config.dart';
import '../services/enhanced_google_auth.dart';

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

  // Método para manejar el inicio de sesión con backend - OPTIMIZADO
  Future<void> loginUsuario(String username, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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

      // Login normal optimizado con timeout reducido
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 8)); // Timeout de 8 segundos

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        // Guardar información del usuario en SharedPreferences de forma paralela
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.setInt('user_id', responseData['user']['id']),
          prefs.setString('user_email', responseData['user']['correo']),
          prefs.setString('user_token', responseData['token']),
        ]);
        
        setState(() {
          _isLoading = false;
        });
        
        // Navegación inmediata sin snackbar para mayor velocidad
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = responseData['message'] ?? 'Usuario o contraseña incorrectos';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error de conexión: $e';
      });
    }
  }

  // Login con Google - OPTIMIZADO
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await EnhancedGoogleAuth.signInWithGoogle();
      
      if (result != null && result['success']) {
        // Guardar información del usuario de Google de forma paralela y rápida
        final prefs = await SharedPreferences.getInstance();
        final userData = result['user'];
        
        await Future.wait([
          prefs.setString('user_id_google', userData['uid']),
          prefs.setString('user_email', userData['email']),
          prefs.setString('user_name', userData['displayName']),
          prefs.setString('login_type', 'google'),
        ]);
        
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
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: const CircularProgressIndicator(
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