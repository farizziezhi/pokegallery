import 'package:flutter/material.dart';
import 'package:pokegallery/widgets/pokemon_card.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../utils/type_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PokemonService _pokemonService = PokemonService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Pokemon> _pokemonList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _offset = 0;
  final int _limit = 20;

  String _searchQuery = '';
  String? _selectedType;

  final List<String> _typeFilters = [
    'fire',
    'water',
    'grass',
    'electric',
    'psychic',
    'ice',
    'dragon',
    'dark',
    'fairy',
    'normal',
    'fighting',
    'flying',
    'poison',
    'ground',
    'rock',
    'bug',
    'ghost',
    'steel',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPokemon();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Pokemon> get _filteredPokemonList {
    return _pokemonList.where((pokemon) {
      final matchesSearch = pokemon.name.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType = _selectedType == null || pokemon.types.contains(_selectedType);

      return matchesSearch && matchesType;
    }).toList();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ) : null,
                hintText: 'Search Pokemon',
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedType == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = null;
                      });
                    },
                    selectedColor: Colors.teal.withValues(alpha: 0.3),
                  ),
                ),
                ..._typeFilters.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        type[0].toUpperCase() + type.substring(1),
                      ),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = selected ? type : null;
                        });
                      },
                      selectedColor: TypeColors.getColor(type).withValues(alpha: 0.3),
                      avatar: _selectedType == type ? null : CircleAvatar(
                        backgroundColor: TypeColors.getColor(type),
                        radius: 8,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8,),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
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

    final filtered = _filteredPokemonList;
    if(filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.catching_pokemon, color: Colors.grey[400], size: 64),
            SizedBox(height: 16),
            Text('No Pokemon Found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            if(_searchQuery.isNotEmpty || _selectedType != null)
              TextButton(onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedType = null;
                });
              }, child: const Text('Clear Filters')),
          ],
        ),
      );
    }

    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final pokemon = filtered[index];
                return PokemonCard(
                  pokemon: pokemon,
                  onDetailLoaded: (updatedPokemon) {
                    final index = _pokemonList.indexWhere((p) => p.id == updatedPokemon.id);
                    if(index != -1) {
                      setState(() {
                        _pokemonList[index] = updatedPokemon;
                      });
                    }
                  },
                );
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