import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _generoController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _registerUser() async {
    final String nombres = _nombresController.text;
    final String apellidos = _apellidosController.text;
    final String correo = _correoController.text;
    final String contrasena = _contrasenaController.text;
    final String genero = _generoController.text;
    final String ubicacion = _ubicacionController.text;
    final String fechaNacimiento = _fechaNacimientoController.text;

    if (nombres.isEmpty ||
        apellidos.isEmpty ||
        correo.isEmpty ||
        contrasena.isEmpty ||
        genero.isEmpty ||
        ubicacion.isEmpty ||
        fechaNacimiento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    final userData = jsonEncode({
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'contraseña': contrasena,
      'genero': genero,
      'ubicacion': ubicacion,
      'fecha_nacimiento': fechaNacimiento,
    });

    final response = await http.post(
      Uri.parse('http://localhost:8080/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: userData,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar el usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombresController,
                decoration: const InputDecoration(labelText: 'Nombres'),
              ),
              TextField(
                controller: _apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
              ),
              TextField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
              ),
              TextField(
                controller: _contrasenaController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              TextField(
                controller: _generoController,
                decoration: const InputDecoration(labelText: 'Género'),
              ),
              TextField(
                controller: _ubicacionController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
              TextField(
                controller: _fechaNacimientoController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}