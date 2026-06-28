// Pantalla de detalle de un personaje.
// Recibe un Character ya cargado (no hace nueva llamada de red)
// y muestra imagen grande, nombre, resumen y descripción larga en HTML.

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/character.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen grande, ancho completo. Si no hay, un placeholder.
            if (character.imageUrlLarge != null)
              CachedNetworkImage(
                imageUrl: character.imageUrlLarge!,
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
              const SizedBox(
                height: 300,
                child: Icon(Icons.person, size: 100),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  // Resumen corto (deck)
                  Text(
                    character.deck,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Divider(height: 32),

                  // Descripción larga: HTML renderizado, o un aviso si no hay.
                  if (character.description != null &&
                      character.description!.isNotEmpty)
                    Html(data: character.description!)
                  else
                    const Text('No hay descripción detallada disponible.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}