import 'package:flutter/material.dart';
import 'screens/characters_screen.dart';
import 'services/translation_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comic Vine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Arranque(),
    );
  }
}

// Pantalla de arranque: prepara el modelo de traducción antes de mostrar la lista.
class Arranque extends StatefulWidget {
  const Arranque({super.key});

  @override
  State<Arranque> createState() => _ArranqueState();
}

class _ArranqueState extends State<Arranque> {
  late Future<void> _preparacion;

  @override
  void initState() {
    super.initState();
    _preparacion = TranslationService.instance.preparar();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _preparacion,
      builder: (context, snapshot) {
        // Mientras prepara el modelo: pantalla de carga.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparando traducción...'),
                ],
              ),
            ),
          );
        }

        // Listo (o falló la descarga): mostramos la lista igual.
        // Si el modelo no bajó, la app sigue usable en inglés.
        return const CharactersScreen();
      },
    );
  }
}