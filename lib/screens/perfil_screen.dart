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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF7A45D1),
            expandedHeight: MediaQuery.of(context).size.width < 400 ? 70 : 90,
            automaticallyImplyLeading: false, // <-- Esto oculta la flecha siempre
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.only(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).size.width < 400 ? 10 : 16,
              ),
              title: Text(
                'Perfil',
                style: TextStyle(
                  fontFamily: 'AntonSC',
                  fontSize: MediaQuery.of(context).size.width < 400 ? 22 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
          ),
          SliverToBoxAdapter(
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}