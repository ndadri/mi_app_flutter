import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

void totalUsuariosAction(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF23243A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: FutureBuilder<int>(
        future: fetchTotalUsuarios(),
        builder: (context, snapshot) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 400;
          final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
          int? total = snapshot.data;
          return Container(
            width: isSmallScreen ? screenWidth * 0.85 : (isMediumScreen ? 340 : 380),
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 24 : 32,
              horizontal: isSmallScreen ? 20 : 28,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 10 : 12,
                      horizontal: isSmallScreen ? 16 : 24,
                    ),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups, 
                          color: Colors.white, 
                          size: isSmallScreen ? 28 : 32,
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Flexible(
                          child: Text(
                            'TOTAL DE USUARIOS',
                            style: TextStyle(
                              fontFamily: 'AntonSC',
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 16 : 20,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    CircularProgressIndicator(color: Color(0xFF7A45D1))
                  else if (snapshot.hasError)
                    Text(
                      'Error al cargar',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: isSmallScreen ? 18 : 22,
                      ),
                    )
                  else
                    Text(
                      total?.toString() ?? '-',
                      style: TextStyle(
                        fontFamily: 'AntonSC',
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 44 : 54,
                        color: Color(0xFF7A45D1),
                        letterSpacing: 2.0,
                      ),
                    ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Text(
                    'Usuarios registrados',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 28),
                  SizedBox(
                    width: double.infinity,
                    height: isSmallScreen ? 45 : 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A45D1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'CERRAR',
                        style: TextStyle(
                          fontFamily: 'AntonSC',
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
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

Future<int> fetchTotalUsuarios() async {
  try {
    print('Solicitando total de usuarios a: ${ApiConfig.baseUrl}/api/usuarios/total');
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/usuarios/total'));
    print('Código de respuesta: [33m${response.statusCode}[0m');
    print('Body: [36m${response.body}[0m');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Data decodificada: $data');
      return data['total'] ?? 0;
    } else {
      print('Error: código inesperado ${response.statusCode}');
      throw Exception('Error al obtener el total');
    }
  } catch (e) {
    print('Error en fetchTotalUsuarios: $e');
    throw Exception('Error de red');
  }
}
