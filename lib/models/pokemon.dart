class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  final int? height;
  final int? weight;
  final List<String> abilities;
  final Map<String, int> stats;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
    this.height,
    this.weight,
    this.abilities = const [],
    this.stats = const {},
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
      types: [],
    );
  }

  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    final id = json['id'] as int;

    final typesData = json['types'] as List<dynamic>;
    final types = typesData.map((t) => t['type']['name'] as String).toList();

    final abilitiesData = json['abilities'] as List<dynamic>;
    final abilities = abilitiesData.map((a) => a['ability']['name'] as String).toList();

    final statsData = json['stats'] as List<dynamic>;
    final stats = <String, int>{};
    for(var stat in statsData) {
      final statName = stat['stat']['name'] as String;
      final baseStat = stat['base_stat'] as int;
      stats[statName] = baseStat;
    }

    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return Pokemon(
      id: id,
      name: json['name'] as String,
      imageUrl: imageUrl,
      types: types,
      abilities: abilities,
      stats: stats,
      height: json['height'] as int,
      weight: json['weight'] as int,
    );
  }

  Pokemon copyWithTypes(List<String> newTypes) {
    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: newTypes,
    );
  }

  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  String get primaryType => types.isNotEmpty ? types.first : 'normal';
}