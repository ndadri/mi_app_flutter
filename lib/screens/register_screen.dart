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
      backgroundColor: const Color(0xFFEDEDED), // Fondo gris claro de la pantalla
      body: SingleChildScrollView( // Desplazamiento para manejar el teclado
        child: Padding(
          padding: const EdgeInsets.all(20), // Padding alrededor del contenido
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centra los elementos
            children: [
              // Header de la pantalla de registro
              Container(
                alignment: Alignment.topCenter, // Centra el título
                margin: const EdgeInsets.only(top: 50), // Espaciado superior
                child: const Text(
                  'Pet Match', // Título de la app
                  style: TextStyle(
                    fontSize: 36, // Tamaño de la fuente
                    fontWeight: FontWeight.bold, // Fuente en negrita
                    color: Color(0xFF7A45D1), // Color morado
                  ),
                ),
              ),
              const SizedBox(height: 40), // Espaciado entre el header y los campos de texto

              // Campos de texto para ingresar los datos del usuario
              _buildTextField('Nombre de Usuario', _nombreController),
              _buildTextField('Correo Electrónico', _emailController),
              _buildPasswordField('Contraseña', _passwordController),
              _buildPasswordField('Confirmar Contraseña', _confirmPasswordController),

              // Botón para confirmar el registro
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Lógica para registrar al usuario (falta implementar)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A45D1), // Fondo morado
                  foregroundColor: Colors.white, // Texto blanco
                  padding: const EdgeInsets.symmetric(vertical: 14), // Padding vertical
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bordes redondeados
                  ),
                ),
                child: const Text('Confirmar Contraseña'), // Texto del botón
              ),

              // Botones de redes sociales (Facebook y Google)
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centra los botones
                children: [
                  // Botón de Facebook
                  ElevatedButton.icon(
                    onPressed: () {
                      // Lógica para iniciar sesión con Facebook (falta implementar)
                    },
                    icon: const Icon(Icons.facebook), // Ícono de Facebook
                    label: const Text('Continue with Facebook'), // Texto del botón
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Color de fondo azul de Facebook
                      foregroundColor: Colors.white, // Texto blanco
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bordes redondeados
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Espaciado entre los botones
                  // Botón de Google
                  ElevatedButton.icon(
                    onPressed: () {
                      // Lógica para iniciar sesión con Google (falta implementar)
                    },
                    icon: const Icon(Icons.g_translate), // Ícono de Google
                    label: const Text('Continue with Google'), // Texto del botón
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Color de fondo rojo de Google
                      foregroundColor: Colors.white, // Texto blanco
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bordes redondeados
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Espaciado entre los botones y el texto de iniciar sesión

              // Texto para redirigir a la pantalla de login si el usuario ya tiene cuenta
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // Navegar a la pantalla de login
                },
                child: const Text(
                  'Have an account? Sign In Here', // Texto del enlace
                  style: TextStyle(
                    color: Color(0xFF7A45D1), // Color morado
                    fontWeight: FontWeight.bold, // Fuente en negrita
                  ),
                ),
              ),
            ],
          ),
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
          labelText: label, // Texto de la etiqueta
          labelStyle: const TextStyle(color: Colors.black), // Estilo de la etiqueta
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
          labelStyle: const TextStyle(color: Colors.black), // Estilo de la etiqueta
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          filled: true, // Activa el fondo relleno
          fillColor: Colors.white, // Color de fondo blanco
          suffixIcon: IconButton(
            icon: Icon(
              label == 'Contraseña'
                  ? (_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                  : (_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off), // Ícono de visibilidad
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
