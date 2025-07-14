// Importación de los paquetes y pantallas necesarias
import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Pantalla de login
import 'screens/register_screen.dart'; // Pantalla de registro
import 'screens/home_screen.dart'; // Pantalla de inicio
import 'screens/pet_detail_screen.dart'; // Pantalla de detalles de la mascota
import 'screens/matches_screen.dart'; // Pantalla de matches
import 'screens/register_pet_screen.dart'; // Pantalla de registro de mascota

// Método principal que inicia la aplicación
void main() {
  runApp(const PetMatchApp()); // Llama a la app principal PetMatchApp
}

// Clase principal de la aplicación
class PetMatchApp extends StatelessWidget {
  const PetMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Match', // Título de la aplicación
      debugShowCheckedModeBanner: false, // Desactiva el banner de depuración en el app
      theme: ThemeData(
        fontFamily: 'Sans', // Establece la fuente de la aplicación
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Esquema de colores basado en un color semilla
        useMaterial3: true, // Habilita Material Design 3
      ),
      initialRoute: '/', // Establece la ruta inicial de la app
      routes: {
        '/': (context) => const LoginScreen(), // Ruta para la pantalla de login
        '/register': (context) => const RegisterScreen(), // Ruta para la pantalla de registro
        '/home': (context) => const HomeScreen(), // Ruta para la pantalla de inicio
        '/pet_detail': (context) => const PetDetailScreen(), // Ruta para la pantalla de detalles de la mascota
        '/register_pet': (context) => const RegisterPetScreen(), // Ruta para la pantalla de registro de mascota
        '/matches': (context) => const MatchesScreen(), // Ruta para la pantalla de matches
      },
    );
  }
}
