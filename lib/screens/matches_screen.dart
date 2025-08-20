// Importación del paquete Flutter para la interfaz de usuario
import 'package:flutter/material.dart';
import 'menssages_screen.dart';
import 'home_screen.dart';
import 'eventos_screen.dart';
import 'perfil_usuario_screen.dart';
import 'perfil_screen.dart';
import '../services/match_service.dart';

// Clase principal para la pantalla de Matches
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> matches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMatches();
  }

  // Cargar matches desde la base de datos
  Future<void> _cargarMatches() async {
    setState(() {
      isLoading = true;
    });

    final resultado = await MatchService.obtenerMatches();
    
    if (mounted) {
      if (resultado['success']) {
        setState(() {
          matches = List<Map<String, dynamic>>.from(resultado['matches'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          matches = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message'] ?? 'Error al cargar matches'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Variables responsive para diferentes tamaños de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    final List<Map<String, dynamic>> matchesEjemplo = [];

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
                        return _matchCard(context, match);
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
                      MaterialPageRoute(builder: (context) => const PerfilScreen()),
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
  Widget _matchCard(BuildContext context, Map<String, dynamic> match) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagesScreen(
              matchId: match['match_id'].toString(),
            ),
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
                  match['mascota_foto'] ?? 'https://via.placeholder.com/150', // Carga la imagen desde la URL
                  width: double.infinity, // Ancho completo de la tarjeta
                  fit: BoxFit.cover, // Ajuste de la imagen para cubrir el espacio
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.pets,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Información de la mascota debajo de la imagen
            Padding(
              padding: const EdgeInsets.all(8), // Padding alrededor del texto
              child: Column(
                children: [
                  Text(
                    match['mascota_nombre'] ?? 'Mascota', // Nombre de la mascota
                    style: const TextStyle(
                      fontWeight: FontWeight.w600, // Fuente en negrita
                      fontSize: 16, // Tamaño de la fuente
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${match['mascota_tipo'] ?? ''} • ${match['mascota_edad'] ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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