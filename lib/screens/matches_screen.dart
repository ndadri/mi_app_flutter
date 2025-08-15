// Importación del paquete Flutter para la interfaz de usuario
import 'package:flutter/material.dart';
import 'menssages_screen.dart';
import 'home_screen.dart';
import 'eventos_screen.dart';
import 'perfil_usuario_screen.dart';

// Clase principal para la pantalla de Matches
class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Variables responsive para diferentes tamaños de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    final List<Map<String, String>> matches = [
      {
        'nombre': 'Luna',
        'imagen':
            'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg'
      },
      {
        'nombre': 'Max',
        'imagen':
            'https://images.pexels.com/photos/4588000/pexels-photo-4588000.jpeg'
      },
      {
        'nombre': 'Chispa',
        'imagen':
            'https://images.pexels.com/photos/4587996/pexels-photo-4587996.jpeg'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED), // Fondo gris claro de la pantalla
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
                  'MATCHES',
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
          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16), // Padding alrededor del contenido
              child: matches.isEmpty // Si no hay matches, muestra mensaje
                  ? const Center(child: Text('No tienes matches aún 😢'))
                  : GridView.builder(
                      // Si hay matches, muestra un GridView
                      itemCount: matches.length, // Número de ítems en el GridView
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // El número de columnas en el GridView
                        crossAxisSpacing: 12, // Espaciado entre las columnas
                        mainAxisSpacing: 12, // Espaciado entre las filas
                        childAspectRatio: 0.9, // Relación de aspecto de cada celda
                      ),
                      itemBuilder: (context, index) {
                        // Construcción de cada celda en el GridView
                        final match = matches[index];
                        return _matchCard(context, match['nombre']!, match['imagen']!);
                        // Llama a la función _matchCard para construir cada tarjeta
                      },
                    ),
            ),
          ),
        ],
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
                currentIndex: 0, // MATCH está seleccionado (índice 0)
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
                    // Ya estamos en Match, no navegar
                  } else if (index == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  } else if (index == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const EventosScreen()),
                    );
                  } else if (index == 3) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PerfilUsuarioScreen()),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget para la tarjeta que muestra el nombre y la imagen de cada mascota
  Widget _matchCard(BuildContext context, String nombre, String imagen) {
    return GestureDetector(
      onTap: () {
        // Aquí debes pasar el matchId real, por ahora usa un valor de ejemplo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MessagesScreen(matchId: 'match_id_de_ejemplo'),
          ),
        );
      },
      child: Container(
        // Estilo de la tarjeta (contenedor que representa un match)
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco para la tarjeta
          borderRadius: BorderRadius.circular(16), // Bordes redondeados
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)], // Sombra de la tarjeta
        ),
        child: Column(
          children: [
            // Imagen de la mascota (expandida para llenar la tarjeta)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), // Bordes redondeados en la parte superior
                child: Image.network(
                  imagen, // Carga la imagen desde la URL
                  width: double.infinity, // Ancho completo de la tarjeta
                  fit: BoxFit.cover, // Ajuste de la imagen para cubrir el espacio
                ),
              ),
            ),
            // Nombre de la mascota debajo de la imagen
            Padding(
              padding: const EdgeInsets.all(8), // Padding alrededor del texto
              child: Column(
                children: [
                  Text(
                    nombre, // Nombre de la mascota
                    style: const TextStyle(
                      fontWeight: FontWeight.w600, // Fuente en negrita
                      fontSize: 16, // Tamaño de la fuente
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '¡Escríbeme!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}