class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final uri = Uri.parse(url);
    final id = int.parse(uri.pathSegments[uri.pathSegments.length - 2]);

    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return Pokemon(
      id: id,
      name: json['name'] as String,
      imageUrl: imageUrl,
    );
  }

  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }
}