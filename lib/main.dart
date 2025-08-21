// Importación de los paquetes y pantallas necesarias
import 'package:flutter/material.dart';
// Firebase habilitado para usar con Google Sign-In
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart'; // Pantalla de splash animada
import 'screens/login_screen.dart'; // Pantalla de login
import 'screens/register_screen.dart'; // Pantalla de registro
import 'screens/home_screen.dart'; // Pantalla de inicio
import 'screens/pet_detail_screen.dart'; // Pantalla de detalles de la mascota
import 'screens/matches_screen.dart'; // Pantalla de matches
import 'screens/perfil_screen.dart'; // Pantalla de perfil
import 'screens/eventos_screen.dart'; // Pantalla de eventos
import 'screens/admin_panel_screen.dart'; // Panel administrativo
import 'screens/dates_screen.dart'; // Pantalla de citas

// Método principal que inicia la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Requerido para plugins
  // Firebase habilitado para Google Sign-In
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PetMatchApp()); // Ejecuta la app
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
        fontFamily: 'AntonSC', // <-- Aquí
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Esquema de colores basado en un color semilla
        useMaterial3: true, // Habilita Material Design 3
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(fontFamily: 'AntonSC'),
          unselectedLabelStyle: TextStyle(fontFamily: 'AntonSC'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontFamily: 'AntonSC'),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontFamily: 'AntonSC'),
          ),
        ),
      ),
      initialRoute: '/', // Establece la ruta inicial de la app (splash screen)
      routes: {
        '/': (context) => const SplashScreen(), // Pantalla de splash inicial
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/pet_detail': (context) => const PetDetailScreen(),
        '/matches': (context) => const MatchesScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/eventos': (context) => const EventosScreen(),
        '/dates': (context) => const DatesScreen(), // Nueva ruta para citas
        '/admin': (context) => const AdminPanelScreen(), // Panel administrativo
      },
    );
  }
}
