import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestConexionPage extends StatefulWidget {
  const TestConexionPage({super.key});

  @override
  State<TestConexionPage> createState() => _TestConexionPageState();
}

class _TestConexionPageState extends State<TestConexionPage> {
  List<dynamic> mascotas = [];
  String? error;

  @override
  void initState() {
    super.initState();
    obtenerMascotas();
  }

  Future<void> obtenerMascotas() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/pets'));

      if (response.statusCode == 200) {
        setState(() {
          mascotas = jsonDecode(response.body);
        });
      } else {
        setState(() {
          error = 'Error al obtener mascotas: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de Conexión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: error != null
            ? Text(error!, style: const TextStyle(color: Colors.red))
            : mascotas.isEmpty
                ? const CircularProgressIndicator()
                : ListView.builder(
                    itemCount: mascotas.length,
                    itemBuilder: (context, index) {
                      final m = mascotas[index];
                      return ListTile(
                        title: Text('${m['name']}'),
                        subtitle: Text('Tipo: ${m['type']} - Edad: ${m['age']}'),
                      );
                    },
                  ),
      ),
    );
  }
}
