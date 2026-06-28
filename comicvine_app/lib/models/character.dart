// Modelo de un personaje de Comic Vine.
// Convierte el JSON crudo de la API en un objeto Dart con campos claros.

class Character {
  final int id;
  final String name;
  final String deck;
  final String? imageUrl;       // imagen mediana, para la lista
  final String? imageUrlLarge;  // imagen grande, para el detalle
  final String? description;    // descripción larga en HTML, para el detalle

  Character({
    required this.id,
    required this.name,
    required this.deck,
    this.imageUrl,
    this.imageUrlLarge,
    this.description,
  });

  // Construye un Character desde el mapa JSON de un resultado de la API.
  // Tolera campos ausentes o nulos: la API no siempre los trae todos.
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      deck: json['deck'] ?? 'Sin descripción disponible.',
      imageUrl: json['image']?['medium_url'],
      imageUrlLarge: json['image']?['super_url'],
      description: json['description'],
    );
  }
}