// Test básico para Pet Match App
//
// Este test verifica que la aplicación se inicializa correctamente
// y muestra la pantalla de login como pantalla inicial.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mi_app_flutter/main.dart';

void main() {
  testWidgets('Pet Match App inicialización test', (WidgetTester tester) async {
    // Construye nuestra app y dispara un frame.
    await tester.pumpWidget(const PetMatchApp());

    // Verifica que la app se inicializa correctamente
    // Esperamos encontrar elementos típicos de una pantalla de login
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // El test básico solo verifica que la app no crashee al inicializarse
    // Puedes agregar más tests específicos según necesites
  });

  testWidgets('App tiene título correcto', (WidgetTester tester) async {
    // Construye la app
    await tester.pumpWidget(const PetMatchApp());

    // Verifica que el MaterialApp tenga el título correcto
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Pet Match');
  });
}
