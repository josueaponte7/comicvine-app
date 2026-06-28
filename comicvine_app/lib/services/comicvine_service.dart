// Servicio que habla con el Worker de Cloudflare (el proxy de Comic Vine).
// Trae personajes y traduce su deck al español antes de devolverlos.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import 'translation_service.dart';

class ComicVineService {
  static const String _baseUrl = 'https://proxy-comicvine.josueaponte.workers.dev';

  // Lista de personajes por defecto.
  Future<List<Character>> getCharacters({int limit = 20}) async {
    final url = Uri.parse('$_baseUrl/characters/?limit=$limit');
    return _pedirYTraducir(url);
  }

  // Búsqueda por nombre.
  Future<List<Character>> searchCharacters(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    final encoded = Uri.encodeComponent(query.trim());
    final url = Uri.parse('$_baseUrl/characters/?filter=name:$encoded&limit=$limit');
    return _pedirYTraducir(url);
  }

  // Lógica compartida: pide a la API, valida, parsea y traduce los decks.
  Future<List<Character>> _pedirYTraducir(Uri url) async {
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error de red: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    if (data['status_code'] != 1) {
      throw Exception('Error de Comic Vine: ${data['error']}');
    }

    final List<dynamic> results = data['results'] ?? [];
    final personajes = results.map((json) => Character.fromJson(json)).toList();
    return _traducirDecks(personajes);
  }

  // Traduce el deck de cada personaje al español.
  // Solo el deck; la descripción larga se traduce en el detalle al abrirlo.
  Future<List<Character>> _traducirDecks(List<Character> personajes) async {
    final traductor = TranslationService.instance;
    final traducidos = <Character>[];

    for (final p in personajes) {
      final deckEs = await traductor.traducir(p.deck);
      traducidos.add(Character(
        id: p.id,
        name: p.name,
        deck: deckEs,           // deck en español (lo que se muestra)
        deckOriginal: p.deck,   // deck en inglés (para el toggle del detalle)
        imageUrl: p.imageUrl,
        imageUrlLarge: p.imageUrlLarge,
        description: p.description,
      ));
    }
    return traducidos;
  }
}