import 'package:flutter/material.dart';
import 'package:pokegallery/services/pokemon_service.dart';
import 'package:pokegallery/utils/type_colors.dart';
import '../models/pokemon.dart';

class PokemonCard extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
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
          _isLoading = false;
          _pokemon = detail;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final backgroundColor = TypeColors.getBackgroundColor(_pokemon.primaryType);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.network(
                    _pokemon.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.catching_pokemon,
                        size: 64,
                        color: Colors.grey,
                      );
                    },
                  )
                )
              ),
              Text(
                _pokemon.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4,),
              _isLoading ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ) 
                : Wrap(
                  spacing: 4,
                  children: _pokemon.types.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: TypeColors.getColor(type),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              const SizedBox(height: 12,),
              
            ],
          ),
        ),
      ),
    );
  }
}