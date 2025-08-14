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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;
    const double headerHeight = 90; // Altura fija en px para el header
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // headerFontSize variable removed (not used)
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header unificado (ocupa todo el tope)
          Container(
            height: headerHeight + statusBarHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF7A45D1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: statusBarHeight + 10), // Puedes ajustar este número para mover el texto
              child: const Text(
                'EVENTOS',
                style: TextStyle(
                  fontFamily: 'AntonSC',
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
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
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'AntonSC',
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'HORA: ${evento['hora']?.toUpperCase() ?? ''}',
                                              style: TextStyle(
                                                fontSize: maxWidth < 350 ? 12 : 15,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'AntonSC',
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'LUGAR: ${evento['lugar']?.toUpperCase() ?? ''}',
                                              style: TextStyle(
                                                fontSize: maxWidth < 350 ? 12 : 15,
                                                color: Colors.grey[700],
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
      // Barra de navegación inferior igual a home_screen
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final isDesktop = constraints.maxWidth >= 1024;
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
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
                backgroundColor: Colors.transparent,
                elevation: 0,
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
                currentIndex: 2,
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
                    Navigator.pushNamedAndRemoveUntil(context, '/matches', (route) => false);
                  } else if (index == 1) {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  } else if (index == 2) {
                    Navigator.pushNamedAndRemoveUntil(context, '/eventos', (route) => false);
                  } else if (index == 3) {
                    Navigator.pushNamedAndRemoveUntil(context, '/perfil', (route) => false);
                  }
                },
              ),
            ),
          );
        },
      ),
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