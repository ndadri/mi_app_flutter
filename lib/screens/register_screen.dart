// Importación del paquete Flutter para la interfaz de usuario
import 'package:flutter/material.dart';

// Clase principal para la pantalla de registro de nuevo usuario
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para los campos de texto (nombre de usuario, correo, contraseña)
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variables para controlar la visibilidad de las contraseñas
  bool _isPasswordVisible = false; 
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado con fondo morado y esquinas inferiores redondeadas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFF7A45D1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Center(
                child: Text(
                  'Pet Match',
                  style: TextStyle(
                    fontFamily: 'AntonSC', // <-- Aquí
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: 430,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Crear Cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField('Nombre de Usuario', _nombreController),
                    _buildTextField('Correo Electrónico', _emailController),
                    _buildPasswordField('Contraseña', _passwordController),
                    _buildPasswordField('Confirmar Contraseña', _confirmPasswordController),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica para registrar al usuario
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A45D1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'AntonSC', // <-- Aplica la fuente aquí
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        child: const Text('Registrarse'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Función para construir campos de texto generales (nombre de usuario y correo)
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Espaciado vertical entre los campos
      child: TextField(
        controller: controller, // Controlador del campo de texto
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'AntonSC',
            color: Colors.black54, // <-- Gris medio
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          filled: true, // Activa el fondo relleno
          fillColor: Colors.white, // Color de fondo blanco
        ),
      ),
    );
  }

  // Función para construir los campos de contraseña con el botón para mostrar/ocultar la contraseña
  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Espaciado vertical entre los campos
      child: TextField(
        controller: controller, // Controlador del campo de texto
        obscureText: label == 'Contraseña' ? !_isPasswordVisible : !_isConfirmPasswordVisible, // Muestra/oculta la contraseña
        decoration: InputDecoration(
          labelText: label, // Texto de la etiqueta
          labelStyle: const TextStyle(
            fontFamily: 'AntonSC',
            color: Colors.black54, // <-- Gris medio
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          filled: true, // Activa el fondo relleno
          fillColor: Colors.white, // Color de fondo blanco
          suffixIcon: IconButton(
            icon: Icon(
              label == 'Contraseña'
                  ? (_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                  : (_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                if (label == 'Contraseña') {
                  _isPasswordVisible = !_isPasswordVisible; // Cambia el estado de la contraseña
                } else {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible; // Cambia el estado de la confirmación
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
