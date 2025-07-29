import 'package:flutter/material.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  const PerfilUsuarioScreen({super.key});

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  // Datos del usuario
  String nombres = 'Juan';
  String apellidos = 'Pérez';
  String genero = 'Masculino';
  String ubicacion = 'Quito';
  String fechaNacimiento = '12/05/1995';

  // Controla si se muestra el modal de edición
  bool showDialogCard = false;

  // Controladores para los campos
  final TextEditingController nombresCtrl = TextEditingController();
  final TextEditingController apellidosCtrl = TextEditingController();
  final TextEditingController generoCtrl = TextEditingController();
  final TextEditingController ubicacionCtrl = TextEditingController();
  final TextEditingController fechaNacimientoCtrl = TextEditingController();

  @override
  void dispose() {
    nombresCtrl.dispose();
    apellidosCtrl.dispose();
    generoCtrl.dispose();
    ubicacionCtrl.dispose();
    fechaNacimientoCtrl.dispose();
    super.dispose();
  }

  void openEditCard() {
    setState(() {
      showDialogCard = true;
      nombresCtrl.text = nombres;
      apellidosCtrl.text = apellidos;
      generoCtrl.text = genero;
      ubicacionCtrl.text = ubicacion;
      fechaNacimientoCtrl.text = fechaNacimiento;
    });
  }

  void confirmCard() {
    setState(() {
      nombres = nombresCtrl.text;
      apellidos = apellidosCtrl.text;
      genero = generoCtrl.text;
      ubicacion = ubicacionCtrl.text;
      fechaNacimiento = fechaNacimientoCtrl.text;
      showDialogCard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
                margin: const EdgeInsets.all(24),
                color: const Color(0xFFF7ECFA),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Foto del usuario
                      const CircleAvatar(
                        radius: 54,
                        backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/men/1.jpg',
                        ),
                      ),
                      const SizedBox(height: 18),
                      _profileField('Nombres', nombres),
                      _profileField('Apellidos', apellidos),
                      _profileField('Género', genero),
                      _profileField('Ubicación', ubicacion),
                      _profileField('Fecha de nacimiento', fechaNacimiento),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A45D1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(
                            fontFamily: 'AntonSC',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: openEditCard,
                        icon: const Icon(Icons.edit),
                        label: const Text('EDITAR DATOS'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontFamily: 'AntonSC',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text('CERRAR SESIÓN'),
            ),
          ],
        ),
        // Modal tipo carta pequeña
        if (showDialogCard)
          Center(
            child: Material(
              // Quita el color de fondo para eliminar el gris
              type: MaterialType.transparency,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth < 400 ? constraints.maxWidth * 0.95 : 400;
                    return SingleChildScrollView(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Container(
                          width: maxWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Editar datos de usuario',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF7A45D1),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              _inputField('Nombres', nombresCtrl),
                              _inputField('Apellidos', apellidosCtrl),
                              _inputField('Género', generoCtrl),
                              _inputField('Ubicación', ubicacionCtrl),
                              _inputField('Fecha de nacimiento', fechaNacimientoCtrl),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => setState(() => showDialogCard = false),
                                    child: const Text('Cancelar'),
                                  ),
                                  Flexible(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF7A45D1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: confirmCard,
                                      child: const Text('Confirmar', overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _profileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                fontSize: 16,
                fontFamily: 'AntonSC',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontFamily: 'AntonSC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Perfil de Usuario'),
      centerTitle: true,
      backgroundColor: const Color(0xFF7A45D1),
      elevation: 4,
      titleTextStyle: const TextStyle(
        fontFamily: 'AntonSC',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.5,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}