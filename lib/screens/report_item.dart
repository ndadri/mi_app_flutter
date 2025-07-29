import 'package:flutter/material.dart';

class ReportItem extends StatelessWidget {
  const ReportItem();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Reportado: Mia',
                  style: TextStyle(
                    fontFamily: 'AntonSC',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF7A45D1),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Reportante: Lucy',
                  style: TextStyle(
                    fontFamily: 'AntonSC',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tipo de reporte: Ofensivo',
                  style: TextStyle(
                    fontFamily: 'AntonSC',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Motivo: Perfil Falso',
                  style: TextStyle(
                    fontFamily: 'AntonSC',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Detalles: perfiles de estafas usados para dañar a la comunidad Petmatch',
                  style: TextStyle(
                    fontFamily: 'AntonSC',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Fecha: 2025-07-25 T9:30:32.238Z',
                  style: TextStyle(
                    fontFamily: 'AntonSC',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Recuadro a la derecha con el icono
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.info, color: Colors.black54, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}
