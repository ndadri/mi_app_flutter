import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PetListScreen extends StatefulWidget {
  @override
  _PetListScreenState createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  List<dynamic> _pets = [];

  // Función para obtener las mascotas del backend
  Future<void> _getPets() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/pets'));

    if (response.statusCode == 200) {
      setState(() {
        _pets = jsonDecode(response.body);
      });
    } else {
      // Si hay error, muestra un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las mascotas')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getPets();  // Cargar las mascotas cuando la pantalla se carga
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Mascotas'),
      ),
      body: ListView.builder(
        itemCount: _pets.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_pets[index]['name']),
            subtitle: Text('${_pets[index]['type']} - ${_pets[index]['age']} años'),
          );
        },
      ),
    );
  }
}
