import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  const PerfilUsuarioScreen({super.key});

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  bool showRegisterCard = false;
  File? pickedImageFile;

  // Datos simulados del usuario registrado
  String? nombre;
  String? apellido;
  String? genero;
  String? ciudad;
  String? fechaNacimiento;

  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController apellidoCtrl = TextEditingController();
  final TextEditingController ciudadCtrl = TextEditingController();
  final TextEditingController fechaNacimientoCtrl = TextEditingController();

  // Opciones de género
  final List<String> generoOpciones = [
    'Hombre',
    'Mujer',
    'No Binario',
    'Prefiero No Decirlo',
  ];
  String? generoSeleccionado;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedImageFile = File(picked.path);
      });
    }
  }

  void confirmCard() {
    setState(() {
      nombre = nombreCtrl.text;
      apellido = apellidoCtrl.text;
      genero = generoSeleccionado;
      ciudad = ciudadCtrl.text;
      fechaNacimiento = fechaNacimientoCtrl.text;
      showRegisterCard = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario registrado correctamente')),
    );
  }

  void editarPerfil() {
    nombreCtrl.text = nombre ?? '';
    apellidoCtrl.text = apellido ?? '';
    generoSeleccionado = genero ?? generoOpciones.first;
    ciudadCtrl.text = ciudad ?? '';
    fechaNacimientoCtrl.text = fechaNacimiento ?? '';
    setState(() {
      showRegisterCard = true;
    });
  }

  void cerrarSesion() {
    // Aquí puedes limpiar datos de sesión si usas SharedPreferences
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _selectFechaNacimiento(BuildContext context) async {
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 6570)); // 18 años atrás
    if (fechaNacimientoCtrl.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(fechaNacimientoCtrl.text);
      } catch (_) {}
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecciona tu fecha de nacimiento',
      locale: const Locale('es'),
    );
    if (picked != null) {
      setState(() {
        fechaNacimientoCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void mostrarRegistroSiNoHayDatos() {
    if (nombre == null || nombre!.isEmpty) {
      setState(() {
        showRegisterCard = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!showRegisterCard && nombre == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A45D1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF7A45D1),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '¡NO HAY DATOS DE USUARIO REGISTRADOS!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'REGISTRA TU INFORMACIÓN PERSONAL\nPARA QUE OTROS USUARIOS PUEDAN VER TU PERFIL',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: mostrarRegistroSiNoHayDatos,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A45D1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '+ REGISTRAR MI USUARIO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          if (!showRegisterCard && nombre != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A45D1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: pickedImageFile != null
                          ? ClipOval(
                              child: Image.file(
                                pickedImageFile!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF7A45D1),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${nombre ?? ''} ${apellido ?? ''}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Género: ${genero ?? ''}',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),
                    Text(
                      'Ciudad:  ${ciudad ?? ''}',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),
                    Text(
                      'Fecha de nacimiento: ${fechaNacimiento ?? ''}',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: editarPerfil,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7A45D1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Editar Perfil'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: cerrarSesion,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF7A45D1),
                              side: const BorderSide(color: Color(0xFF7A45D1)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cerrar Sesión'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (showRegisterCard)
            Center(
              child: Material(
                type: MaterialType.transparency,
                child: SingleChildScrollView(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Container(
                      width: 350,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: pickImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                  ),
                                  child: ClipOval(
                                    child: pickedImageFile != null
                                        ? Image.file(
                                            pickedImageFile!,
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          )
                                        : Image.network(
                                            'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.camera_alt, color: Color(0xFF7A45D1), size: 26),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _inputField('Nombre', nombreCtrl),
                          _inputField('Apellido', apellidoCtrl),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: DropdownButtonFormField<String>(
                              value: generoSeleccionado,
                              decoration: InputDecoration(
                                labelText: 'Género',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: generoOpciones
                                  .map((opcion) => DropdownMenuItem(
                                        value: opcion,
                                        child: Text(opcion),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  generoSeleccionado = value;
                                });
                              },
                            ),
                          ),
                          _inputField('Ciudad', ciudadCtrl),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: GestureDetector(
                              onTap: () => _selectFechaNacimiento(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: fechaNacimientoCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Fecha de nacimiento',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    suffixIcon: const Icon(Icons.calendar_today),
                                  ),
                                  keyboardType: TextInputType.datetime,
                                  readOnly: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => showRegisterCard = false),
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Campo de entrada reutilizable
Widget _inputField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),
  );
}
