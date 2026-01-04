import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  Future<List<Pokemon>> fetchPokemonList({int limit = 100}) async {
   try {
    final response = await http.get(Uri.parse('$_baseUrl?limit=$limit'));

    if(response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      return results.map((json) => Pokemon.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Pokemon list: ${response.statusCode}');
    }
   } catch (e) {
    throw Exception('Failed to load Pokemon list: $e');
   } 
  }
}