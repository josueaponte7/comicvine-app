// Pantalla principal: lista de personajes con buscador.
// Sin texto: muestra personajes por defecto.
// Con texto: busca por nombre (con debounce para no saturar la API).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/character.dart';
import '../services/comicvine_service.dart';
import 'character_detail_screen.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  final ComicVineService _service = ComicVineService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Character>> _charactersFuture;
  Timer? _debounce; // temporizador para el debounce de la búsqueda

  @override
  void initState() {
    super.initState();
    // Carga inicial: personajes por defecto.
    _charactersFuture = _service.getCharacters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Se llama en cada cambio del texto, pero solo busca tras 500ms de pausa.
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        if (query.trim().isEmpty) {
          // Barra vacía: volvemos a los personajes por defecto.
          _charactersFuture = _service.getCharacters();
        } else {
          _charactersFuture = _service.searchCharacters(query);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personajes'),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar personaje...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // Botón para limpiar la búsqueda
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
                    : null,
              ),
            ),
          ),

          // La lista ocupa el resto del espacio
          Expanded(
            child: FutureBuilder<List<Character>>(
              future: _charactersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Algo salió mal:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final characters = snapshot.data ?? [];
                if (characters.isEmpty) {
                  return const Center(child: Text('No se encontraron personajes.'));
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CharacterDetailScreen(character: character),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}