// Importación del paquete Flutter para la interfaz de usuario
import 'package:flutter/material.dart';

// Clase principal para la pantalla de Matches
class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de matches, con nombre e imagen de cada mascota
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
      // AppBar de la pantalla de Matches
      appBar: AppBar(
        title: const Text('Matches'), // Título del app bar
        backgroundColor: const Color(0xFF7A45D1), // Fondo morado
        foregroundColor: Colors.white, // Color de los íconos del app bar
        centerTitle: true, // Centra el título
      ),
      backgroundColor: const Color(0xFFEDEDED), // Fondo gris claro de la pantalla
      body: Padding(
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
                  final match = matches[index]; // Obtén los datos del match
                  return _matchCard(match['nombre']!, match['imagen']!);
                  // Llama a la función _matchCard para construir cada tarjeta
                },
              ),
      ),
    );
  }

  // Widget para la tarjeta que muestra el nombre y la imagen de cada mascota
  Widget _matchCard(String nombre, String imagen) {
    return Container(
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
            child: Text(
              nombre, // Nombre de la mascota
              style: const TextStyle(
                fontWeight: FontWeight.w600, // Fuente en negrita
                fontSize: 16, // Tamaño de la fuente
              ),
            ),
          )
        ],
      ),
    );
  }
}
