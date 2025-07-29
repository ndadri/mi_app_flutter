import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

// Define la clase Mascota correctamente
class Mascota {
  final String nombre;
  final String edad;
  final String tipo;
  final String raza;
  final String sexo;
  final String ciudad;
  final String estado;
  final String? fotoPath; // Si quieres guardar la ruta de la foto

  Mascota({
    required this.nombre,
    required this.edad,
    required this.tipo,
    required this.raza,
    required this.sexo,
    required this.ciudad,
    required this.estado,
    this.fotoPath,
  });
}

class PerfilMascotaScreen extends StatefulWidget {
  const PerfilMascotaScreen({super.key});

  @override
  State<PerfilMascotaScreen> createState() => _PerfilMascotaScreenState();
}

class _PerfilMascotaScreenState extends State<PerfilMascotaScreen> {
  // Listas de tipos y razas
  final List<String> tiposAnimales = ['Perro', 'Gato'];
  final Map<String, List<String>> razasPorTipo = {
    'Perro': [
      'Labrador', 'Golden Retriever', 'Bulldog', 'Poodle', 'Chihuahua', 'Pastor Alemán', 'Beagle', 'Boxer', 'Dálmata', 'Otro'
    ],
    'Gato': [
      'Siames', 'Persa', 'Maine Coon', 'Bengala', 'Sphynx', 'Ragdoll', 'Azul Ruso', 'Angora', 'Otro'
    ],
  };
  // Datos de la mascota
  List<Mascota> mascotas = [
    Mascota(
      nombre: 'Luna',
      edad: '2 años',
      tipo: 'Perro',
      raza: 'Labrador',
      sexo: 'Hembra',
      ciudad: 'Quito',
      estado: 'Disponible',
      fotoPath: null,
    ),
  ];
  int? editingIndex; // null si es nueva, si no el índice a editar

  // Controla si se muestra el modal y si es edición o registro
  bool showDialogCard = false;
  bool isEditing = true;

  // Controladores para los campos
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController edadCtrl = TextEditingController();
  final TextEditingController tipoCtrl = TextEditingController(); // No se usará para el Dropdown, pero se deja para compatibilidad
  final TextEditingController razaCtrl = TextEditingController(); // Igual

  String? selectedTipo;
  String? selectedRaza;
  final TextEditingController sexoCtrl = TextEditingController();
  final TextEditingController ciudadCtrl = TextEditingController();
  final TextEditingController estadoCtrl = TextEditingController();

  // Imagen temporal para el modal
  File? pickedImageFile;

  @override
  void dispose() {
    nombreCtrl.dispose();
    edadCtrl.dispose();
    tipoCtrl.dispose();
    razaCtrl.dispose();
    sexoCtrl.dispose();
    ciudadCtrl.dispose();
    estadoCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Ajustar foto',
            toolbarColor: const Color(0xFF7A45D1),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Ajustar foto',
            aspectRatioLockEnabled: false,
          ),
        ],
      );
      if (cropped != null) {
        setState(() {
          pickedImageFile = File(cropped.path);
        });
      }
    }
  }

  void openEditCard({required bool edit, int? index}) {
    setState(() {
      isEditing = edit;
      showDialogCard = true;
      editingIndex = edit ? index : null;
      if (edit && index != null) {
        final mascota = mascotas[index];
        nombreCtrl.text = mascota.nombre;
        edadCtrl.text = mascota.edad;
        tipoCtrl.text = mascota.tipo;
        razaCtrl.text = mascota.raza;
        selectedTipo = mascota.tipo;
        selectedRaza = mascota.raza;
        sexoCtrl.text = mascota.sexo;
        ciudadCtrl.text = mascota.ciudad;
        estadoCtrl.text = mascota.estado;
        pickedImageFile = mascota.fotoPath != null ? File(mascota.fotoPath!) : null;
      } else {
        nombreCtrl.clear();
        edadCtrl.clear();
        tipoCtrl.clear();
        razaCtrl.clear();
        selectedTipo = null;
        selectedRaza = null;
        sexoCtrl.clear();
        ciudadCtrl.clear();
        estadoCtrl.clear();
        pickedImageFile = null;
      }
    });
  }

  void confirmCard() {
    setState(() {
      if (isEditing && editingIndex != null) {
        mascotas[editingIndex!] = Mascota(
          nombre: nombreCtrl.text,
          edad: edadCtrl.text,
          tipo: selectedTipo ?? '',
          raza: selectedRaza ?? '',
          sexo: sexoCtrl.text,
          ciudad: ciudadCtrl.text,
          estado: estadoCtrl.text,
          fotoPath: pickedImageFile?.path,
        );
      } else {
        mascotas.add(Mascota(
          nombre: nombreCtrl.text,
          edad: edadCtrl.text,
          tipo: selectedTipo ?? '',
          raza: selectedRaza ?? '',
          sexo: sexoCtrl.text,
          ciudad: ciudadCtrl.text,
          estado: estadoCtrl.text,
          fotoPath: pickedImageFile?.path,
        ));
      }
      showDialogCard = false;
      pickedImageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...mascotas.asMap().entries.map((entry) {
              final index = entry.key;
              final mascota = entry.value;
              double photoSize = MediaQuery.of(context).size.width * 0.28;
              if (photoSize < 90) photoSize = 90;
              if (photoSize > 140) photoSize = 140;
              ImageProvider imageProvider;
              if (mascota.fotoPath != null && mascota.fotoPath!.isNotEmpty) {
                imageProvider = FileImage(File(mascota.fotoPath!));
              } else {
                imageProvider = const NetworkImage('https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg');
              }
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.all(16),
                color: const Color(0xFFE3D9F7), // Fondo más oscuro que el actual
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    children: [
                      // Foto de la mascota
                      Container(
                        width: photoSize,
                        height: photoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: photoSize / 2,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: imageProvider,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _profileField('Nombre', mascota.nombre),
                      _profileField('Edad', mascota.edad),
                      _profileField('Tipo de animal', mascota.tipo),
                      _profileField('Raza', mascota.raza),
                      _profileField('Sexo', mascota.sexo),
                      _profileField('Ciudad', mascota.ciudad),
                      _profileField('Estado', mascota.estado),
                      const SizedBox(height: 18),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7A45D1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              onPressed: () => openEditCard(edit: true, index: index),
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar datos'),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('¿Eliminar mascota?'),
                                    content: const Text('¿Estás seguro de que deseas eliminar esta mascota? Esta acción no se puede deshacer.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  setState(() {
                                    mascotas.removeAt(index);
                                  });
                                }
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            // Botón para agregar nueva mascota (fuera de la tarjeta)
            FloatingActionButton.extended(
              heroTag: 'add_pet',
              backgroundColor: const Color(0xFF7A45D1),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Registrar nueva mascota',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () => openEditCard(edit: false),
            ),
          ],
        ),
        // Modal tipo carta pequeña
        if (showDialogCard)
          Center(
            child: Material(
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
                              const SizedBox(height: 8),
                              Text(
                                isEditing ? 'Editar foto de la mascota' : 'Elegir foto de la mascota',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF7A45D1),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
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
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.18),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
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
                                                'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg',
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
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: DropdownButtonFormField<String>(
                                  value: selectedTipo,
                                  decoration: InputDecoration(
                                    labelText: 'Tipo de animal',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: tiposAnimales
                                      .map((tipo) => DropdownMenuItem(
                                            value: tipo,
                                            child: Text(tipo),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTipo = value;
                                      selectedRaza = null;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: DropdownButtonFormField<String>(
                                  value: selectedRaza,
                                  decoration: InputDecoration(
                                    labelText: 'Raza',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: (selectedTipo != null)
                                      ? razasPorTipo[selectedTipo]!
                                          .map((raza) => DropdownMenuItem(
                                                value: raza,
                                                child: Text(raza),
                                              ))
                                          .toList()
                                      : [],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedRaza = value;
                                    });
                                  },
                                ),
                              ),
                              _inputField('Sexo', sexoCtrl),
                              _inputField('Ciudad', ciudadCtrl),
                              _inputField('Estado', estadoCtrl),
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
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 16,
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

class CustomTextStyle {
  static TextStyle get header => const TextStyle(
        fontFamily: 'AntonSC',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.5,
      );
}
