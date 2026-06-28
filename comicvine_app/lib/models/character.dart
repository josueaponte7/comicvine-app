// Modelo de un personaje de Comic Vine.

class Character {
  final int id;
  final String name;
  final String deck;            // deck mostrado (traducido al español)
  final String? deckOriginal;   // deck en inglés, para el toggle del detalle
  final String? imageUrl;
  final String? imageUrlLarge;
  final String? description;    // descripción larga en HTML (en inglés)

  Character({
    required this.id,
    required this.name,
    required this.deck,
    this.deckOriginal,
    this.imageUrl,
    this.imageUrlLarge,
    this.description,
  });

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