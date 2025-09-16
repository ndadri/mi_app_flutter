// Importación del paquete Flutter para la interfaz de usuario
import 'package:flutter/material.dart';

// Clase principal para la pantalla de detalles de la mascota
class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos falsos por ahora (pueden venir por parámetros luego)
    const String nombre = 'Luna'; // Nombre de la mascota
    const String edad = '2 años'; // Edad de la mascota
    const String raza = 'Golden Retriever'; // Raza de la mascota
    const String descripcion = 'Luna es una perrita muy cariñosa, juguetona y le encanta correr en el parque. Busca un hogar lleno de amor.'; // Descripción de la mascota

    return Scaffold(
      // AppBar de la pantalla
      appBar: AppBar(
        title: const Text('Detalle Mascota'), // Título de la app bar
        backgroundColor: const Color(0xFF7A45D1), // Color morado de fondo
        foregroundColor: Colors.white, // Color de los íconos del app bar
        centerTitle: true, // Centra el título
      ),
      backgroundColor: const Color(0xFFEDEDED), // Fondo gris claro para la pantalla
      body: Column(
        children: [
          // FOTO GRANDE de la mascota
          Container(
            height: 280, // Altura de la imagen
            width: double.infinity, // Ancho completo
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg', // URL de la imagen de la mascota
                ),
                fit: BoxFit.cover, // Ajusta la imagen para cubrir el contenedor
              ),
            ),
          ),

          // Contenedor con la información de la mascota
          Expanded(
            child: Container(
              width: double.infinity, // Ancho completo
              padding: const EdgeInsets.all(20), // Espaciado interno
              decoration: const BoxDecoration(
                color: Colors.white, // Fondo blanco
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Bordes redondeados en la parte superior
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
                children: [
                  // Mostrar el nombre y la edad de la mascota
                  const Text(
                    '$nombre • $edad', // Texto que combina el nombre y la edad
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Estilo del texto (tamaño y negrita)
                  ),
                  const SizedBox(height: 8), // Espaciado entre el nombre y la raza
                  // Mostrar la raza de la mascota
                  const Text(
                    raza,
                    style: TextStyle(fontSize: 18, color: Colors.grey), // Estilo del texto (gris)
                  ),
                  const Divider(height: 30, thickness: 1), // Línea divisoria
                  const Text(
                    'Descripción', // Título de la sección de descripción
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), // Estilo de texto (negrita)
                  ),
                  const SizedBox(height: 6), // Espaciado entre el título y la descripción
                  // Mostrar la descripción de la mascota
                  const Text(
                    descripcion,
                    style: TextStyle(fontSize: 16), // Estilo del texto (tamaño de fuente)
                  ),
                  const Spacer(), // Espaciador flexible que empuja el contenido hacia arriba
                  // Botón para mostrar el interés en la mascota
                  SizedBox(
                    width: double.infinity, // Ancho completo del botón
                    child: ElevatedButton(
                      onPressed: () {
                        // Aquí irá la lógica para contactar o agendar cita
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A45D1), // Fondo morado del botón
                        foregroundColor: Colors.white, // Color del texto blanco
                        padding: const EdgeInsets.symmetric(vertical: 14), // Padding vertical
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Bordes redondeados
                        ),
                      ),
                      child: const Text('¡Me interesa!'), // Texto del botón
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
