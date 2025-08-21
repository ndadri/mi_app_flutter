import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Limpiar datos del perfil para simular usuario nuevo
  final prefs = await SharedPreferences.getInstance();
  
  // Limpiar datos del perfil específicamente
  await prefs.remove('profile_nombres');
  await prefs.remove('profile_apellidos');
  await prefs.remove('profile_genero');
  await prefs.remove('profile_ubicacion');
  await prefs.remove('profile_fecha_nacimiento');
  
  print('✅ Datos del perfil limpiados para simular usuario nuevo');
  print('👤 El usuario ahora debería ver la pantalla de perfil vacío');
}
