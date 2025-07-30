import 'package:flutter/material.dart';

import 'edit_admin_profile_dialog.dart';
import 'profile_label.dart';
import 'profile_value.dart';


class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});
  @override
  State<AdminProfile> createState() => AdminProfileState();
}

class AdminProfileState extends State<AdminProfile> {
  String nombres = 'Juan';
  String apellidos = 'Pérez';
  String genero = 'Masculino';
  String ubicacion = 'Quito';
  String fechaNacimiento = '12/05/1995';

  void _editarDatos() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => EditAdminProfileDialog(
        nombres: nombres,
        apellidos: apellidos,
        genero: genero,
        ubicacion: ubicacion,
        fechaNacimiento: fechaNacimiento,
      ),
    );
    if (result != null) {
      setState(() {
        nombres = result['nombres'] ?? nombres;
        apellidos = result['apellidos'] ?? apellidos;
        genero = result['genero'] ?? genero;
        ubicacion = result['ubicacion'] ?? ubicacion;
        fechaNacimiento = result['fechaNacimiento'] ?? fechaNacimiento;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          // Header
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
                'PERFIL',
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
          // Profile Card
          Expanded(
            child: Center(
              child: Container(
                width: 340,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFFF),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfileLabel('NOMBRES'),
                              SizedBox(height: 8),
                              ProfileLabel('APELLIDOS'),
                              SizedBox(height: 8),
                              ProfileLabel('GÉNERO'),
                              SizedBox(height: 8),
                              ProfileLabel('UBICACIÓN'),
                              SizedBox(height: 8),
                              ProfileLabel('FECHA DE\nNACIMIENTO'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfileValue(nombres),
                              SizedBox(height: 8),
                              ProfileValue(apellidos),
                              SizedBox(height: 8),
                              ProfileValue(genero),
                              SizedBox(height: 8),
                              ProfileValue(ubicacion),
                              SizedBox(height: 8),
                              ProfileValue(fechaNacimiento),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A45D1),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text(
                          'EDITAR DATOS',
                          style: TextStyle(
                            fontFamily: 'AntonSC',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: _editarDatos,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        width: 240,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5A5A),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.logout, size: 22),
                          label: const Text(
                            'CERRAR SESIÓN',
                            style: TextStyle(
                              fontFamily: 'AntonSC',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
