// Importación del paquete de Flutter
import 'package:flutter/material.dart';

// Clase principal de la pantalla HomeScreen, que se mostrará al iniciar la app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Constructor de la clase HomeScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Configuración del fondo de la pantalla
      backgroundColor:
          const Color(0xFFEDEDED), // Color gris claro para el fondo

      // Contenedor principal SIN SafeArea para que el header ocupe toda la pantalla
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // Ajustes responsivos
          final isTablet = width >= 600 && width < 1024;
          final isDesktop = width >= 1024;
          final isSmall = width < 400;

          final cardHeight = isDesktop
              ? height * 0.70
              : isTablet
                  ? height * 0.65
                  : height * 0.50;
          final cardPadding = isDesktop
              ? width * 0.25
              : isTablet
                  ? width * 0.15
                  : width * 0.05;
          final cardBorderRadius = isDesktop
              ? 36.0
              : isTablet
                  ? 28.0
                  : 18.0;
          final cardTextFont = isDesktop
              ? 32.0
              : isTablet
                  ? 24.0
                  : 18.0;
          final buttonSize = isDesktop
              ? 100.0
              : isTablet
                  ? 80.0
                  : 56.0;
          final iconSize = isDesktop
              ? 48.0
              : isTablet
                  ? 36.0
                  : 26.0;
          final headerPadding = isDesktop
              ? 40.0
              : isTablet
                  ? 28.0
                  : 16.0;

          return Scaffold(
            body: Column(
              children: [
                // HEADER QUE OCUPA TODA LA PARTE SUPERIOR INCLUIDA LA BARRA DE ESTADO
                Container(
                  height: 120,
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
                        bottom: isSmall
                            ? 20
                            : (isTablet ? 24 : 28), // Padding responsivo
                      ),
                      child: Text(
                        'PET MATCH',
                        style: TextStyle(
                          fontFamily: 'AntonSC',
                          fontSize: isSmall
                              ? 34
                              : (isTablet ? 38 : 42), // Tamaño responsivo
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // CONTENIDO PRINCIPAL - TARJETAS CENTRADAS
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: cardPadding),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centra verticalmente
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Centra horizontalmente
                        children: [
                          // Espaciado superior para centrar mejor
                          SizedBox(height: headerPadding),

                          // TARJETA DE MASCOTA - IMAGEN
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: isSmall
                                  ? 320
                                  : (isTablet
                                      ? 400
                                      : 450), // Ancho máximo responsivo
                            ),
                            height: cardHeight * 0.65, // Altura responsiva
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  cardBorderRadius +
                                      5), // Bordes más redondeados
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Espaciado entre imagen e información
                          SizedBox(height: isSmall ? 16 : 20),

                          // INFORMACIÓN DE LA MASCOTA - CENTRADA
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: isSmall
                                  ? 320
                                  : (isTablet
                                      ? 400
                                      : 450), // Mismo ancho que la imagen
                            ),
                            padding: EdgeInsets.all(
                                isSmall ? 18 : 24), // Más padding
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  cardBorderRadius +
                                      5), // Bordes más redondeados
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Nombre y edad
                                Text(
                                  'Luna, 2 años',
                                  style: TextStyle(
                                    fontFamily: 'AntonSC',
                                    fontSize: cardTextFont * 0.8,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF7A45D1),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isSmall ? 4 : 8),

                                // Ubicación
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: isSmall ? 12 : 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Cerca - En Quito',
                                      style: TextStyle(
                                        fontSize: isSmall ? 10 : 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmall ? 6 : 10),

                                // Descripción
                                Text(
                                  'Soy buena onda',
                                  style: TextStyle(
                                    fontSize: isSmall ? 11 : 13,
                                    color: Colors.black87,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isSmall ? 8 : 12),

                                // Información en filas
                                Column(
                                  children: [
                                    // Tipo y Raza
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _infoItem(Icons.pets, 'Perro', isSmall),
                                        _infoItem(
                                            Icons.pets,
                                            'Golden Retriever',
                                            isSmall), // <-- Cambiado de Icons.category a Icons.pets
                                      ],
                                    ),
                                    SizedBox(height: isSmall ? 6 : 8),

                                    // Sexo y Estado
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _infoItem(Icons.pets, 'Hembra',
                                            isSmall), // <-- Cambiado de Icons.wc a Icons.pets
                                        _infoItem(Icons.check_circle,
                                            'Disponible', isSmall),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmall ? 8 : 12),
                              ],
                            ),
                          ),

                          // Espaciado antes de los botones
                          SizedBox(height: isSmall ? 20 : 28),

                          // BOTONES DE LIKE Y DISLIKE - CENTRADOS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _circleButton(Icons.close, Colors.redAccent,
                                  buttonSize, iconSize),
                              SizedBox(
                                  width: isDesktop
                                      ? 70
                                      : isTablet
                                          ? 55
                                          : 45), // Espacio entre botones
                              _circleButton(Icons.favorite, Colors.green,
                                  buttonSize, iconSize),
                            ],
                          ),

                          // Espaciado final
                          SizedBox(height: headerPadding),

                          // Botón para acceder a la pantalla de citas
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE040FB),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.event_available),
                            label: const Text(
                              'Ver Citas',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/dates');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // NAV INFERIOR - Barra de navegación en la parte inferior
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final isDesktop = constraints.maxWidth >= 1024;
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft:
                    Radius.circular(20), // <-- Borde curvo superior izquierdo
                topRight:
                    Radius.circular(20), // <-- Borde curvo superior derecho
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors
                    .transparent, // <-- Transparente para que se vea el container
                elevation: 0, // <-- Sin elevación para evitar sombras dobles
                selectedItemColor: const Color(0xFF7A45D1),
                unselectedItemColor: Colors.grey,
                iconSize: isDesktop
                    ? 40
                    : isTablet
                        ? 32
                        : 22,
                selectedFontSize: isDesktop
                    ? 22
                    : isTablet
                        ? 16
                        : 12,
                unselectedFontSize: isDesktop
                    ? 20
                    : isTablet
                        ? 14
                        : 10,
                currentIndex: 1,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Match',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.pets),
                    label: 'Inicio',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event),
                    label: 'Eventos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                ],
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushNamed(context, '/matches');
                  } else if (index == 1) {
                    // Inicio, no navega
                  } else if (index == 2) {
                    Navigator.pushNamed(context, '/eventos');
                  } else if (index == 3) {
                    Navigator.pushNamed(context, '/perfil');
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget para los botones circulares (like y dislike)
  Widget _circleButton(
      IconData icon, Color color, double size, double iconSize) {
    return Container(
      width: size, // Ancho del botón
      height: size, // Alto del botón
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(size * 0.3), // <-- Bordes curvos suaves
        color: Colors.white, // Color de fondo del botón
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4)
        ], // Sombra del botón
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

  // Widget para información con icono
  Widget _infoItem(IconData icon, String text, bool isSmall) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isSmall ? 14 : 16,
            color: const Color(0xFF7A45D1),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmall ? 11 : 13,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
