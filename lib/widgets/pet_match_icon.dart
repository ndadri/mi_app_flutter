import 'package:flutter/material.dart';

class PetMatchIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const PetMatchIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PetMatchIconPainter(
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class PetMatchIconPainter extends CustomPainter {
  final Color color;

  PetMatchIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Dibujar la silueta de una mascota con corazón
    final path = Path();
    
    // Cabeza (círculo principal)
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx, center.dy - size.height * 0.1),
      radius: size.width * 0.3,
    ));
    
    // Orejas
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.3),
      radius: size.width * 0.1,
    ));
    
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx + size.width * 0.2, center.dy - size.height * 0.3),
      radius: size.width * 0.1,
    ));
    
    canvas.drawPath(path, paint);
    
    // Dibujar corazón pequeño
    final heartPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    _drawMiniHeart(
      canvas, 
      Offset(center.dx + size.width * 0.3, center.dy - size.height * 0.3),
      size.width * 0.08,
      heartPaint,
    );
  }

  void _drawMiniHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    path.moveTo(center.dx, center.dy + size * 0.3);
    
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.1,
      center.dx - size * 0.7, center.dy - size * 0.7,
      center.dx - size * 0.2, center.dy - size * 0.7,
    );
    
    path.cubicTo(
      center.dx - size * 0.05, center.dy - size * 0.8,
      center.dx + size * 0.05, center.dy - size * 0.8,
      center.dx + size * 0.2, center.dy - size * 0.7,
    );
    
    path.cubicTo(
      center.dx + size * 0.7, center.dy - size * 0.7,
      center.dx + size * 0.5, center.dy - size * 0.1,
      center.dx, center.dy + size * 0.3,
    );
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
