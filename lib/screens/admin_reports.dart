import 'package:flutter/material.dart';
import 'report_item.dart';

class AdminReports extends StatelessWidget {
  const AdminReports({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          // Barra de búsqueda sin título
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar Usuario',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF7A45D1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF7A45D1)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // Lista de reportes
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                ReportItem(),
                ReportItem(),
                ReportItem(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
