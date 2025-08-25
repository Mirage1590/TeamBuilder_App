enum PokemonType {
  grass,
  fire,
  water,
  electric,
  normal,
  psychic,
  fairy,
  fighting,
  flying,
  poison,
  ground,
  rock,
  bug,
  ghost,
  steel,
  ice,
  dragon,
  dark
}

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<PokemonType> types; // เพิ่ม field ธาตุ

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [], // default เป็นว่าง
  });

  factory Pokemon.fromListResult(Map<String, dynamic> raw) {
    final uri = Uri.parse(raw['url'] as String);
    final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final id = int.parse(segs.last);
    final name = (raw['name'] as String).toLowerCase();
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
    // ธาตุควรดึงจาก raw['types'] ถ้ามีข้อมูล
    return Pokemon(id: id, name: name, imageUrl: imageUrl);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'types': types.map((t) => t.name).toList(), // serialize ธาตุ
      };

  factory Pokemon.fromJson(Map<String, dynamic> json) => Pokemon(
        id: json['id'] as int,
        name: json['name'] as String,
        imageUrl: json['imageUrl'] as String,
        types: (json['types'] as List<dynamic>? ?? [])
            .map((e) => PokemonType.values.firstWhere(
                  (t) => t.name == e,
                  orElse: () => PokemonType.normal,
                ))
            .toList(),
      );
}
