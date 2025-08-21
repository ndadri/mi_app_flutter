import 'package:flutter/material.dart';
import 'perfil_mascota_screen.dart';
import 'perfil_usuario_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool showPetProfile = true;

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
              padding: EdgeInsets.only(top: statusBarHeight + 12), // 12 para separar el texto del borde
              child: const Text(
                'PERFIL',
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
          // Contenido principal scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Botones para cambiar entre perfiles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: showPetProfile ? const Color(0xFF7A45D1) : Colors.white,
                          foregroundColor: showPetProfile ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => setState(() => showPetProfile = true),
                        child: const Text('PERFIL MASCOTA'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !showPetProfile ? const Color(0xFF7A45D1) : Colors.white,
                          foregroundColor: !showPetProfile ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => setState(() => showPetProfile = false),
                        child: const Text('PERFIL USUARIO'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Card de perfil
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                      child: showPetProfile
                          ? PerfilMascotaScreen()
                          : PerfilUsuarioScreen(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
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
                currentIndex: 3,
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
                    Navigator.pushReplacementNamed(context, '/eventos');
                  } else if (index == 3) {
                    // Ya estamos en perfil
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}