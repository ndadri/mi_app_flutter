import 'package:flutter/material.dart';

class StatButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function() onPressed;
  
  const StatButton({
    super.key, 
    required this.icon, 
    required this.label, 
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 400;
        
        return Container(
          margin: EdgeInsets.symmetric(vertical: isLargeScreen ? 10 : 8),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A45D1),
              foregroundColor: Colors.white,
              minimumSize: Size.fromHeight(isLargeScreen ? 70 : 60),
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 24 : 20,
                vertical: isLargeScreen ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 10),
              ),
              elevation: 3,
              shadowColor: const Color(0xFF7A45D1).withOpacity(0.3),
            ),
            icon: Icon(
              icon, 
              size: isLargeScreen ? 36 : 32,
            ),
            label: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AntonSC',
                fontWeight: FontWeight.bold,
                fontSize: isLargeScreen ? 20 : 18,
                letterSpacing: 0.5,
              ),
            ),
            onPressed: onPressed,
          ),
        );
      },
    );
  }
}
