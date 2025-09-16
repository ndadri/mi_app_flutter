import 'package:flutter/material.dart';

class PetMatchLogo extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  const PetMatchLogo({
    super.key,
    this.size = 120,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? Colors.pink.shade400;
    final secondary = secondaryColor ?? Colors.purple.shade300;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PetMatchLogoPainter(
          primaryColor: primary,
          secondaryColor: secondary,
        ),
      ),
    );
  }
}

class PetMatchLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  PetMatchLogoPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fondo del círculo
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, backgroundPaint);

    // Sombra del círculo
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawCircle(center.translate(0, 2), radius, shadowPaint);

    // Dibujar la cabeza del perro/gato (círculo principal)
    final headPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    final headRadius = radius * 0.6;
    canvas.drawCircle(center.translate(0, -radius * 0.1), headRadius, headPaint);

    // Dibujar las orejas
    final earPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Oreja izquierda
    final leftEarPath = Path()
      ..moveTo(center.dx - headRadius * 0.6, center.dy - radius * 0.4)
      ..quadraticBezierTo(
        center.dx - headRadius * 0.8,
        center.dy - radius * 0.8,
        center.dx - headRadius * 0.3,
        center.dy - radius * 0.6,
      )
      ..close();
    canvas.drawPath(leftEarPath, earPaint);

    // Oreja derecha
    final rightEarPath = Path()
      ..moveTo(center.dx + headRadius * 0.6, center.dy - radius * 0.4)
      ..quadraticBezierTo(
        center.dx + headRadius * 0.8,
        center.dy - radius * 0.8,
        center.dx + headRadius * 0.3,
        center.dy - radius * 0.6,
      )
      ..close();
    canvas.drawPath(rightEarPath, earPaint);

    // Dibujar los ojos
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Ojo izquierdo
    final leftEye = Offset(center.dx - headRadius * 0.3, center.dy - radius * 0.2);
    canvas.drawCircle(leftEye, headRadius * 0.15, eyePaint);
    canvas.drawCircle(leftEye.translate(headRadius * 0.05, 0), headRadius * 0.08, pupilPaint);

    // Ojo derecho
    final rightEye = Offset(center.dx + headRadius * 0.3, center.dy - radius * 0.2);
    canvas.drawCircle(rightEye, headRadius * 0.15, eyePaint);
    canvas.drawCircle(rightEye.translate(-headRadius * 0.05, 0), headRadius * 0.08, pupilPaint);

    // Dibujar la nariz
    final nosePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final nosePath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.05)
      ..lineTo(center.dx - headRadius * 0.08, center.dy + radius * 0.15)
      ..lineTo(center.dx + headRadius * 0.08, center.dy + radius * 0.15)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // Dibujar la boca
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.15)
      ..quadraticBezierTo(
        center.dx - headRadius * 0.15,
        center.dy + radius * 0.25,
        center.dx - headRadius * 0.25,
        center.dy + radius * 0.2,
      );
    canvas.drawPath(mouthPath, mouthPaint);

    final mouthPath2 = Path()
      ..moveTo(center.dx, center.dy + radius * 0.15)
      ..quadraticBezierTo(
        center.dx + headRadius * 0.15,
        center.dy + radius * 0.25,
        center.dx + headRadius * 0.25,
        center.dy + radius * 0.2,
      );
    canvas.drawPath(mouthPath2, mouthPaint);

    // Dibujar el corazón flotante
    final heartPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final heartCenter = Offset(center.dx + radius * 0.6, center.dy - radius * 0.6);
    _drawHeart(canvas, heartCenter, radius * 0.15, heartPaint);

    // Dibujar las patas (círculos pequeños en la parte inferior)
    final pawPaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Pata izquierda
    canvas.drawCircle(
      Offset(center.dx - radius * 0.4, center.dy + radius * 0.7),
      radius * 0.12,
      pawPaint,
    );

    // Pata derecha
    canvas.drawCircle(
      Offset(center.dx + radius * 0.4, center.dy + radius * 0.7),
      radius * 0.12,
      pawPaint,
    );
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    path.moveTo(center.dx, center.dy + size * 0.3);
    
    // Lado izquierdo del corazón
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.2,
      center.dx - size * 0.8, center.dy - size * 0.8,
      center.dx - size * 0.3, center.dy - size * 0.8,
    );
    
    // Parte superior izquierda
    path.cubicTo(
      center.dx - size * 0.1, center.dy - size * 0.9,
      center.dx + size * 0.1, center.dy - size * 0.9,
      center.dx + size * 0.3, center.dy - size * 0.8,
    );
    
    // Lado derecho del corazón
    path.cubicTo(
      center.dx + size * 0.8, center.dy - size * 0.8,
      center.dx + size * 0.5, center.dy - size * 0.2,
      center.dx, center.dy + size * 0.3,
    );
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
