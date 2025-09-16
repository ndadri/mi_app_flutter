import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/evento_service.dart';
import '../services/session_manager.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  List<Map<String, dynamic>> eventos = [];
  bool isLoading = true;

  // Controla si se muestra el modal de añadir evento
  bool showAddEventDialog = false;

  // Controladores para los campos del nuevo evento
  final TextEditingController tituloCtrl = TextEditingController();
  final TextEditingController fechaCtrl = TextEditingController();
  final TextEditingController horaCtrl = TextEditingController(); 
  final TextEditingController lugarCtrl = TextEditingController();
  
  // Variables para manejo de imágenes
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  @override
  void dispose() {
    tituloCtrl.dispose();
    fechaCtrl.dispose();
    horaCtrl.dispose();
    lugarCtrl.dispose();
    super.dispose();
  }

  // Cargar eventos desde la base de datos
  Future<void> _cargarEventos() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      // Reducido timeout a 5 segundos para carga más rápida
      final resultado = await EventoService.obtenerEventos()
          .timeout(const Duration(seconds: 5));
      
      if (mounted) {
        if (resultado['success']) {
          setState(() {
            eventos = List<Map<String, dynamic>>.from(resultado['eventos'] ?? []);
            isLoading = false;
          });
          
          // Mostrar snackbar de éxito solo si hay eventos
          if (eventos.isNotEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${eventos.length} eventos cargados'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() {
            // Si hay datos en cache, mantenerlos
            if (resultado['fromCache'] != true) {
              eventos = [];
            }
            isLoading = false;
          });
          
          // Verificar si debe hacer logout usando SessionManager
          final shouldLogout = resultado['shouldLogout'] == true;
          if (shouldLogout) {
            await SessionManager.handleError(
              context, 
              resultado['statusCode'], 
              resultado['message']
            );
            return; // No continuar con el manejo de UI si se hizo logout
          }
          
          // Manejar diferentes tipos de error
          String message = resultado['message'] ?? 'Error al cargar eventos';
          Color backgroundColor = Colors.orange;
          
          // Si es un error de servidor pero tenemos cache, mostrar advertencia suave
          if (resultado['warning'] != null) {
            message = resultado['warning'];
            backgroundColor = Colors.blue;
          } else if (resultado['statusCode'] == 500) {
            message = 'Error temporal del servidor. Los datos pueden estar desactualizados.';
            backgroundColor = Colors.amber;
          }
          
          // No mostrar error si simplemente no hay eventos o si tenemos datos de cache
          bool showError = !message.toLowerCase().contains('no hay eventos') && 
                           resultado['fromCache'] != true;
          
          if (showError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: backgroundColor,
                duration: Duration(seconds: resultado['canRetry'] == true ? 4 : 3),
                action: resultado['canRetry'] == true ? SnackBarAction(
                  label: 'Reintentar',
                  textColor: Colors.white,
                  onPressed: () => _cargarEventos(),
                ) : null,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          eventos = [];
          isLoading = false;
        });
        
        // Mensaje de error más específico
        String errorMessage = 'Error de conexión. Verifica tu internet.';
        if (e.toString().contains('TimeoutException')) {
          errorMessage = 'La conexión está lenta. Reintentando...';
          // Auto-reintentar una vez en caso de timeout
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) _cargarEventos();
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _cargarEventos(),
            ),
          ),
        );
      }
    }
  }

  void openAddEventDialog() {
    setState(() {
      showAddEventDialog = true;
      tituloCtrl.clear();
      fechaCtrl.clear();
      horaCtrl.clear();
      lugarCtrl.clear();
      _selectedImage = null;
    });
    _showAddEventModal();
  }

  // Función para seleccionar imagen de la galería
  Future<void> _selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  // Función para mostrar diálogo de asistencia al evento
  void _showAttendanceDialog(int index) {
    final evento = eventos[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            evento['nombre'],
            style: const TextStyle(
              fontFamily: 'AntonSC',
              fontWeight: FontWeight.bold,
              color: Color(0xFF7A45D1),
            ),
          ),
          content: const Text(
            '¿Vas a asistir a este evento?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _marcarAsistencia(evento['id'], false);
              },
              child: const Text(
                'NO VOY',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _marcarAsistencia(evento['id'], true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A45D1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'SÍ VOY',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Marcar asistencia en la base de datos
  Future<void> _marcarAsistencia(int eventoId, bool asistira) async {
    try {
      final resultado = await EventoService.marcarAsistencia(
        eventoId: eventoId,
        asistira: asistira,
      );

      if (resultado['success']) {
        // Recargar eventos para actualizar el estado
        await _cargarEventos();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(asistira 
                ? '¡Confirmado! Vas a asistir al evento' 
                : 'Marcado como "No voy a asistir"'),
              backgroundColor: asistira ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message'] ?? 'Error al marcar asistencia'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> confirmAddEvent() async {
    if (tituloCtrl.text.trim().isEmpty ||
        fechaCtrl.text.trim().isEmpty ||
        horaCtrl.text.trim().isEmpty ||
        lugarCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final resultado = await EventoService.crearEvento(
        nombre: tituloCtrl.text.trim(),
        fecha: fechaCtrl.text.trim(),
        hora: horaCtrl.text.trim(),
        lugar: lugarCtrl.text.trim(),
        imagen: _selectedImage,
      );

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      if (resultado['success']) {
        setState(() {
          showAddEventDialog = false;
          _selectedImage = null;
        });
        
        // Cerrar modal
        if (mounted) Navigator.of(context).pop();
        
        // Recargar eventos
        await _cargarEventos();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Evento creado exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message'] ?? 'Error al crear evento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Modal para agregar evento
  void _showAddEventModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'AGREGAR EVENTO',
                style: TextStyle(
                  fontFamily: 'AntonSC',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A45D1),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _inputField('Nombre del evento', tituloCtrl),
                    _inputField('Fecha (DD/MM/YYYY)', fechaCtrl),
                    _inputField('Hora (HH:MM)', horaCtrl),
                    _inputField('Lugar', lugarCtrl),
                    const SizedBox(height: 16),
                    // Sección para imagen
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setStateModal(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await _selectImage();
                                    setStateModal(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7A45D1),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Seleccionar Imagen'),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      showAddEventDialog = false;
                      _selectedImage = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: confirmAddEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A45D1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'AGREGAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 90;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

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
              padding: EdgeInsets.only(top: statusBarHeight + 10),
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
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando eventos...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : eventos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '¡No hay eventos disponibles!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sé el primero en crear un evento\npara la comunidad PetMatch',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: openAddEventDialog,
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text(
                                  'Crear Primer Evento',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E63),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                            ],
                          ),
                        )
                  : RefreshIndicator(
                      onRefresh: _cargarEventos,
                      color: const Color(0xFFE91E63),
                      child: ListView.builder(
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
                                child: GestureDetector(
                                  onTap: () => _showAttendanceDialog(index),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: (evento['asistira'] != null && evento['asistira'] == true)
                                          ? Border.all(color: Colors.green, width: 3)
                                          : Border.all(color: Colors.transparent),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Row(
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
                                                        image: NetworkImage('http://192.168.1.24:3004${evento['imagen']}'),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: evento['imagen'] == null
                                                  ? Icon(
                                                      Icons.event,
                                                      color: Colors.grey[600],
                                                      size: maxWidth < 350 ? 24 : 32,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                        // Indicador de asistencia
                                        if (evento['asistira'] != null && evento['asistira'] == true)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
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
          ),
        ],
      ),
      floatingActionButton: eventos.isNotEmpty ? FloatingActionButton(
        backgroundColor: const Color(0xFF7A45D1),
        foregroundColor: Colors.white,
        onPressed: openAddEventDialog,
        child: const Icon(Icons.add, size: 32),
      ) : null,
      floatingActionButtonLocation: eventos.isNotEmpty ? FloatingActionButtonLocation.endFloat : null,
      // Barra de navegación inferior
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
                    Navigator.pushReplacementNamed(context, '/matches');
                  } else if (index == 1) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else if (index == 2) {
                    // Ya estamos en eventos
                  } else if (index == 3) {
                    Navigator.pushReplacementNamed(context, '/perfil');
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