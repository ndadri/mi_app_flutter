import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessagesScreen extends StatefulWidget {
  final String matchId;

  const MessagesScreen({super.key, required this.matchId});

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
    final response = await http.get(Uri.parse('http://localhost:8080/api/match/${widget.matchId}/messages'));

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
        Uri.parse('http://localhost:8080/api/match/${widget.matchId}/messages'),
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
      appBar: AppBar(title: const Text("Mensajes")),
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
