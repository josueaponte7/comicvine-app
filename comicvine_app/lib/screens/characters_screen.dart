// Pantalla principal: lista de personajes de Comic Vine.
// Maneja tres estados: cargando, error y datos listos.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/character.dart';
import '../services/comicvine_service.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  final ComicVineService _service = ComicVineService();
  late Future<List<Character>> _charactersFuture;

  @override
  void initState() {
    super.initState();
    // Lanzamos la petición una sola vez, al crear la pantalla.
    _charactersFuture = _service.getCharacters();
  }

  // Vuelve a pedir los datos (para el botón de reintentar).
  void _reload() {
    setState(() {
      _charactersFuture = _service.getCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personajes'),
      ),
      body: FutureBuilder<List<Character>>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          // Estado 1: esperando respuesta.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado 2: algo falló.
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Algo salió mal:\n${snapshot.error}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Estado 3: datos listos.
          final characters = snapshot.data ?? [];
          if (characters.isEmpty) {
            return const Center(child: Text('No hay personajes.'));
          }

          return ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return ListTile(
                leading: character.imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: character.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                  const SizedBox(width: 56, height: 56),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.person),
                )
                    : const Icon(Icons.person, size: 56),
                title: Text(character.name),
                subtitle: Text(
                  character.deck,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ),
    );
  }
}