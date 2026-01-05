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
  final ScrollController _scrollController = ScrollController();

  List<Pokemon> _pokemonList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchPokemon();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _fetchMorePokemon();
    }
  }

  Future<void> _fetchPokemon() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _offset = 0;
      });

      final pokemons = await _pokemonService.fetchPokemonList(limit: _limit, offset: 0);

      setState(() {
        _pokemonList = pokemons;
        _isLoading = false;
        _offset = _limit;
        _hasMore = pokemons.length == _limit;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchMorePokemon() async {
    if(_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final pokemons = await _pokemonService.fetchPokemonList(limit: _limit, offset: _offset);

      setState(() {
        _pokemonList.addAll(pokemons);
        _offset += _limit;
        _hasMore = pokemons.length == _limit;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
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
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: _pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = _pokemonList[index];
                return PokemonCard(pokemon: pokemon);
              },
            ),
          ),
          if(_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}