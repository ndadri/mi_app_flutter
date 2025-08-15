import 'package:flutter/material.dart';
import 'stat_button.dart';
import 'stat_total_usuarios_action.dart';
import 'stat_usuarios_activos_action.dart';
import 'stat_usuarios_online_action.dart';
import 'stat_promedio_mascotas_usuario_action.dart';

class AdminStats extends StatelessWidget {
  const AdminStats({super.key});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar si es pantalla grande
        bool isLargeScreen = constraints.maxWidth > 600;
        bool isMediumScreen = constraints.maxWidth > 400;
        
        return Container(
          color: const Color(0xFFF8F9FA),
          child: Column(
            children: [
              // Header con "ESTADÍSTICAS" - sin altura fija para evitar overflow
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: isLargeScreen ? 40 : 32,
                  bottom: isLargeScreen ? 32 : 24,
                  left: 16,
                  right: 16,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7A45D1),
                      Color(0xFF9C27B0),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Center(
                  child: Text(
                    'ESTADÍSTICAS',
                    style: TextStyle(
                      fontFamily: 'AntonSC',
                      fontWeight: FontWeight.bold,
                      fontSize: isLargeScreen ? 42 : (isMediumScreen ? 38 : 32),
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              
              // Contenido principal con botones centrados y espaciado fijo
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 40 : 20,
                      vertical: isLargeScreen ? 40 : 30,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isLargeScreen ? 500 : 400,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatButton(
                            icon: Icons.groups,
                            label: 'TOTAL DE USUARIOS',
                            onPressed: () => totalUsuariosAction(context),
                            isLarge: isLargeScreen,
                          ),
                          SizedBox(height: isLargeScreen ? 20 : 16),
                          _buildStatButton(
                            icon: Icons.person,
                            label: 'USUARIOS ACTIVOS',
                            onPressed: () => usuariosActivosAction(context),
                            isLarge: isLargeScreen,
                          ),
                          SizedBox(height: isLargeScreen ? 20 : 16),
                          _buildStatButton(
                            icon: Icons.wifi,
                            label: 'USUARIOS ONLINE',
                            onPressed: () => usuariosOnlineAction(context),
                            isLarge: isLargeScreen,
                          ),
                          SizedBox(height: isLargeScreen ? 20 : 16),
                          _buildStatButton(
                            icon: Icons.show_chart,
                            label: 'PROMEDIO MASCOTAS/USUARIO',
                            onPressed: () => promedioMascotasUsuarioAction(context),
                            isLarge: isLargeScreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para construir botones de estadísticas responsive
  Widget _buildStatButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isLarge,
  }) {
    return SizedBox(
      width: double.infinity,
      height: isLarge ? 70 : 60,
      child: StatButton(
        icon: icon,
        label: label,
        onPressed: onPressed,
      ),
    );
  }
}
