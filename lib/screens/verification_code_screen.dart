import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'new_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyCode() async {
    String code = _controllers.map((controller) => controller.text).join();
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el código completo'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.24:3002/api/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'code': code,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${data['message']}'),
            duration: const Duration(seconds: 1),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(
              email: widget.email,
              resetToken: data['resetToken'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${data['message']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 1),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header morado con bordes inferiores redondeados
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF7A45D1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 28),
              child: const Text(
                'Pet Match',
                style: TextStyle(
                  fontFamily: 'AntonSC',
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Card blanca con el formulario de verificación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Verificación de código',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ingresa el código de 6 dígitos que enviamos a ${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Fila de cajas de código
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 45,
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _controllers[index].text.isNotEmpty
                                  ? const Color(0xFF7A45D1)
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: KeyboardListener(
                            focusNode: FocusNode(),
                            onKeyEvent: (event) => _onKeyEvent(event, index),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              onChanged: (value) {
                                setState(() {});
                                _onDigitChanged(value, index);
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    // Botón de verificar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A45D1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _verifyCode,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Verificar código',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
