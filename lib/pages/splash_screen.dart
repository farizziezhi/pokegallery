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
        _progress = 0.3;
      });

      final pokemonList = await _service.fetchPokemonList(
        limit: 1025,
        offset: 0,
      );

      setState(() {
        _progress = 0.5;
        _loadingText = '${pokemonList.length} Pokemons found!';
      });

      final List<Pokemon> detailedPokemon = List.from(pokemonList);
      int loadedCount = 0;

      bool shouldStop = false;

      Future.delayed(const Duration(seconds: 8), () {
        shouldStop = true;
      });

      const batchSize = 20;
      for (int i = 0; i < pokemonList.length && !shouldStop; i += batchSize) {
        final end = (i + batchSize < pokemonList.length) ? i + batchSize : pokemonList.length;
        final batch = pokemonList.sublist(i, end);

        final batchResults = await Future.wait(
          batch.map((pokemon) async {
            try {
              return await _service.fetchPokemonDetail(pokemon.id);
            } catch (e) {
              return pokemon;
            }
          }),
        );

        for(int j = 0; j < batchResults.length; j++) {
          detailedPokemon[i + j] = batchResults[j];
        }

        loadedCount += batchResults.length;
        setState(() {
          _progress = 0.5 + (loadedCount / pokemonList.length) * 0.5;
          _loadingText = 'Loading Pokemon details...';
        });
      }

      setState(() {
        _progress = 1;
        _loadingText = shouldStop ? 'Loading stopped' : 'Loading completed';
      });

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _loadingText = 'Preparing gallery...';
      });

      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                preloadedPokemon: pokemonList,
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