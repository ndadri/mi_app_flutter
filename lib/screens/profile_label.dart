import 'package:flutter/material.dart';

class ProfileLabel extends StatelessWidget {
  final String text;
  const ProfileLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'AntonSC',
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black,
        letterSpacing: 0.5,
      ),
    );
  }
}
