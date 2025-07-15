import 'package:flutter/material.dart';

class PerfilUsuarioScreen extends StatelessWidget {
  const PerfilUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Foto del usuario
        CircleAvatar(
          radius: 54,
          backgroundImage: const NetworkImage(
            'https://randomuser.me/api/portraits/men/1.jpg',
          ),
        ),
        const SizedBox(height: 18),
        _profileField('Nombres', 'Juan'),
        _profileField('Apellidos', 'Pérez'),
        _profileField('Género', 'Masculino'),
        _profileField('Ubicación', 'Quito'),
        _profileField('Fecha de nacimiento', '12/05/1995'),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A45D1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            // Lógica para editar perfil de usuario
          },
          icon: const Icon(Icons.edit),
          label: const Text('Editar datos'),
        ),
      ],
    );
  }

  Widget _profileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Perfil de Usuario'),
      centerTitle: true,
      backgroundColor: const Color(0xFF7A45D1),
      elevation: 4,
      titleTextStyle: const TextStyle(
        fontFamily: 'AntonSC',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.5,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}