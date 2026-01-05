import 'package:flutter/material.dart';
import 'package:pokegallery/models/pokemon.dart';
import 'package:pokegallery/pages/home_page.dart';
import 'package:pokegallery/services/pokemon_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PokemonService _service = PokemonService();
  String _loadingText = 'Loading Pokemons...';
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _loadAllPokemons();
  }

  Future<void> _loadAllPokemons() async {
    try {
      setState(() {
        _loadingText = 'Fetching Pokemon list...';
      });

      final pokemonList = await _service.fetchPokemonList(
        limit: 150,
        offset: 0,
      );

      final List<Pokemon> detailedPokemon = [];

      for (int i = 0; i < pokemonList.length; i++) {
        final pokemon = pokemonList[i];

        try {
          final detail = await _service.fetchPokemonDetail(pokemon.id);
          detailedPokemon.add(detail);
        } catch (e) {
          detailedPokemon.add(pokemon);
        }

        setState(() {
          _progress = (i + 1) / pokemonList.length;
          _loadingText = 'Loading Pokemon ${pokemon.name}...(${i + 1}/${pokemonList.length})';
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                preloadedPokemon: detailedPokemon,
              ),
            ),
          );
      }
    } catch (e) {
      setState(() {
        _loadingText = 'Failed to load Pokemons';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.catching_pokemon,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'PokeGallery',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _loadingText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}