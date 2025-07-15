import 'package:flutter/material.dart';

class PerfilMascotaScreen extends StatelessWidget {
  const PerfilMascotaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Foto de la mascota
        CircleAvatar(
          radius: 54,
          backgroundImage: const NetworkImage(
            'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg',
          ),
        ),
        const SizedBox(height: 18),
        _profileField('Nombre', 'Luna'),
        _profileField('Edad', '2 años'),
        _profileField('Tipo de animal', 'Perro'),
        _profileField('Sexo', 'Hembra'),
        _profileField('Ciudad', 'Quito'),
        _profileField('Estado', 'Disponible'),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A45D1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            // Lógica para editar perfil de mascota
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

class CustomTextStyle {
  static TextStyle get header => const TextStyle(
        fontFamily: 'AntonSC',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.5,
      );
}