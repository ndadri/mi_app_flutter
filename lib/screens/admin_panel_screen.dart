import 'package:flutter/material.dart';
import 'admin_users.dart';
import 'admin_stats.dart';
import 'admin_reports.dart';
import 'admin_profile.dart';

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
        body: AdminWelcomeFullScreen(),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      AdminStats(),
                      // AdminUsers ya no puede ser const porque es StatefulWidget
                      AdminUsers(),
                      AdminReports(),
                      AdminProfile(),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
            // Custom bottom bar with curves
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: TabBar(
                  controller: _tabController,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 3, color: Color(0xFF7A45D1)),
                    insets: EdgeInsets.symmetric(horizontal: 24),
                  ),
                  labelColor: const Color(0xFF7A45D1),
                  unselectedLabelColor: Colors.black45,
                  labelStyle: const TextStyle(
                    fontFamily: 'AntonSC',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'AntonSC',
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.bar_chart, size: 28),
                      text: 'ESTADÍSTICA',
                    ),
                    Tab(
                      icon: Icon(Icons.group, size: 28),
                      text: 'USUARIOS',
                    ),
                    Tab(
                      icon: Icon(Icons.report, size: 28),
                      text: 'REPORTES',
                    ),
                    Tab(
                      icon: Icon(Icons.admin_panel_settings, size: 28),
                      text: 'PERFIL',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Pantalla de bienvenida fullscreen
class AdminWelcomeFullScreen extends StatelessWidget {
  const AdminWelcomeFullScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF7A45D1),
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: Text(
          'BIENVENIDO\nADMINISTRADOR',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'AntonSC',
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

