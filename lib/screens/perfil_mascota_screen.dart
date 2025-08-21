import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PerfilMascotaScreen extends StatefulWidget {
  const PerfilMascotaScreen({super.key});

  @override
  State<PerfilMascotaScreen> createState() => _PerfilMascotaScreenState();
}

class _PerfilMascotaScreenState extends State<PerfilMascotaScreen> {
  bool showRegisterCard = false;
  File? pickedImageFile;

  // Datos simulados de la mascota registrada
  String? nombre;
  String? edad;
  String? tipoAnimal;
  String? raza;
  String? sexo;
  String? ciudad;
  String? estado;

  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController edadCtrl = TextEditingController();
  final TextEditingController razaCtrl = TextEditingController();
  final TextEditingController ciudadCtrl = TextEditingController();
  final TextEditingController estadoCtrl = TextEditingController();

  // Opciones de tipo de animal y sexo
  final List<String> tipoAnimalOpciones = ['Perro', 'Gato', 'Otro'];
  String? tipoAnimalSeleccionado;
  final List<String> sexoOpciones = ['Macho', 'Hembra'];
  String? sexoSeleccionado;

  // Razas para perros y gatos
  final Map<String, List<String>> razasPorTipo = {
    'Perro': [
      'Labrador Retriever', 'Golden Retriever', 'Bulldog', 'Poodle', 'Chihuahua', 'Pastor Alemán', 'Beagle', 'Boxer', 'Dálmata',
      'Shih Tzu', 'Doberman', 'Rottweiler', 'Schnauzer', 'Cocker Spaniel', 'Pug', 'Yorkshire Terrier', 'Border Collie', 'Akita',
      'Basset Hound', 'Samoyedo', 'Husky Siberiano', 'Gran Danés', 'Bull Terrier', 'Mastín', 'Pinscher', 'Fox Terrier', 'Otro'
    ],
    'Gato': [
      'Siames', 'Persa', 'Maine Coon', 'Bengala', 'Sphynx', 'Ragdoll', 'Azul Ruso', 'Angora', 'British Shorthair',
      'Scottish Fold', 'Bombay', 'Himalayo', 'Manx', 'Savannah', 'Abisinio', 'Bosque de Noruega', 'Exótico', 'Oriental', 'Otro'
    ],
    'Otro': ['Otro']
  };
  String? razaSeleccionada;

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
      edad = edadCtrl.text;
      tipoAnimal = tipoAnimalSeleccionado;
      raza = razaCtrl.text;
      sexo = sexoSeleccionado;
      ciudad = ciudadCtrl.text;
      estado = estadoCtrl.text;
      showRegisterCard = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mascota registrada correctamente')),
    );
  }

  void editarPerfil() {
    nombreCtrl.text = nombre ?? '';
    edadCtrl.text = edad ?? '';
    tipoAnimalSeleccionado = tipoAnimal ?? tipoAnimalOpciones.first;
    razaCtrl.text = raza ?? '';
    sexoSeleccionado = sexo ?? sexoOpciones.first;
    ciudadCtrl.text = ciudad ?? '';
    estadoCtrl.text = estado ?? '';
    setState(() {
      showRegisterCard = true;
    });
  }

  void cerrarSesion() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                      Icons.pets,
                      size: 60,
                      color: Color(0xFF7A45D1),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '¡NO HAY DATOS DE MASCOTA REGISTRADOS!',
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
                      'REGISTRA LA INFORMACIÓN DE TU MASCOTA\nPARA QUE OTROS USUARIOS PUEDAN VER SU PERFIL',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => showRegisterCard = true),
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
                        '+ REGISTRAR MI MASCOTA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
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
                            Icons.pets,
                            size: 60,
                            color: Color(0xFF7A45D1),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    nombre ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Edad: ${edad ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                  ),
                  Text(
                    'Tipo: ${tipoAnimal ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                  ),
                  Text(
                    'Raza: ${raza ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                  ),
                  Text(
                    'Sexo: ${sexo ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                  ),
                  Text(
                    'Ciudad: ${ciudad ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                  ),
                  Text(
                    'Estado: ${estado ?? ''}',
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
                                          'https://cdn-icons-png.flaticon.com/512/616/616408.png',
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
                        _inputField('Edad', edadCtrl),
                        // Tipo de animal como dropdown
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: DropdownButtonFormField<String>(
                            value: tipoAnimalSeleccionado,
                            decoration: InputDecoration(
                              labelText: 'Tipo de animal',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: tipoAnimalOpciones
                                .map((opcion) => DropdownMenuItem(
                                      value: opcion,
                                      child: Text(opcion),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                tipoAnimalSeleccionado = value;
                                // Reset raza al cambiar tipo
                                razaSeleccionada = null;
                              });
                            },
                          ),
                        ),
                        // Raza como dropdown dependiente del tipo
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: DropdownButtonFormField<String>(
                            value: razaSeleccionada,
                            decoration: InputDecoration(
                              labelText: 'Raza',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: (tipoAnimalSeleccionado != null)
                                ? razasPorTipo[tipoAnimalSeleccionado]!
                                    .map((raza) => DropdownMenuItem(
                                          value: raza,
                                          child: Text(raza),
                                        ))
                                    .toList()
                                : [],
                            onChanged: (value) {
                              setState(() {
                                razaSeleccionada = value;
                              });
                            },
                          ),
                        ),
                        // Sexo como dropdown
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: DropdownButtonFormField<String>(
                            value: sexoSeleccionado,
                            decoration: InputDecoration(
                              labelText: 'Sexo',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: sexoOpciones
                                .map((opcion) => DropdownMenuItem(
                                      value: opcion,
                                      child: Text(opcion),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                sexoSeleccionado = value;
                              });
                            },
                          ),
                        ),
                        _inputField('Ciudad', ciudadCtrl),
                        _inputField('Estado', estadoCtrl),
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
    );
  }
}

// Campo de entrada reutilizable
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