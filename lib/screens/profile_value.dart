import 'package:flutter/material.dart';

class ProfileValue extends StatelessWidget {
  final String text;
  const ProfileValue(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'AntonSC',
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: Colors.black,
        letterSpacing: 0.2,
      ),
    );
  }
}
