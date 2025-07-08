// Importación del paquete Flutter para la interfaz de usuario
import 'package:flutter/material.dart';

// Clase principal para la pantalla de Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true; // Controla si la contraseña es visible o no
  bool _emailValid = true; // Simulación de validación del email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED), // Color de fondo gris claro
      body: SingleChildScrollView( // Hacemos la pantalla desplazable en caso de que el teclado se active
        child: Column(
          children: [
            // Header con color morado y texto 'Pet Match'
            Container(
              height: 150, // Altura del contenedor
              width: double.infinity, // Toma todo el ancho de la pantalla
              decoration: const BoxDecoration(
                color: Color(0xFF7A45D1), // Color morado
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35), // Bordes redondeados solo en la parte inferior
                  bottomRight: Radius.circular(35),
                ),
              ),
              alignment: Alignment.bottomCenter, // Alinea el texto en la parte inferior
              padding: const EdgeInsets.only(bottom: 20), // Espaciado inferior
              child: const Text(
                'Pet Match', // Título principal de la app
                style: TextStyle(
                  fontSize: 60, // Tamaño de la fuente
                  fontWeight: FontWeight.bold, // Fuente en negrita
                  color: Colors.white, // Color de texto blanco
                  letterSpacing: 1.5, // Espaciado entre letras
                ),
              ),
            ),
            const SizedBox(height: 50), // Espacio entre el encabezado y el formulario

            // Card blanca con el formulario de inicio de sesión
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24), // Padding horizontal
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28), // Padding interno
                decoration: BoxDecoration(
                  color: Colors.white, // Fondo blanco
                  borderRadius: BorderRadius.circular(16), // Bordes redondeados
                  boxShadow: [ // Sombra para dar un efecto de elevación
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08), // Color de la sombra
                      blurRadius: 16, // Desenfoque de la sombra
                      offset: const Offset(0, 8), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Alinea el contenido a la izquierda
                  children: [
                    const Text(
                      'Iniciar Sesión', // Título del formulario
                      textAlign: TextAlign.center, // Centra el texto
                      style: TextStyle(
                        fontSize: 22, // Tamaño de la fuente
                        fontWeight: FontWeight.w600, // Estilo de la fuente
                        color: Colors.black87, // Color del texto
                      ),
                    ),
                    const SizedBox(height: 24), // Espaciado entre el título y el campo de texto

                    // Campo de texto para el nombre de usuario (simula validación de email)
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nombre de Usuario', // Texto del campo
                        hintText: 'Umetale@gmail.com', // Texto de ayuda
                        suffixIcon: _emailValid
                            ? const Icon(Icons.check_circle, color: Colors.green) // Ícono de validación
                            : null, // Si la validación es falsa, no muestra el ícono
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // Bordes redondeados
                        ),
                      ),
                    ),
                    const SizedBox(height: 18), // Espaciado entre el campo de texto y la contraseña

                    // Campo de texto para la contraseña
                    TextField(
                      obscureText: _obscurePassword, // Hace la contraseña invisible por defecto
                      decoration: InputDecoration(
                        labelText: 'Contraseña', // Texto del campo
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off // Ícono para ocultar la contraseña
                                : Icons.visibility, // Ícono para mostrar la contraseña
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword; // Cambia el estado de visibilidad de la contraseña
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // Bordes redondeados
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Espaciado entre los campos y el botón

                    // Botón principal para iniciar sesión
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A45D1), // Color de fondo del botón
                        foregroundColor: Colors.white, // Color del texto
                        padding: const EdgeInsets.symmetric(vertical: 14), // Espaciado interno del botón
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Bordes redondeados
                        ),
                        textStyle: const TextStyle(fontSize: 16), // Tamaño del texto
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/home'); // Navega a la pantalla de inicio después de login
                      },
                      child: const Text('Iniciar Sesión'), // Texto del botón
                    ),
                    const SizedBox(height: 12), // Espaciado entre el botón y el texto para recuperar contraseña

                    // Texto para recuperar la contraseña
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Olvidaste tu Contraseña?', // Texto de recuperación
                        style: TextStyle(
                          color: Colors.black54, // Color del texto
                          fontSize: 14, // Tamaño del texto
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24), // Espaciado entre el formulario y los botones de redes sociales

            // Texto para "Iniciar sesión con"
            const Text(
              'Sign In with',
              style: TextStyle(fontSize: 14, color: Colors.black54), // Estilo del texto
            ),
            const SizedBox(height: 12), // Espaciado entre el texto y los botones de redes sociales

            // Botón de Facebook
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36), // Padding horizontal
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Fondo blanco
                  foregroundColor: Colors.black87, // Color del texto
                  minimumSize: const Size.fromHeight(44), // Tamaño mínimo del botón
                  side: const BorderSide(color: Color(0xFFE0E0E0)), // Borde gris claro
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bordes redondeados
                  ),
                  elevation: 0, // Sin sombra
                ),
                icon: const Icon(Icons.facebook, color: Color(0xFF1877F3)), // Ícono de Facebook
                label: const Text('Continue with Facebook'), // Texto del botón
                onPressed: () {}, // Lógica para el inicio con Facebook
              ),
            ),
            const SizedBox(height: 10), // Espaciado entre los botones

            // Botón de Google
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36), // Padding horizontal
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Fondo blanco
                  foregroundColor: Colors.black87, // Color del texto
                  minimumSize: const Size.fromHeight(44), // Tamaño mínimo del botón
                  side: const BorderSide(color: Color(0xFFE0E0E0)), // Borde gris claro
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bordes redondeados
                  ),
                  elevation: 0, // Sin sombra
                ),
                icon: Image.asset(
                  'assets/google_icon.png', // Icono de Google desde los assets
                  height: 22,
                  width: 22,
                ),
                label: const Text('Continue with Google'), // Texto del botón
                onPressed: () {}, // Lógica para el inicio con Google
              ),
            ),
            const SizedBox(height: 24), // Espaciado entre el botón de Google y el footer

            // Footer con enlace para registrar una nueva cuenta
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido
              children: [
                const Text(
                  'New Member? ', // Texto de invitación para registrarse
                  style: TextStyle(color: Colors.black54, fontSize: 14), // Estilo del texto
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register'); // Navega a la pantalla de registro
                  },
                  child: const Text(
                    'Sign up Here', // Texto para registrarse
                    style: TextStyle(
                      color: Color(0xFF7A45D1), // Color morado
                      fontWeight: FontWeight.bold, // Estilo en negrita
                      fontSize: 14, // Tamaño del texto
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24), // Espaciado entre el footer y el final
          ],
        ),
      ),
    );
  }
}
