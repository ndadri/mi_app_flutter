import 'package:flutter/material.dart';

void usuariosActivosAction(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF23243A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isSmallScreen = screenWidth < 400;
          final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
          
          return Container(
            width: isSmallScreen ? screenWidth * 0.85 : (isMediumScreen ? 340 : 380),
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.9,
              maxHeight: screenHeight * 0.85,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 20 : 28,
                horizontal: isSmallScreen ? 16 : 24,
              ),
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
                          Icons.person, 
                          color: Colors.white, 
                          size: isSmallScreen ? 28 : 32,
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Flexible(
                          child: Text(
                            'USUARIOS ACTIVOS',
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
                  SizedBox(height: isSmallScreen ? 20 : 28),
                  Text(
                    '1,120',
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
                    'Usuarios activos ahora',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  
                  // Sección de usuarios inactivos
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1B2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility_off,
                              color: Colors.white60,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Flexible(
                              child: Text(
                                'USUARIOS INACTIVOS',
                                style: TextStyle(
                                  fontFamily: 'AntonSC',
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Colors.white60,
                                  letterSpacing: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          '2,130',
                          style: TextStyle(
                            fontFamily: 'AntonSC',
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 36 : 44,
                            color: Colors.white60,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Text(
                          'Usuarios inactivos',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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