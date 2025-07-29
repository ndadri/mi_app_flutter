import 'package:flutter/material.dart';

class ProfileValue extends StatelessWidget {
  final String text;
  const ProfileValue(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'AntonSC',
        fontWeight: FontWeight.normal,
        fontSize: 15,
        color: Colors.black,
      ),
    );
  }
}
