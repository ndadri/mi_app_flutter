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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Definir breakpoints para responsividad
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        
        return Stack(
          children: [
            // Contenido principal responsivo
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: _getHorizontalPadding(screenWidth),
                vertical: _getVerticalPadding(screenHeight),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (screenWidth >= 1200) 
                    _buildLargeScreenLayout(screenWidth, screenHeight)
                  else if (screenWidth >= 600)
                    _buildMediumScreenLayout(screenWidth, screenHeight)
                  else
                    _buildSmallScreenLayout(screenWidth, screenHeight),
                  
                  SizedBox(height: _getSpacing(screenWidth)),
                  
                  // Botón de cerrar sesión responsivo
                  _buildLogoutButton(screenWidth),
                ],
              ),
            ),
            
            // Modal de edición responsivo
            if (showDialogCard)
              _buildEditModal(screenWidth, screenHeight),
          ],
        );
      },
    );
  }

  // Layout para pantallas grandes (tablets horizontales, desktop)
  Widget _buildLargeScreenLayout(double screenWidth, double screenHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda - Foto de perfil
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildProfileImage(screenWidth * 0.15), // Imagen más grande
              SizedBox(height: _getSpacing(screenWidth)),
              Text(
                '$nombres $apellidos',
                style: TextStyle(
                  fontSize: _getTitleSize(screenWidth),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AntonSC',
                  color: const Color(0xFF7A45D1),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        SizedBox(width: _getSpacing(screenWidth)),
        
        // Columna derecha - Información del perfil
        Expanded(
          flex: 3,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth)),
            ),
            elevation: 8,
            color: const Color(0xFFF7ECFA),
            child: Padding(
              padding: EdgeInsets.all(_getCardPadding(screenWidth)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'INFORMACIÓN DEL PERFIL',
                    style: TextStyle(
                      fontSize: _getSubtitleSize(screenWidth),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AntonSC',
                      color: const Color(0xFF7A45D1),
                    ),
                  ),
                  SizedBox(height: _getSpacing(screenWidth)),
                  _profileField('Nombres', nombres, screenWidth),
                  _profileField('Apellidos', apellidos, screenWidth),
                  _profileField('Género', genero, screenWidth),
                  _profileField('Ubicación', ubicacion, screenWidth),
                  _profileField('Fecha de nacimiento', fechaNacimiento, screenWidth),
                  SizedBox(height: _getSpacing(screenWidth)),
                  _buildEditButton(screenWidth),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Layout para pantallas medianas (tablets verticales)
  Widget _buildMediumScreenLayout(double screenWidth, double screenHeight) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth)),
          ),
          elevation: 8,
          color: const Color(0xFFF7ECFA),
          child: Padding(
            padding: EdgeInsets.all(_getCardPadding(screenWidth)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfileImage(screenWidth * 0.2),
                SizedBox(height: _getSpacing(screenWidth)),
                Text(
                  '$nombres $apellidos',
                  style: TextStyle(
                    fontSize: _getTitleSize(screenWidth),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'AntonSC',
                    color: const Color(0xFF7A45D1),
                  ),
                ),
                SizedBox(height: _getSpacing(screenWidth)),
                _profileField('Nombres', nombres, screenWidth),
                _profileField('Apellidos', apellidos, screenWidth),
                _profileField('Género', genero, screenWidth),
                _profileField('Ubicación', ubicacion, screenWidth),
                _profileField('Fecha de nacimiento', fechaNacimiento, screenWidth),
                SizedBox(height: _getSpacing(screenWidth)),
                _buildEditButton(screenWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Layout para pantallas pequeñas (móviles)
  Widget _buildSmallScreenLayout(double screenWidth, double screenHeight) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth)),
        ),
        elevation: 8,
        margin: EdgeInsets.all(_getCardMargin(screenWidth)),
        color: const Color(0xFFF7ECFA),
        child: Padding(
          padding: EdgeInsets.all(_getCardPadding(screenWidth)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProfileImage(screenWidth * 0.25),
              SizedBox(height: _getSpacing(screenWidth)),
              _profileField('Nombres', nombres, screenWidth),
              _profileField('Apellidos', apellidos, screenWidth),
              _profileField('Género', genero, screenWidth),
              _profileField('Ubicación', ubicacion, screenWidth),
              _profileField('Fecha de nacimiento', fechaNacimiento, screenWidth),
              SizedBox(height: _getSpacing(screenWidth)),
              _buildEditButton(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  // Componente de imagen de perfil responsivo
  Widget _buildProfileImage(double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: const NetworkImage(
        'https://randomuser.me/api/portraits/men/1.jpg',
      ),
    );
  }

  // Botón de editar responsivo
  Widget _buildEditButton(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7A45D1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth) / 2),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _getButtonPadding(screenWidth),
            vertical: _getButtonPadding(screenWidth) * 0.75,
          ),
          textStyle: TextStyle(
            fontFamily: 'AntonSC',
            fontWeight: FontWeight.bold,
            fontSize: _getButtonTextSize(screenWidth),
          ),
        ),
        onPressed: openEditCard,
        icon: Icon(Icons.edit, size: _getIconSize(screenWidth)),
        label: const Text('EDITAR DATOS'),
      ),
    );
  }

  // Botón de cerrar sesión responsivo
  Widget _buildLogoutButton(double screenWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth < 600 ? double.infinity : 300,
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth) / 2),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _getButtonPadding(screenWidth),
            vertical: _getButtonPadding(screenWidth) * 0.75,
          ),
          textStyle: TextStyle(
            fontFamily: 'AntonSC',
            fontWeight: FontWeight.bold,
            fontSize: _getButtonTextSize(screenWidth),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        },
        icon: Icon(Icons.logout, size: _getIconSize(screenWidth)),
        label: const Text('CERRAR SESIÓN'),
      ),
    );
  }
  // Modal de edición responsivo
  Widget _buildEditModal(double screenWidth, double screenHeight) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth)),
              ),
              elevation: 12,
              margin: EdgeInsets.all(_getCardMargin(screenWidth)),
              child: Container(
                width: _getModalWidth(screenWidth),
                padding: EdgeInsets.all(_getCardPadding(screenWidth)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Editar datos de usuario',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _getSubtitleSize(screenWidth),
                        color: const Color(0xFF7A45D1),
                        fontFamily: 'AntonSC',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: _getSpacing(screenWidth)),
                    _inputField('Nombres', nombresCtrl, screenWidth),
                    _inputField('Apellidos', apellidosCtrl, screenWidth),
                    _inputField('Género', generoCtrl, screenWidth),
                    _inputField('Ubicación', ubicacionCtrl, screenWidth),
                    _inputField('Fecha de nacimiento', fechaNacimientoCtrl, screenWidth),
                    SizedBox(height: _getSpacing(screenWidth)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => showDialogCard = false),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: _getButtonTextSize(screenWidth),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: _getSpacing(screenWidth)),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7A45D1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth) / 2),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: _getButtonPadding(screenWidth) * 0.75,
                              ),
                              textStyle: TextStyle(
                                fontSize: _getButtonTextSize(screenWidth),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: confirmCard,
                            child: const Text('Confirmar'),
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
    );
  }

  // Función para campos de perfil responsivos
  Widget _profileField(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _getFieldSpacing(screenWidth)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: screenWidth < 600 ? 2 : 3,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                fontSize: _getFieldLabelSize(screenWidth),
                fontFamily: 'AntonSC',
              ),
            ),
          ),
          SizedBox(width: _getSpacing(screenWidth) / 2),
          Expanded(
            flex: screenWidth < 600 ? 3 : 4,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black54,
                fontSize: _getFieldValueSize(screenWidth),
                fontFamily: 'AntonSC',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para campos de entrada responsivos
  Widget _inputField(String label, TextEditingController controller, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _getFieldSpacing(screenWidth)),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: _getInputTextSize(screenWidth)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: _getInputLabelSize(screenWidth)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth) / 3),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: _getInputPadding(screenWidth),
            vertical: _getInputPadding(screenWidth) * 0.75,
          ),
        ),
      ),
    );
  }

  // Funciones para calcular dimensiones responsivas
  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 1200) return 32.0;
    return 64.0;
  }

  double _getVerticalPadding(double screenHeight) {
    if (screenHeight < 600) return 16.0;
    if (screenHeight < 800) return 24.0;
    return 32.0;
  }

  double _getCardMargin(double screenWidth) {
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 1200) return 24.0;
    return 32.0;
  }

  double _getCardPadding(double screenWidth) {
    if (screenWidth < 600) return 20.0;
    if (screenWidth < 1200) return 28.0;
    return 36.0;
  }

  double _getBorderRadius(double screenWidth) {
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 1200) return 20.0;
    return 24.0;
  }

  double _getSpacing(double screenWidth) {
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 1200) return 20.0;
    return 24.0;
  }

  double _getFieldSpacing(double screenWidth) {
    if (screenWidth < 600) return 8.0;
    if (screenWidth < 1200) return 10.0;
    return 12.0;
  }

  double _getTitleSize(double screenWidth) {
    if (screenWidth < 600) return 20.0;
    if (screenWidth < 1200) return 24.0;
    return 28.0;
  }

  double _getSubtitleSize(double screenWidth) {
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 1200) return 18.0;
    return 20.0;
  }

  double _getFieldLabelSize(double screenWidth) {
    if (screenWidth < 600) return 14.0;
    if (screenWidth < 1200) return 15.0;
    return 16.0;
  }

  double _getFieldValueSize(double screenWidth) {
    if (screenWidth < 600) return 14.0;
    if (screenWidth < 1200) return 15.0;
    return 16.0;
  }

  double _getButtonTextSize(double screenWidth) {
    if (screenWidth < 600) return 14.0;
    if (screenWidth < 1200) return 15.0;
    return 16.0;
  }

  double _getInputTextSize(double screenWidth) {
    if (screenWidth < 600) return 14.0;
    if (screenWidth < 1200) return 15.0;
    return 16.0;
  }

  double _getInputLabelSize(double screenWidth) {
    if (screenWidth < 600) return 12.0;
    if (screenWidth < 1200) return 13.0;
    return 14.0;
  }

  double _getButtonPadding(double screenWidth) {
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 1200) return 20.0;
    return 24.0;
  }

  double _getInputPadding(double screenWidth) {
    if (screenWidth < 600) return 12.0;
    if (screenWidth < 1200) return 14.0;
    return 16.0;
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth < 600) return 18.0;
    if (screenWidth < 1200) return 20.0;
    return 22.0;
  }

  double _getModalWidth(double screenWidth) {
    if (screenWidth < 600) return screenWidth * 0.9;
    if (screenWidth < 1200) return screenWidth * 0.6;
    return screenWidth * 0.4;
  }

}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;
        
        return AppBar(
          title: Text(
            'PERFIL',
            style: TextStyle(
              fontFamily: 'AntonSC',
              fontSize: screenWidth < 600 ? 18.0 : 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF7A45D1),
          elevation: 4,
          toolbarHeight: screenWidth < 600 ? 56.0 : 64.0,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}