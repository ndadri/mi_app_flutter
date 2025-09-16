import 'package:flutter/material.dart';

class EditAdminProfileDialog extends StatefulWidget {
  final String nombres;
  final String apellidos;
  final String genero;
  final String ubicacion;
  final String fechaNacimiento;
  const EditAdminProfileDialog({super.key, 
    required this.nombres,
    required this.apellidos,
    required this.genero,
    required this.ubicacion,
    required this.fechaNacimiento,
  });
  @override
  State<EditAdminProfileDialog> createState() => EditAdminProfileDialogState();
}

class EditAdminProfileDialogState extends State<EditAdminProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late String nombres;
  late String apellidos;
  late String genero;
  late String ubicacion;
  late String fechaNacimiento;

  @override
  void initState() {
    super.initState();
    nombres = widget.nombres;
    apellidos = widget.apellidos;
    genero = widget.genero;
    ubicacion = widget.ubicacion;
    fechaNacimiento = widget.fechaNacimiento;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF5EFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'EDITAR DATOS DE USUARIO',
                style: TextStyle(
                  fontFamily: 'AntonSC',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF7A45D1),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _customTextField(
                    label: 'NOMBRES',
                    initialValue: nombres,
                    onChanged: (v) => nombres = v,
                  ),
                  _customTextField(
                    label: 'APELLIDOS',
                    initialValue: apellidos,
                    onChanged: (v) => apellidos = v,
                  ),
                  _customTextField(
                    label: 'GÉNERO',
                    initialValue: genero,
                    onChanged: (v) => genero = v,
                  ),
                  _customTextField(
                    label: 'UBICACIÓN',
                    initialValue: ubicacion,
                    onChanged: (v) => ubicacion = v,
                  ),
                  _customTextField(
                    label: 'FECHA DE NACIMIENTO',
                    initialValue: fechaNacimiento,
                    onChanged: (v) => fechaNacimiento = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(
                      fontFamily: 'AntonSC',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A45D1),
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A45D1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop({
                        'nombres': nombres,
                        'apellidos': apellidos,
                        'genero': genero,
                        'ubicacion': ubicacion,
                        'fechaNacimiento': fechaNacimiento,
                      });
                    }
                  },
                  child: const Text(
                    'CONFIRMAR',
                    style: TextStyle(
                      fontFamily: 'AntonSC',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _customTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
        style: const TextStyle(
          fontFamily: 'AntonSC',
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'AntonSC',
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF7A45D1),
            letterSpacing: 1.1,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7A45D1), width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7A45D1), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7A45D1), width: 2),
          ),
        ),
      ),
    );
  }
}
