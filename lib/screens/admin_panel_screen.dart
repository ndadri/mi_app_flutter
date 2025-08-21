import 'package:flutter/material.dart';
import 'admin_users.dart';
import 'admin_reports.dart';
import 'admin_profile.dart';
import 'stat_button.dart';
import 'stat_total_usuarios_action.dart';
import 'stat_usuarios_activos_action.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showWelcome = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcome) {
      return const Scaffold(
        resizeToAvoidBottomInset: false, // Evita overflow con teclado
        body: AdminWelcomeFullScreen(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Header que cubre perfectamente el título
              Container(
                height: MediaQuery.of(context).size.height * 0.22, // Reducido para cubrir solo el título
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF7A45D1),
                      Color(0xFF9C27B0),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 15), // Fondo morado desde arriba completo
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        SizedBox(height: MediaQuery.of(context).padding.top + 35), // Espacio para mantener título en posición
                        // Header superior con ícono y título
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Panel Administrativo',
                                    style: TextStyle(
                                      fontFamily: 'AntonSC',
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Gestiona tu aplicación Pet Match',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ),
              
              // Contenido principal sin títulos
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    AdminStatsContent(), // Nueva versión sin título
                    AdminUsers(),
                    AdminReports(),
                    PerfilUsuarioScreen(),
                  ],
                ),
              ),
              
              // Navegación inferior sin overflow
              SafeArea(
                top: false,
                child: Container(
                  height: 80, // Reducido para evitar overflow
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Reducido
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          icon: Icons.analytics,
                          label: 'Estadísticas',
                          index: 0,
                          isSelected: _tabController.index == 0,
                        ),
                        _buildNavItem(
                          icon: Icons.people,
                          label: 'Usuarios',
                          index: 1,
                          isSelected: _tabController.index == 1,
                        ),
                        _buildNavItem(
                          icon: Icons.report_problem,
                          label: 'Reportes',
                          index: 2,
                          isSelected: _tabController.index == 2,
                        ),
                        _buildNavItem(
                          icon: Icons.person,
                          label: 'Perfil',
                          index: 3,
                          isSelected: _tabController.index == 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget para construir cada elemento de navegación
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {}); // Actualizar el título
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7A45D1) : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF7A45D1) : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}


// Pantalla de bienvenida fullscreen mejorada
class AdminWelcomeFullScreen extends StatelessWidget {
  const AdminWelcomeFullScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7A45D1),
            Color(0xFF9C27B0),
            Color(0xFFE91E63),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono animado
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Texto principal
                const Text(
                  'BIENVENIDO',
                  textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AntonSC',
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ADMINISTRADOR',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'AntonSC',
                fontWeight: FontWeight.w600,
                fontSize: 28,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Descripción
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Text(
                'Panel de control para gestionar usuarios, revisar estadísticas y administrar reportes de Pet Match',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Indicador de carga
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Cargando panel...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Clase para el contenido de estadísticas sin título
class AdminStatsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30), // Más padding horizontal
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350), // Ancho máximo reducido
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatButton(
                  icon: Icons.groups,
                  label: 'TOTAL DE USUARIOS',
                  onPressed: () => totalUsuariosAction(context),
                ),
                const SizedBox(height: 16),
                _buildStatButton(
                  icon: Icons.person,
                  label: 'USUARIOS ACTIVOS',
                  onPressed: () => usuariosActivosAction(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 70, // Aumentado de 60 a 70 para más altura
      child: StatButton(
        icon: icon,
        label: label,
        onPressed: onPressed,
      ),
    );
  }
}
