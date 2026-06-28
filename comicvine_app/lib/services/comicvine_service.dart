// Servicio que habla con el Worker de Cloudflare (el proxy de Comic Vine).
// La UI le pide datos a esta clase; nunca toca URLs ni JSON directamente.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';

class ComicVineService {
  // URL pública de tu Worker. Todas las peticiones pasan por aquí.
  static const String _baseUrl = 'https://proxy-comicvine.josueaponte.workers.dev';

  // Trae una lista de personajes.
  // [limit] controla cuántos pedimos de golpe.
  Future<List<Character>> getCharacters({int limit = 20}) async {
    // Construimos la URL hacia el Worker. El Worker ya añade la clave y format=json.
    final url = Uri.parse('$_baseUrl/characters/?limit=$limit');

    final response = await http.get(url);

    // Si el Worker o Comic Vine no respondieron con 200, fallamos claro.
    if (response.statusCode != 200) {
      throw Exception('Error de red: ${response.statusCode}');
    }

    // Convertimos el texto de la respuesta en un mapa Dart.
    final Map<String, dynamic> data = json.decode(response.body);

    // Comic Vine usa status_code:1 para "OK". Cualquier otra cosa es un error suyo.
    if (data['status_code'] != 1) {
      throw Exception('Error de Comic Vine: ${data['error']}');
    }

    // 'results' es la lista de personajes en bruto. Mapeamos cada uno a Character.
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Character.fromJson(json)).toList();
  }

  // Busca personajes por nombre.
  // Usa el filtro de Comic Vine: filter=name:loquesea
  Future<List<Character>> searchCharacters(String query, {int limit = 20}) async {
    // Si la búsqueda está vacía, no llamamos a la red: devolvemos lista vacía.
    if (query.trim().isEmpty) return [];

    // Uri.encodeComponent escapa espacios y caracteres raros del nombre.
    final encoded = Uri.encodeComponent(query.trim());
    final url = Uri.parse('$_baseUrl/characters/?filter=name:$encoded&limit=$limit');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error de red: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    if (data['status_code'] != 1) {
      throw Exception('Error de Comic Vine: ${data['error']}');
    }

    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Character.fromJson(json)).toList();
  }
}