import 'package:flutter/material.dart';

class AdminStats extends StatelessWidget {
  const AdminStats();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 32, bottom: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF7A45D1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: const Center(
              child: Text(
                'ESTADÍSTICAS',
                style: TextStyle(
                  fontFamily: 'AntonSC',
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 170),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Center(child: SizedBox(width: 340, child: StatButton(icon: Icons.groups, label: 'TOTAL DE USUARIOS'))),
                Center(child: SizedBox(width: 340, child: StatButton(icon: Icons.person, label: 'USUARIOS ACTIVOS'))),
                Center(child: SizedBox(width: 340, child: StatButton(icon: Icons.wifi, label: 'USUARIOS ONLINE'))),
                Center(child: SizedBox(width: 340, child: StatButton(icon: Icons.show_chart, label: 'PROMEDIO MASCOTAS/USUARIO'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const StatButton({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7A45D1),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon, size: 32),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'AntonSC',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}
