import 'package:flutter/material.dart';

class ProfileLabel extends StatelessWidget {
  final String text;
  const ProfileLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'AntonSC',
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.black,
      ),
    );
  }
}
