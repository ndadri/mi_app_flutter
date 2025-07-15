import 'package:flutter/material.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  // Ejemplo de eventos
  final List<Map<String, dynamic>> eventos = [
    {
      'nombre': 'Paseo Canino',
      'fecha': '20/07/2025',
      'lugar': 'Parque La Carolina',
      'asistir': false,
      'imagen': 'https://via.placeholder.com/80x80?text=Paseo+Canino',
    },
    {
      'nombre': 'Feria de Mascotas',
      'fecha': '25/07/2025',
      'lugar': 'Centro de Convenciones',
      'asistir': false,
      'imagen': 'https://via.placeholder.com/80x80?text=Feria+de+Mascotas',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header morado
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF7A45D1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 24),
              child: const Text(
                'Eventos',
                style: TextStyle(
                  fontFamily: 'AntonSC', // <-- Aquí
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Lista de eventos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: eventos.map((evento) {
                  return Container(
                    height: 220, // <-- Altura fija uniforme para todos los cuadros
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Contenido principal con imagen
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              // Información del evento (lado izquierdo)
                              Expanded(
                                flex: 2, // <-- Ocupa 2/3 del ancho
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      evento['nombre'],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF7A45D1),
                                        fontFamily: 'AntonSC',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Fecha: ${evento['fecha']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Lugar: ${evento['lugar']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16), // <-- Espacio entre texto e imagen
                              // Imagen del evento (lado derecho)
                              Container(
                                width: 80, // <-- Ancho fijo para la imagen
                                height: 80, // <-- Alto fijo para la imagen
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[200], // <-- Color de fondo mientras carga
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      evento['imagen'] ?? 'https://via.placeholder.com/80x80?text=Evento'
                                    ), // <-- URL de la imagen del evento
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Espaciador
                        const SizedBox(height: 16),
                        // Botón (altura fija)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: evento['asistir']
                                  ? Colors.green
                                  : const Color(0xFF7A45D1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'AntonSC',
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                evento['asistir'] = !evento['asistir'];
                              });
                            },
                            icon: Icon(evento['asistir'] ? Icons.check : Icons.event_available),
                            label: Text(evento['asistir'] ? 'Asistiendo' : 'Asistir'),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}