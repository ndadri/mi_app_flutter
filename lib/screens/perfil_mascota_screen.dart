import 'package:flutter/material.dart';

class PerfilMascotaScreen extends StatefulWidget {
  const PerfilMascotaScreen({super.key});

  @override
  State<PerfilMascotaScreen> createState() => _PerfilMascotaScreenState();
}

class _PerfilMascotaScreenState extends State<PerfilMascotaScreen> {
  // Datos de la mascota
  String nombre = 'Luna';
  String edad = '2 años';
  String tipo = 'Perro';
  String sexo = 'Hembra';
  String ciudad = 'Quito';
  String estado = 'Disponible';

  // Controla si se muestra el modal y si es edición o registro
  bool showDialogCard = false;
  bool isEditing = true;

  // Controladores para los campos
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController edadCtrl = TextEditingController();
  final TextEditingController tipoCtrl = TextEditingController();
  final TextEditingController sexoCtrl = TextEditingController();
  final TextEditingController ciudadCtrl = TextEditingController();
  final TextEditingController estadoCtrl = TextEditingController();

  @override
  void dispose() {
    nombreCtrl.dispose();
    edadCtrl.dispose();
    tipoCtrl.dispose();
    sexoCtrl.dispose();
    ciudadCtrl.dispose();
    estadoCtrl.dispose();
    super.dispose();
  }

  void openEditCard({required bool edit}) {
    setState(() {
      isEditing = edit;
      showDialogCard = true;
      if (edit) {
        nombreCtrl.text = nombre;
        edadCtrl.text = edad;
        tipoCtrl.text = tipo;
        sexoCtrl.text = sexo;
        ciudadCtrl.text = ciudad;
        estadoCtrl.text = estado;
      } else {
        nombreCtrl.clear();
        edadCtrl.clear();
        tipoCtrl.clear();
        sexoCtrl.clear();
        ciudadCtrl.clear();
        estadoCtrl.clear();
      }
    });
  }

  void confirmCard() {
    setState(() {
      if (isEditing) {
        nombre = nombreCtrl.text;
        edad = edadCtrl.text;
        tipo = tipoCtrl.text;
        sexo = sexoCtrl.text;
        ciudad = ciudadCtrl.text;
        estado = estadoCtrl.text;
      } else {
        // Aquí podrías agregar la nueva mascota a una lista, si tuvieras varias
        nombre = nombreCtrl.text;
        edad = edadCtrl.text;
        tipo = tipoCtrl.text;
        sexo = sexoCtrl.text;
        ciudad = ciudadCtrl.text;
        estado = estadoCtrl.text;
      }
      showDialogCard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tarjeta de perfil de mascota
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  children: [
                    // Foto de la mascota
                    const CircleAvatar(
                      radius: 54,
                      backgroundImage: NetworkImage(
                        'https://images.pexels.com/photos/4587995/pexels-photo-4587995.jpeg',
                      ),
                    ),
                    const SizedBox(height: 18),
                    _profileField('Nombre', nombre),
                    _profileField('Edad', edad),
                    _profileField('Tipo de animal', tipo),
                    _profileField('Sexo', sexo),
                    _profileField('Ciudad', ciudad),
                    _profileField('Estado', estado),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A45D1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () => openEditCard(edit: true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar datos'),
                    ),
                  ],
                ),
              ),
            ),
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
              type: MaterialType.transparency, // <-- Quita el fondo gris
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
                              Text(
                                isEditing ? 'Editar datos de mascota' : 'Registrar nueva mascota',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF7A45D1),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              _inputField('Nombre', nombreCtrl),
                              _inputField('Edad', edadCtrl),
                              _inputField('Tipo de animal', tipoCtrl),
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