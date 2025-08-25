import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  final http.Client _client = http.Client();

  Future<List<Pokemon>> fetchPokemonList({int limit = 150}) async {
    final uri = Uri.https('pokeapi.co', '/api/v2/pokemon', {
      'limit': '$limit',
      'offset': '0',
    });
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('PokeAPI error: ${res.statusCode}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final List results = data['results'] as List;

    // ดึงรายละเอียดแต่ละตัว (รวม types)
    final pokemons = <Pokemon>[];
    for (final e in results) {
      final detailRes = await _client.get(Uri.parse(e['url']));
      if (detailRes.statusCode == 200) {
        final detail = json.decode(detailRes.body) as Map<String, dynamic>;
        final types = (detail['types'] as List)
            .map((t) => t['type']['name'] as String)
            .map((name) => _typeFromName(name))
            .whereType<PokemonType>()
            .toList();
        final id = detail['id'] as int;
        final name = (detail['name'] as String).toLowerCase();
        final imageUrl =
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
        pokemons.add(Pokemon(
          id: id,
          name: name,
          imageUrl: imageUrl,
          types: types,
        ));
      }
    }
    return pokemons;
  }

  PokemonType? _typeFromName(String name) {
    switch (name) {
      case 'grass':
        return PokemonType.grass;
      case 'fire':
        return PokemonType.fire;
      case 'water':
        return PokemonType.water;
      case 'electric':
        return PokemonType.electric;
      case 'normal':
        return PokemonType.normal;
      case 'psychic':
        return PokemonType.psychic;
      case 'fairy':
        return PokemonType.fairy;
      case 'fighting':
        return PokemonType.fighting;
      case 'flying':
        return PokemonType.flying;
      case 'poison':
        return PokemonType.poison;
      case 'ground':
        return PokemonType.ground;
      case 'rock':
        return PokemonType.rock;
      case 'bug':
        return PokemonType.bug;
      case 'ghost':
        return PokemonType.ghost;
      case 'steel':
        return PokemonType.steel;
      case 'ice':
        return PokemonType.ice;
      case 'dragon':
        return PokemonType.dragon;
      case 'dark':
        return PokemonType.dark;
      default:
        return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
