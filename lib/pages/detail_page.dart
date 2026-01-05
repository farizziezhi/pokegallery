import 'package:flutter/material.dart';
import 'package:pokegallery/models/pokemon.dart';
import 'package:pokegallery/services/pokemon_service.dart';
import 'package:pokegallery/utils/type_colors.dart';

class DetailPage extends StatefulWidget {
  final Pokemon pokemon;

  const DetailPage({super.key, required this.pokemon});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final PokemonService _service = PokemonService();
  late Pokemon _pokemon;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pokemon = widget.pokemon;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final detail = await _service.fetchPokemonDetail(_pokemon.id);
      if(mounted) {
        setState(() {
          _pokemon = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = TypeColors.getColor(_pokemon.primaryType);
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          _pokemon.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(primaryColor),
          Expanded(
            child: _buildDetailSection(),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '#${_pokemon.id.toString().padLeft(3, '0')}', 
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Hero(
            tag: 'pokemon-${_pokemon.id}',
            child: Image.network(
              _pokemon.imageUrl,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.catching_pokemon,
                  size: 150,
                  color: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _pokemon.types.map((type) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: _isLoading ? const Center(
        child: CircularProgressIndicator()) : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16,),
              _buildAboutRow(),
              const SizedBox(height: 24,),
              const Text(
                'Abilities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8,),
              Wrap(
                spacing: 8,
                children: _pokemon.abilities.map((ability) {
                  return Chip(
                    label: Text(ability.replaceAll('-', ' ').toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24,),
              const Text(
                'Base Stats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16,),
              _buildStats(),
            ],
          ),
        ),
    );
  }

  Widget _buildAboutRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAboutItem(
          icon: Icons.straighten,
          label: 'Height',
          value: _pokemon.height != null ? '${(_pokemon.height! / 10).toStringAsFixed(1)} m' : '-',
        ),
        _buildAboutItem(
          icon: Icons.fitness_center,
          label: 'Weight',
          value: _pokemon.weight != null ? '${(_pokemon.weight! / 10).toStringAsFixed(1)} kg' : '-',
        ),
      ],
    );
  }

  Widget _buildAboutItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.grey[600]),
        const SizedBox(height: 4,),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final statNames = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'SATK',
      'special-defense': 'SDEF',
      'speed': 'SPD',
    };

    final primaryColor = TypeColors.getColor(_pokemon.primaryType);

    return Column(
      children: _pokemon.stats.entries.map((entry) {
        final statLabel = statNames[entry.key] ?? entry.key.toUpperCase();
        final statValue = entry.value;
        final percentage = (statValue / 255).clamp(0.0, 1.0);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  statLabel,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(
                  statValue.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(primaryColor),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}