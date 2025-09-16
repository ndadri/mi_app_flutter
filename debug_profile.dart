import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DebugProfileScreen(),
    );
  }
}

class DebugProfileScreen extends StatefulWidget {
  const DebugProfileScreen({super.key});

  @override
  _DebugProfileScreenState createState() => _DebugProfileScreenState();
}

class _DebugProfileScreenState extends State<DebugProfileScreen> {
  Map<String, String> profileData = {};

  @override
  void initState() {
    super.initState();
    _loadDebugData();
  }

  Future<void> _loadDebugData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      profileData = {
        'user_email': prefs.getString('user_email') ?? 'NO ENCONTRADO',
        'user_name': prefs.getString('user_name') ?? 'NO ENCONTRADO',
        'user_id': prefs.getInt('user_id')?.toString() ?? 'NO ENCONTRADO',
        'user_id_google': prefs.getString('user_id_google') ?? 'NO ENCONTRADO',
        'profile_nombres': prefs.getString('profile_nombres') ?? 'NO ENCONTRADO',
        'profile_apellidos': prefs.getString('profile_apellidos') ?? 'NO ENCONTRADO',
        'profile_genero': prefs.getString('profile_genero') ?? 'NO ENCONTRADO',
        'profile_ubicacion': prefs.getString('profile_ubicacion') ?? 'NO ENCONTRADO',
        'profile_fecha_nacimiento': prefs.getString('profile_fecha_nacimiento') ?? 'NO ENCONTRADO',
        'login_type': prefs.getString('login_type') ?? 'NO ENCONTRADO',
      };
    });
    
    print('🔍 DEBUG - Datos en SharedPreferences:');
    profileData.forEach((key, value) {
      print('  $key: $value');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEBUG - Datos del Perfil'),
        backgroundColor: const Color(0xFF7A45D1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: profileData.entries.map((entry) => 
          Card(
            child: ListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value),
              leading: Icon(
                entry.value == 'NO ENCONTRADO' ? Icons.error : Icons.check_circle,
                color: entry.value == 'NO ENCONTRADO' ? Colors.red : Colors.green,
              ),
            ),
          )
        ).toList(),
      ),
    );
  }
}
