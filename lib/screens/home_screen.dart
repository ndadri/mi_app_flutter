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
            final isTablet = width >= 600 && width < 1024;
            final isDesktop = width >= 1024;
            final isSmall = width < 400;

            final headerHeight = isDesktop
                ? height * 0.13
                : isTablet
                    ? height * 0.12
                    : height * 0.10;
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
            final cardSubTextFont = isDesktop
                ? 26.0
                : isTablet
                    ? 18.0
                    : 14.0;
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
            final headerFontSize = isDesktop
                ? 48.0
                : isTablet
                    ? 36.0
                    : 24.0;
            final headerPadding = isDesktop
                ? 40.0
                : isTablet
                    ? 28.0
                    : 16.0;
            final spaceBetween = isDesktop
                ? 140.0
                : isTablet
                    ? 100.0
                    : 60.0;

            return SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado arriba
                  Container(
                    height: headerHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A45D1), // Color de fondo morado
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12), // <-- Borde inferior izquierdo suave
                        bottomRight: Radius.circular(12), // <-- Borde inferior derecho suave
                      ),
                    ),
                    alignment: Alignment.bottomCenter, // Alinea el texto en la parte inferior
                    padding: EdgeInsets.only(bottom: headerPadding), // Espaciado en la parte inferior
                    child: Text(
                      'Sexo entre mascotas', // Texto principal en el encabezado
                      style: TextStyle(
                        fontFamily: 'AntonSC', // <-- Aquí
                        fontSize: headerFontSize, // Tamaño de la fuente
                        fontWeight: FontWeight.bold, // Estilo de la fuente
                        color: Colors.white, // Color de la fuente blanco
                        letterSpacing: 1.5, // Espaciado entre letras
                      ),
                    ),
                  ),
                  // Aquí centramos solo la tarjeta y los botones
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // CARD DE LA MASCOTA (más pequeña)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: cardPadding + 40), // <-- Más padding para carta más pequeña
                          child: Container(
                            width: double.infinity,
                            height: cardHeight * 0.6, // <-- Reducir altura al 60% (antes era 80%)
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(cardBorderRadius),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 8),
                              ],
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        
                        // Espaciado entre carta e información
                        SizedBox(height: isSmall ? 6 : 12), // <-- Menos espaciado
                        
                        // INFORMACIÓN DE LA MASCOTA (más pequeña también)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: cardPadding + 40), // <-- Mismo padding que la carta
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isSmall ? 12 : 16), // <-- Menos padding interno
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
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
                                    SizedBox(width: 4),
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
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _infoItem(Icons.pets, 'Perro', isSmall),
                                        _infoItem(Icons.pets, 'Golden Retriever', isSmall), // <-- Cambiado de Icons.category a Icons.pets
                                      ],
                                    ),
                                    SizedBox(height: isSmall ? 6 : 8),
                                    
                                    // Sexo y Estado
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _infoItem(Icons.pets, 'Hembra', isSmall), // <-- Cambiado de Icons.wc a Icons.pets
                                        _infoItem(Icons.check_circle, 'Disponible', isSmall),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmall ? 8 : 12),
                                
                                // Intereses
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _interestChip('📸 Fotografía de paisajes', isSmall),
                                    _interestChip('🏋️ Ir al gimnasio', isSmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Espaciado antes de los botones
                        SizedBox(height: isSmall ? 12 : 20), // <-- Menos espaciado
                        
                        // BOTONES DE LIKE Y DISLIKE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _circleButton(Icons.close, Colors.redAccent, buttonSize, iconSize),
                            SizedBox(width: isDesktop ? 60 : isTablet ? 48 : 40), // <-- Espacio entre botones optimizado
                            _circleButton(Icons.favorite, Colors.green, buttonSize, iconSize),
                          ],
                        ),
                        
                        // Espaciado final
                        SizedBox(height: isSmall ? 16 : 24), // <-- Espacio final
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // NAV INFERIOR - Barra de navegación en la parte inferior
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final isDesktop = constraints.maxWidth >= 1024;
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), // <-- Borde curvo superior izquierdo
                topRight: Radius.circular(20), // <-- Borde curvo superior derecho
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
                backgroundColor: Colors.transparent, // <-- Transparente para que se vea el container
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
  Widget _circleButton(IconData icon, Color color, double size, double iconSize) {
    return Container(
      width: size, // Ancho del botón
      height: size, // Alto del botón
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3), // <-- Bordes curvos suaves
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
          SizedBox(width: 4),
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

  // Widget para chips de intereses (más pequeños)
  Widget _interestChip(String text, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10, // <-- Menos padding horizontal
        vertical: isSmall ? 3 : 5, // <-- Menos padding vertical
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF7A45D1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16), // <-- Bordes más pequeños
        border: Border.all(
          color: const Color(0xFF7A45D1).withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSmall ? 9 : 11, // <-- Texto más pequeño
          color: const Color(0xFF7A45D1),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget para filas de información detallada
  Widget _detailRow(String label, String value, bool isSmall, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: isSmall ? 4 : 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label (izquierda)
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Value (derecha)
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        // Línea divisoria (excepto en el último elemento)
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey[300],
          ),
      ],
    );
  }
}
