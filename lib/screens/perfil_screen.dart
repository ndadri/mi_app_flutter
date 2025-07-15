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
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header morado
            Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF7A45D1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(top: 18, bottom: 24), // <-- Cambia aquí: agrega top: 18
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Flecha a la izquierda
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  // Título centrado
                  const Center(
                    child: Text(
                      'Perfil',
                      style: TextStyle(
                        fontFamily: 'AntonSC',
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                  child: const Text('Perfil Mascota'),
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
                  child: const Text('Perfil Usuario'),
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
                    ? const PerfilMascotaScreen()
                    : const PerfilUsuarioScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}