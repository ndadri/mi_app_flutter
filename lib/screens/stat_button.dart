import 'package:flutter/material.dart';

class StatButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function() onPressed;
  const StatButton({super.key, required this.icon, required this.label, required this.onPressed});
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
        onPressed: onPressed,
      ),
    );
  }
}
