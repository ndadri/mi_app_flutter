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
      'hora': '10:00',
      'lugar': 'Parque La Carolina',
      'asistir': false,
      'imagen': null,
    },
    {
      'nombre': 'Feria de Mascotas',
      'fecha': '25/07/2025',
      'hora': '15:00',
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
  final TextEditingController horaCtrl = TextEditingController(); 
  final TextEditingController lugarCtrl = TextEditingController();
  

  @override
  void dispose() {
    tituloCtrl.dispose();
    fechaCtrl.dispose();
    horaCtrl.dispose(); 
    lugarCtrl.dispose();
    
    super.dispose();
  }

  void openAddEventDialog() {
    setState(() {
      showAddEventDialog = true;
      tituloCtrl.clear();
      fechaCtrl.clear();
      horaCtrl.clear();
      lugarCtrl.clear();
      // <-- Limpia el campo de hora
    });
  }

  void confirmAddEvent() {
    if (tituloCtrl.text.trim().isEmpty ||
        fechaCtrl.text.trim().isEmpty ||
        horaCtrl.text.trim().isEmpty ||
        lugarCtrl.text.trim().isEmpty) {
      // Puedes mostrar un mensaje de error aquí si quieres
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }
    setState(() {
      eventos.add({
        'nombre': tituloCtrl.text,
        'fecha': fechaCtrl.text,
        'hora': horaCtrl.text,
        'lugar': lugarCtrl.text,
        'asistir': false,
        'imagen': null,
      });
      showAddEventDialog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
  print('EVENTOS: $eventos');
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFEDEDED),
          body: Column(
            children: [
              // Header morado
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF7A45D1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 20),
                child: const Text(
                  'Eventos',
                  style: TextStyle(
                    fontFamily: 'AntonSC',
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              // Lista de eventos
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: eventos.isEmpty
                      ? const Center(child: Text('No hay eventos'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 24, bottom: 80),
                          itemCount: eventos.length,
                          itemBuilder: (context, index) {
                            final evento = eventos[index];
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                double maxWidth = constraints.maxWidth > 420 ? 420 : constraints.maxWidth;
                                return Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: maxWidth,
                                      minWidth: 0,
                                    ),
                                    child: Container(
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
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  evento['nombre']?.toUpperCase() ?? '',
                                                  style: TextStyle(
                                                    fontSize: maxWidth < 350 ? 16 : 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF7A45D1),
                                                    fontFamily: 'AntonSC',
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'FECHA: ${evento['fecha']?.toUpperCase() ?? ''}',
                                                  style: TextStyle(
                                                    fontSize: maxWidth < 350 ? 12 : 15,
                                                    color: Colors.grey[700], // <-- gris medio
                                                    fontWeight: FontWeight.w900,
                                                    fontFamily: 'AntonSC',
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'HORA: ${evento['hora']?.toUpperCase() ?? ''}',
                                                  style: TextStyle(
                                                    fontSize: maxWidth < 350 ? 12 : 15,
                                                    color: Colors.grey[700], // <-- gris medio
                                                    fontWeight: FontWeight.w900,
                                                    fontFamily: 'AntonSC',
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'LUGAR: ${evento['lugar']?.toUpperCase() ?? ''}',
                                                  style: TextStyle(
                                                    fontSize: maxWidth < 350 ? 12 : 15,
                                                    color: Colors.grey[700], // <-- gris medio
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
                                            width: maxWidth < 350 ? 50 : 70,
                                            height: maxWidth < 350 ? 50 : 70,
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
                          },
                        ),
                ),
              ),
            ],
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
                              _inputField('Hora', horaCtrl),
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