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
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 32, bottom: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF7A45D1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: const Center(
              child: Text(
                'ESTADÍSTICAS',
                style: TextStyle(
                  fontFamily: 'AntonSC',
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 170),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: SizedBox(
                    width: 340,
                    child: StatButton(
                      icon: Icons.groups,
                      label: 'TOTAL DE USUARIOS',
                      onPressed: () => totalUsuariosAction(context),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 340,
                    child: StatButton(
                      icon: Icons.person,
                      label: 'USUARIOS ACTIVOS',
                      onPressed: () => usuariosActivosAction(context),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 340,
                    child: StatButton(
                      icon: Icons.wifi,
                      label: 'USUARIOS ONLINE',
                      onPressed: () => usuariosOnlineAction(context),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 340,
                    child: StatButton(
                      icon: Icons.show_chart,
                      label: 'PROMEDIO MASCOTAS/USUARIO',
                      onPressed: () => promedioMascotasUsuarioAction(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// StatButton ahora está en stat_button.dart y acepta onPressed
