// Detalle del personaje. Español por defecto:
// - el deck ya viene traducido desde el servicio
// - la descripción larga se traduce aquí al abrir la pantalla
// Un botón permite alternar entre español e inglés (original).

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/character.dart';
import '../services/translation_service.dart';

class CharacterDetailScreen extends StatefulWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  bool _mostrarOriginal = false; // false = español (por defecto), true = inglés
  bool _traduciendo = true;      // traduciendo la descripción al abrir

  String? _descripcionEs; // descripción traducida (texto plano)

  @override
  void initState() {
    super.initState();
    _traducirDescripcion();
  }

  // Quita etiquetas HTML para poder traducir texto plano.
  String _limpiarHtml(String html) {
    final sinEtiquetas = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return sinEtiquetas.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _traducirDescripcion() async {
    final desc = widget.character.description;
    if (desc == null || desc.isEmpty) {
      setState(() => _traduciendo = false);
      return;
    }
    try {
      final es = await TranslationService.instance.traducir(_limpiarHtml(desc));
      if (!mounted) return;
      setState(() {
        _descripcionEs = es;
        _traduciendo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _traduciendo = false); // si falla, mostramos el original
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: FilledButton.icon(
              onPressed: () =>
                  setState(() => _mostrarOriginal = !_mostrarOriginal),
              icon: const Icon(Icons.translate, size: 18),
              label: Text(_mostrarOriginal ? 'Español' : 'Original'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.imageUrlLarge != null)
              CachedNetworkImage(
                imageUrl: c.imageUrlLarge!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  height: 300,
                  child: Icon(Icons.person, size: 100),
                ),
              )
            else
              const SizedBox(height: 300, child: Icon(Icons.person, size: 100)),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),

                  // Deck: español (c.deck) o inglés (c.deckOriginal) según el toggle.
                  Text(
                    _mostrarOriginal
                        ? (c.deckOriginal ?? c.deck)
                        : c.deck,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Divider(height: 32),

                  // Descripción larga.
                  _construirDescripcion(c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirDescripcion(Character c) {
    // Modo original: HTML renderizado en inglés.
    if (_mostrarOriginal) {
      if (c.description != null && c.description!.isNotEmpty) {
        return Html(data: c.description!);
      }
      return const Text('No hay descripción detallada disponible.');
    }

    // Modo español: mientras traduce, spinner.
    if (_traduciendo) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Traduciendo...'),
        ],
      );
    }

    // Español listo (texto plano) o aviso si no había descripción.
    return Text(_descripcionEs ?? 'No hay descripción detallada disponible.');
  }
}