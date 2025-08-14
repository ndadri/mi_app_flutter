import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/location_service.dart';
import '../config/api_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedGenero;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Agregar listeners para detectar cambios en los campos
    _nombresController.addListener(() => setState(() {}));
    _apellidosController.addListener(() => setState(() {}));
    _correoController.addListener(() => setState(() {}));
    _contrasenaController.addListener(() => setState(() {}));
    _ubicacionController.addListener(() => setState(() {}));
    _fechaNacimientoController.addListener(() => setState(() {}));
  }

  Future<void> _registerUser() async {
    final String nombres = _nombresController.text;
    final String apellidos = _apellidosController.text;
    final String correo = _correoController.text;
    final String contrasena = _contrasenaController.text;
    final String genero = _selectedGenero ?? '';
    final String ubicacion = _ubicacionController.text;
    final String fechaNacimiento = _fechaNacimientoController.text;

    if (nombres.isEmpty ||
        apellidos.isEmpty ||
        correo.isEmpty ||
        contrasena.isEmpty ||
        genero.isEmpty ||
        ubicacion.isEmpty ||
        fechaNacimiento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      // Obtener coordenadas si es posible
      final position = await LocationService.getCurrentLocation();
      
      final userData = jsonEncode({
        'nombres': nombres,
        'apellidos': apellidos,
        'correo': correo,
        'contraseña': contrasena,
        'genero': genero,
        'ubicacion': ubicacion,
        'fecha_nacimiento': fechaNacimiento,
        if (position != null) 'coordenadas': {
          'latitud': position.latitude,
          'longitud': position.longitude,
        },
      });

      final response = await http.post(
        Uri.parse(ApiConfig.registrarEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: userData,
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['mensaje']),
            backgroundColor: Colors.green,
          ),
        );
        // Limpiar formulario
        _nombresController.clear();
        _apellidosController.clear();
        _correoController.clear();
        _contrasenaController.clear();
        _ubicacionController.clear();
        _fechaNacimientoController.clear();
        setState(() {
          _selectedGenero = null;
        });
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['mensaje'] ?? 'Error al registrar el usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 años atrás
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6), // Color morado para header
              onPrimary: Colors.white, // Texto del header
              surface: Colors.white, // Fondo del calendario
              onSurface: Color(0xFF333333), // Texto del calendario
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      String? address = await LocationService.getCurrentAddress();
      
      if (address != null) {
        setState(() {
          _ubicacionController.text = address;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación obtenida correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación. Verifica los permisos.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 30,
              left: 40,
              right: 40,
            ),
            child: const Text(
              'PET MATCH',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Crear una Cuenta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _nombresController,
                          label: 'Nombres de Usuario',
                          icon: Icons.person_outline,
                          isPassword: false,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _apellidosController,
                          label: 'Apellidos',
                          icon: Icons.person_outline,
                          isPassword: false,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _correoController,
                          label: 'Correo Electrónico',
                          icon: Icons.email_outlined,
                          isPassword: false,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _contrasenaController,
                          label: 'Contraseña',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 15),
                        _buildGenderDropdown(),
                        const SizedBox(height: 15),
                        _buildLocationField(),
                        const SizedBox(height: 15),
                        _buildDateField(),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              elevation: 0,
                            ),
                            onPressed: _registerUser,
                            child: const Text(
                              'Registrarme',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[50],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGenero,
        decoration: InputDecoration(
          labelText: 'Género',
          prefixIcon: const Icon(
            Icons.wc_outlined,
            color: Color(0xFF8B5CF6),
          ),
          suffixIcon: _selectedGenero != null
              ? const AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: const TextStyle(color: Color(0xFF666666)),
        ),
        items: const [
          DropdownMenuItem(
            value: 'Hombre',
            child: Text('Hombre'),
          ),
          DropdownMenuItem(
            value: 'Mujer',
            child: Text('Mujer'),
          ),
          DropdownMenuItem(
            value: 'No Binario',
            child: Text('No Binario'),
          ),
          DropdownMenuItem(
            value: 'Prefiero no decirlo',
            child: Text('Prefiero no decirlo'),
          ),
        ],
        onChanged: (String? newValue) {
          setState(() {
            _selectedGenero = newValue;
          });
        },
        dropdownColor: Colors.white,
        menuMaxHeight: 200,
        borderRadius: BorderRadius.circular(15),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF8B5CF6),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextField(
          controller: _fechaNacimientoController,
          decoration: InputDecoration(
            labelText: 'Fecha de Nacimiento',
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF8B5CF6),
            ),
            suffixIcon: _fechaNacimientoController.text.isNotEmpty
                ? const AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            labelStyle: const TextStyle(color: Color(0xFF666666)),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return TextField(
      controller: _ubicacionController,
      decoration: InputDecoration(
        labelText: 'Ubicación',
        prefixIcon: const Icon(
          Icons.location_on_outlined,
          color: Color(0xFF8B5CF6),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_ubicacionController.text.isNotEmpty)
              const AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 300),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      color: Color(0xFF8B5CF6),
                    ),
              tooltip: 'Obtener ubicación actual',
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: const TextStyle(color: Color(0xFF666666)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF8B5CF6),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF8B5CF6),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : controller.text.isNotEmpty
                ? const AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: const TextStyle(color: Color(0xFF666666)),
      ),
    );
  }
}
//hola