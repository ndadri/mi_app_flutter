// Importación del paquete de Flutter
import 'package:flutter/material.dart';

// Clase principal de la pantalla HomeScreen, que se mostrará al iniciar la app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Constructor de la clase HomeScreen

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla del dispositivo
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Configuración del fondo de la pantalla
      backgroundColor: const Color(0xFFEDEDED), // Color gris claro para el fondo

      // Contenedor principal con SafeArea para evitar que el contenido se solape con la barra superior
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado superior de color morado con el texto 'Sexo entre mascotas'
            Container(
              height: 80, // Altura del encabezado
              width: double.infinity, // Ocupa todo el ancho de la pantalla
              decoration: const BoxDecoration(
                color: Color(0xFF7A45D1), // Color de fondo morado
              ),
              alignment: Alignment.bottomCenter, // Alinea el texto en la parte inferior
              padding: const EdgeInsets.only(bottom: 20), // Espaciado en la parte inferior
              child: const Text(
                'Sexo entre mascotas', // Texto principal en el encabezado
                style: TextStyle(
                  fontSize: 30, // Tamaño de la fuente
                  fontWeight: FontWeight.bold, // Estilo de la fuente
                  color: Colors.white, // Color de la fuente blanco
                  letterSpacing: 1.5, // Espaciado entre letras
                ),
              ),
            ),
            const SizedBox(height: 50), // Espaciado entre el encabezado y la tarjeta

            // CARD DE LA MASCOTA (diseño fijo por ahora)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20), // Padding en los lados
              child: Container(
                width: double.infinity, // Ocupa todo el ancho de la pantalla
                height: 600, // Altura de la tarjeta
                decoration: BoxDecoration(
                  color: Colors.white, // Fondo blanco
                  borderRadius: BorderRadius.circular(20), // Bordes redondeados
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8), // Sombra de la tarjeta
                  ],
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg', // Imagen de la mascota
                    ),
                    fit: BoxFit.cover, // Ajuste de la imagen para cubrir todo el contenedor
                  ),
                ),
                alignment: Alignment.bottomLeft, // Alinea el contenido de la tarjeta en la parte inferior izquierda
                padding: const EdgeInsets.all(20), // Espaciado interno de la tarjeta
                child: Container(
                  padding: const EdgeInsets.all(12), // Espaciado interno del contenedor de texto
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), // Fondo blanco con opacidad
                    borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min, // Ajusta el tamaño según el contenido
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                    children: [
                      Text('Luna, 2 años', // Nombre y edad de la mascota
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)), // Estilo del texto
                      Text('Golden Retriever', // Raza de la mascota
                          style: TextStyle(fontSize: 16)), // Estilo del texto
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30), // Espaciado entre la tarjeta y los botones

            // BOTONES DE LIKE Y DISLIKE
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
              children: [
                _circleButton(Icons.close, Colors.redAccent), // Botón de dislike
                const SizedBox(width: 40), // Espaciado entre los botones
                _circleButton(Icons.favorite, Colors.green), // Botón de like
              ],
            ),
          ],
        ),
      ),

      // NAV INFERIOR - Barra de navegación en la parte inferior
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF7A45D1), // Color cuando un item está seleccionado
        unselectedItemColor: Colors.grey, // Color cuando un item no está seleccionado
        currentIndex: 1, // Ítem seleccionado inicialmente (Inicio)
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/matches'); // Navegar a Matches
          } else if (index == 2) {
            Navigator.pushNamed(context, '/register_pet'); // Navegar al registro de mascotas
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Matches'), // Ítem de Matches
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Inicio'), // Ítem de Inicio
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'), // Ítem de Perfil
        ],
      ),
    );
  }

  // Widget para los botones circulares (like y dislike)
  Widget _circleButton(IconData icon, Color color) {
    return Container(
      width: 65, // Ancho del botón
      height: 65, // Alto del botón
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Forma circular
        color: Colors.white, // Color de fondo del botón
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)], // Sombra del botón
      ),
      child: IconButton(
        icon: Icon(icon, size: 32), // Ícono dentro del botón
        color: color, // Color del ícono (rojo para dislike, verde para like)
        onPressed: () {
          // Aquí irá la lógica de swipe (no implementada aún)
        },
      ),
    );
  }
}
