import 'package:flutter/material.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final List<Map<String, dynamic>> eventos = [
    {
      'nombre': 'Paseo Canino',
      'fecha': '20/07/2025',
      'lugar': 'Parque La Carolina',
      'asistir': false,
      'imagen': null,
    },
    {
      'nombre': 'Feria de Mascotas',
      'fecha': '25/07/2025',
      'lugar': 'Centro de Convenciones',
      'asistir': false,
      'imagen': null,
    },
  ];

  // Controla si se muestra el modal de añadir evento
  bool showAddEventDialog = false;

  // Controladores para los campos del nuevo evento
  final TextEditingController tituloCtrl = TextEditingController();
  final TextEditingController fechaCtrl = TextEditingController();
  final TextEditingController lugarCtrl = TextEditingController();

  @override
  void dispose() {
    tituloCtrl.dispose();
    fechaCtrl.dispose();
    lugarCtrl.dispose();
    super.dispose();
  }

  void openAddEventDialog() {
    setState(() {
      showAddEventDialog = true;
      tituloCtrl.clear();
      fechaCtrl.clear();
      lugarCtrl.clear();
    });
  }

  void confirmAddEvent() {
    setState(() {
      eventos.add({
        'nombre': tituloCtrl.text,
        'fecha': fechaCtrl.text,
        'lugar': lugarCtrl.text,
        'asistir': false,
        'imagen': null,
      });
      showAddEventDialog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFEDEDED),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header morado
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7A45D1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 18, bottom: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Flecha a la izquierda
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      // Título centrado
                      const Center(
                        child: Text(
                          'Eventos',
                          style: TextStyle(
                            fontFamily: 'AntonSC',
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Lista de eventos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: eventos.map((evento) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          double maxWidth = constraints.maxWidth > 420 ? 420 : constraints.maxWidth;
                          // Usamos MediaQuery para altura adaptable
                          double cardHeight = MediaQuery.of(context).size.width < 400 ? 140 : 110;
                          return Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxWidth,
                                minWidth: 0,
                              ),
                              child: Container(
                                height: cardHeight,
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Información del evento (lado izquierdo)
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center, // <-- centra verticalmente
                                        children: [
                                          Text(
                                            evento['nombre']?.toUpperCase() ?? '',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF7A45D1),
                                              fontFamily: 'AntonSC',
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'FECHA: ${evento['fecha']?.toUpperCase() ?? ''}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'AntonSC',
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'LUGAR: ${evento['lugar']?.toUpperCase() ?? ''}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'AntonSC',
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Imagen del evento (lado derecho)
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                        image: evento['imagen'] != null
                                            ? DecorationImage(
                                                image: NetworkImage(evento['imagen']),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF7A45D1),
            foregroundColor: Colors.white,
            onPressed: openAddEventDialog,
            child: const Icon(Icons.add, size: 32),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
        // Modal para añadir evento
        if (showAddEventDialog)
          Center(
            child: Material(
              type: MaterialType.transparency,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth < 400 ? constraints.maxWidth * 0.95 : 400;
                    return SingleChildScrollView(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Container(
                          width: maxWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Añadir evento',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFF7A45D1),
                                  fontFamily: 'AntonSC',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              _inputField('Título', tituloCtrl),
                              _inputField('Fecha', fechaCtrl),
                              _inputField('Lugar', lugarCtrl),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => setState(() => showAddEventDialog = false),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        fontFamily: 'AntonSC',
                                        color: Color(0xFF7A45D1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF7A45D1),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: confirmAddEvent,
                                    child: const Text(
                                      'Confirmar',
                                      style: TextStyle(
                                        fontFamily: 'AntonSC',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'AntonSC',
            fontWeight: FontWeight.bold,
            color: Color(0xFF7A45D1),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: const TextStyle(
          fontFamily: 'AntonSC',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}