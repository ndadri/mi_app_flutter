import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GlobalConfigPanel extends StatefulWidget {
  const GlobalConfigPanel({Key? key}) : super(key: key);

  @override
  State<GlobalConfigPanel> createState() => _GlobalConfigPanelState();
}

class _GlobalConfigPanelState extends State<GlobalConfigPanel> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  // Parámetros globales
  int maxImageSize = 2048;
  String termsText = '';
  bool featureEnabled = true;

  Future<void> fetchConfig() async {
    setState(() { _loading = true; });
    try {
      final response = await http.get(Uri.parse('http://localhost:3002/config/global'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final config = data['config'] ?? {};
        setState(() {
          maxImageSize = config['max_image_size'] ?? 2048;
          termsText = config['terms_text'] ?? '';
          featureEnabled = config['features_enabled'] == true || config['features_enabled'] == 'true';
        });
      } else {
        setState(() { _error = 'Error al obtener configuración.'; });
      }
    } catch (e) {
      setState(() { _error = 'Error de red: $e'; });
    }
    setState(() { _loading = false; });
  }

  Future<void> saveConfig() async {
    setState(() { _loading = true; });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3002/config/global'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'max_image_size': maxImageSize,
          'terms_text': termsText,
          'features_enabled': featureEnabled,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada')),
        );
      } else {
        setState(() { _error = 'Error al guardar configuración.'; });
      }
    } catch (e) {
      setState(() { _error = 'Error de red: $e'; });
    }
    setState(() { _loading = false; });
  }

  @override
  void initState() {
    super.initState();
    fetchConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Configuración Global')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      initialValue: maxImageSize.toString(),
                      decoration: const InputDecoration(labelText: 'Tamaño máximo de imagen (KB)'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() { maxImageSize = int.tryParse(val) ?? 2048; });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: termsText,
                      decoration: const InputDecoration(labelText: 'Términos y condiciones'),
                      maxLines: 5,
                      onChanged: (val) {
                        setState(() { termsText = val; });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Función especial activada'),
                      value: featureEnabled,
                      onChanged: (val) {
                        setState(() { featureEnabled = val; });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: saveConfig,
                      child: const Text('Guardar configuración'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
