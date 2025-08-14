import 'package:flutter/material.dart';

void promedioMascotasUsuarioAction(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF23243A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = MediaQuery.of(context).size.width * 0.92;
          final double dialogWidth = maxWidth < 360 ? maxWidth : 360;
          final double horizontalPad = dialogWidth < 340 ? 12 : 28;
          return SingleChildScrollView(
            child: Container(
              width: dialogWidth,
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: horizontalPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A45D1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.show_chart, color: Colors.white, size: 32),
                        SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            'PROMEDIO MASCOTAS/USUARIO',
                            style: TextStyle(
                              fontFamily: 'AntonSC',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Promedio grande
                  const Text(
                    '2.7', // Valor ejemplo
                    style: TextStyle(
                      fontFamily: 'AntonSC',
                      fontWeight: FontWeight.bold,
                      fontSize: 54,
                      color: Color(0xFF7A45D1),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mascotas por usuario',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Placeholder para gráfico
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF292B45),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Gráfico próximamente',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A45D1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'CERRAR',
                        style: TextStyle(
                          fontFamily: 'AntonSC',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}


