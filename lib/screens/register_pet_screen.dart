// Importación del paquete Flutter para la interfaz de usuario
import 'package:flutter/material.dart';

// Clase principal para la pantalla de registro de una nueva mascota
class RegisterPetScreen extends StatefulWidget {
  const RegisterPetScreen({super.key});

  @override
  State<RegisterPetScreen> createState() => _RegisterPetScreenState();
}

class _RegisterPetScreenState extends State<RegisterPetScreen> {
  // Controladores para los campos de texto (nombre, edad, raza y descripción)
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _razaController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con título 'Registrar Mascota'
      appBar: AppBar(
        title: const Text('Registrar Mascota'), // Título de la AppBar
        backgroundColor: const Color(0xFF7A45D1), // Color de fondo morado
        foregroundColor: Colors.white, // Color del texto en blanco
        centerTitle: true, // Centra el título
      ),
      backgroundColor: const Color(0xFFEDEDED), // Fondo gris claro para la pantalla
      body: SingleChildScrollView(
        // Hace la pantalla desplazable en caso de que el teclado se active
        padding: const EdgeInsets.all(16), // Padding alrededor de la pantalla
        child: Column(
          children: [
            // Contenedor para la imagen (fija por ahora)
            Container(
              width: double.infinity, // Ancho completo de la pantalla
              height: 180, // Altura de la imagen
              decoration: BoxDecoration(
                color: Colors.grey[300], // Fondo gris claro para la imagen
                borderRadius: BorderRadius.circular(12), // Bordes redondeados
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg', // Imagen de ejemplo
                  ),
                  fit: BoxFit.cover, // La imagen cubre todo el espacio
                ),
              ),
              alignment: Alignment.bottomRight, // Alineación de los botones en la parte inferior derecha
              padding: const EdgeInsets.all(8), // Padding alrededor del botón
              child: ElevatedButton.icon(
                onPressed: () {
                  // Lógica para seleccionar una nueva imagen
                },
                icon: const Icon(Icons.upload), // Ícono para cargar la imagen
                label: const Text('Subir foto'), // Texto del botón
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8), // Fondo semi-transparente
                  foregroundColor: Colors.black, // Color del ícono y texto en negro
                ),
              ),
            ),
            const SizedBox(height: 16), // Espaciado entre la imagen y los campos de texto

            // Campos de texto para ingresar el nombre, edad, raza y descripción de la mascota
            _buildTextField('Nombre', _nombreController),
            _buildTextField('Edad', _edadController),
            _buildTextField('Raza', _razaController),
            _buildTextField('Descripción', _descripcionController, maxLines: 3), // Campo de descripción con 3 líneas

            const SizedBox(height: 20), // Espaciado antes del botón de guardar

            // Botón para guardar la mascota
            ElevatedButton(
              onPressed: () {
                // Lógica para guardar los datos de la mascota
                Navigator.pop(context); // Vuelve a la pantalla anterior
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A45D1), // Fondo morado
                foregroundColor: Colors.white, // Color del texto en blanco
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12), // Padding interno
              ),
              child: const Text('Guardar'), // Texto del botón
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear los campos de texto (Nombre, Edad, Raza, Descripción)
  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Espaciado entre los campos
      child: TextField(
        controller: controller, // Asocia el controlador al campo de texto
        maxLines: maxLines, // Número máximo de líneas para el campo (por defecto 1)
        decoration: InputDecoration(
          labelText: label, // Texto que aparece como etiqueta
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // Bordes redondeados
          filled: true, // Habilita el fondo relleno
          fillColor: Colors.white, // Color de fondo blanco para el campo de texto
        ),
      ),
    );
  }
}
