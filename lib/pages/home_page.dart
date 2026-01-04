import 'package:flutter/material.dart';
import 'package:pokegallery/widgets/pokemon_card.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PokemonService _pokemonService = PokemonService();

  List<Pokemon> _pokemonList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPokemon();
  }

  Future<void> _fetchPokemon() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final pokemons = await _pokemonService.fetchPokemonList();

      setState(() {
        _pokemonList = pokemons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Pokemon...'),
          ],
        )
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text('Gagal memuat data', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(_errorMessage!, style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPokemon,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: _pokemonList.length,
        itemBuilder: (context, index) {
          final pokemon = _pokemonList[index];
          return PokemonCard(pokemon: pokemon);
        },
      )
    );
  }
}