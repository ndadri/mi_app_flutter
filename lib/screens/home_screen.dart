// Importación del paquete de Flutter
import 'package:flutter/material.dart';

// Clase principal de la pantalla HomeScreen, que se mostrará al iniciar la app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Constructor de la clase HomeScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Configuración del fondo de la pantalla
      backgroundColor: const Color(0xFFEDEDED), // Color gris claro para el fondo

      // Contenedor principal con SafeArea para evitar que el contenido se solape con la barra superior
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            // Ajustes responsivos
            final isTablet = width > 900;
            final headerHeight = isTablet ? height * 0.13 : height * 0.10;
            final cardHeight = isTablet ? height * 0.90 : height * 0.65;
            final cardPadding = isTablet ? width * 0.15 : 20.0;
            final cardBorderRadius = isTablet ? 32.0 : 20.0;
            final cardTextFont = isTablet ? 28.0 : 20.0;
            final cardSubTextFont = isTablet ? 22.0 : 16.0;
            final buttonSize = isTablet ? 90.0 : 65.0;
            final iconSize = isTablet ? 44.0 : 32.0;
            final headerFontSize = isTablet ? 40.0 : 30.0;
            final headerPadding = isTablet ? 32.0 : 20.0;
            final spaceBetween = isTablet ? 105.0 : 70.0;

            return Column(
              children: [
                // Encabezado
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7A45D1), // Color de fondo morado
                  ),
                  alignment: Alignment.bottomCenter, // Alinea el texto en la parte inferior
                  padding: EdgeInsets.only(bottom: headerPadding), // Espaciado en la parte inferior
                  child: Text(
                    'Sexo entre mascotas', // Texto principal en el encabezado
                    style: TextStyle(
                      fontSize: headerFontSize, // Tamaño de la fuente
                      fontWeight: FontWeight.bold, // Estilo de la fuente
                      color: Colors.white, // Color de la fuente blanco
                      letterSpacing: 1.5, // Espaciado entre letras
                    ),
                  ),
                ),
                SizedBox(height: spaceBetween), // Espaciado entre el encabezado y la tarjeta

                // CARD DE LA MASCOTA (diseño fijo por ahora)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: cardPadding), // Padding en los lados
                  child: Container(
                    width: double.infinity, // Ocupa todo el ancho de la pantalla
                    height: cardHeight, // Altura de la tarjeta
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco
                      borderRadius: BorderRadius.circular(cardBorderRadius), // Bordes redondeados
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño según el contenido
                        crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                        children: [
                          Text(
                            'Luna, 2 años', // Nombre y edad de la mascota
                            style: TextStyle(
                              fontSize: cardTextFont, // Tamaño de la fuente
                              fontWeight: FontWeight.bold, // Estilo de la fuente
                            ),
                          ),
                          Text(
                            'Golden Retriever', // Raza de la mascota
                            style: TextStyle(fontSize: cardSubTextFont), // Estilo del texto
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: spaceBetween), // Espaciado entre la tarjeta y los botones

                // BOTONES DE LIKE Y DISLIKE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centra los botones horizontalmente
                  children: [
                    _circleButton(Icons.close, Colors.redAccent, buttonSize, iconSize), // Botón de dislike
                    SizedBox(width: isTablet ? 60 : 40), // Espaciado entre los botones
                    _circleButton(Icons.favorite, Colors.green, buttonSize, iconSize), // Botón de like
                  ],
                ),
              ],
            );
          },
        ),
      ),

      // NAV INFERIOR - Barra de navegación en la parte inferior
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return BottomNavigationBar(
            selectedItemColor: const Color(0xFF7A45D1), // Color cuando un item está seleccionado
            unselectedItemColor: Colors.grey, // Color cuando un item no está seleccionado
            iconSize: isTablet ? 38 : 24,
            selectedFontSize: isTablet ? 20 : 14,
            unselectedFontSize: isTablet ? 18 : 12,
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
          );
        },
      ),
    );
  }

  // Widget para los botones circulares (like y dislike)
  Widget _circleButton(IconData icon, Color color, double size, double iconSize) {
    return Container(
      width: size, // Ancho del botón
      height: size, // Alto del botón
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Forma circular
        color: Colors.white, // Color de fondo del botón
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)], // Sombra del botón
      ),
      child: IconButton(
        icon: Icon(icon, size: iconSize), // Ícono dentro del botón
        color: color, // Color del ícono (rojo para dislike, verde para like)
        onPressed: () {
          // Aquí irá la lógica de swipe (no implementada aún)
        },
      ),
    );
  }
}
