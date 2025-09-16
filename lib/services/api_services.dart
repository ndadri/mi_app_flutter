
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class ApiService {
  // Usa la baseUrl centralizada
  Future<List<dynamic>> fetchPets() async {
  final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/pets'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar las mascotas');
    }
  }

  // Función para crear una mascota
  Future<void> createPet(Map<String, dynamic> petData) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/pet'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(petData),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al crear la mascota');
    }
  }
}
