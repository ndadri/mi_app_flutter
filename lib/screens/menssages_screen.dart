import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessagesScreen extends StatefulWidget {
  final String matchId;
  final int? otherUserId; // ID del otro usuario para reportes

  const MessagesScreen({
    super.key, 
    required this.matchId,
    this.otherUserId,
  });

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Cargar los mensajes del match desde el backend
  void _loadMessages() async {
    final response = await http.get(Uri.parse('http://192.168.1.24:3004/api/match/${widget.matchId}/messages'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        messages = data.map((e) => Map<String, String>.from(e)).toList();
      });
    } else {
      // Manejar el error si no se cargan los mensajes
      print('Error al cargar mensajes');
    }
  }

  // Función para enviar reporte
  Future<void> _enviarReporte(String tipoReporte, String descripcion) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.24:3004/api/reportes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_reportador_id': 2, // Aquí deberías usar el ID del usuario actual
          'usuario_reportado_id': widget.otherUserId ?? 1,
          'tipo_reporte': tipoReporte,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reporte enviado correctamente'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al enviar el reporte'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error de conexión'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Función para mostrar el diálogo de reporte
  void _mostrarOpcionesReporte() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reportar Usuario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildOpcionReporte('fake_profile', 'Perfil falso', Icons.person_off),
              _buildOpcionReporte('inappropriate_content', 'Contenido inapropiado', Icons.warning),
              _buildOpcionReporte('offensive_language', 'Lenguaje ofensivo o insultos', Icons.record_voice_over),
              _buildOpcionReporte('harassment', 'Acoso o comportamiento no deseado', Icons.block),
              _buildOpcionReporte('animal_sales', 'Venta de Animales', Icons.pets),
              _buildOpcionReporte('dangerous_behavior', 'Comportamiento peligroso', Icons.dangerous),
              _buildOpcionReporte('spam', 'Publicidad o spam', Icons.campaign),
              _buildOpcionReporte('identity_theft', 'Suplantación de identidad', Icons.face),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para construir cada opción de reporte
  Widget _buildOpcionReporte(String tipo, String titulo, IconData icono) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _enviarReporte(tipo, 'Reporte de: $titulo\n\nDetalles del reporte enviado desde la aplicación.');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icono, color: Colors.red[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para enviar un nuevo mensaje
  void _sendMessage() async {
    final messageContent = _messageController.text;
    if (messageContent.isNotEmpty) {
      final message = {
        'sender': 'Luna', // Aquí debes obtener el nombre de la mascota o usuario
        'content': messageContent,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('http://192.168.1.24:3004/api/match/${widget.matchId}/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        setState(() {
          messages.add(message);
        });
        _messageController.clear();
      } else {
        // Manejar error al enviar el mensaje
        print('Error al enviar mensaje');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensajes"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'report') {
                _mostrarOpcionesReporte();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    const Text('Reportar usuario'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes del match
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message['sender']!),
                  subtitle: Text(message['content']!),
                  trailing: Text(message['timestamp']!),
                );
              },
            ),
          ),
          // Campo para escribir un nuevo mensaje
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
