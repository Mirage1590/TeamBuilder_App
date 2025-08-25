import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/pokemon.dart';

class PokemonTile extends StatelessWidget {
  final Pokemon pokemon;
  final bool selected;
  final VoidCallback onTap;

  const PokemonTile({
    super.key,
    required this.pokemon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: selected
              ? [Colors.white, cs.primaryContainer.withOpacity(.7)]
              : [Colors.white, Colors.white],
        ),
        border: Border.all(
          width: selected ? 2 : 1,
          color: selected ? cs.primary : cs.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: selected ? 12 : 6,
            spreadRadius: 0,
            offset: const Offset(0, 3),
            color: cs.primary.withOpacity(selected ? .20 : .08),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56, height: 56,
              child: CachedNetworkImage(
                imageUrl: pokemon.imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (_, __) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                errorWidget: (_, __, ___) => const Icon(Icons.catching_pokemon),
            ),
          ),
        ),
        title: Text(
          _capitalize(pokemon.name),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: selected ? cs.primary : cs.onSurface,
          ),
        ),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: selected
              ? const Icon(Icons.check_circle, key: ValueKey('yes'))
              : Opacity(
                  opacity: 0.35,
                  child: const Icon(Icons.radio_button_unchecked, key: ValueKey('no')),
                ),
          ),
        )
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}