import 'package:flutter/material.dart';

class DetailsCommandeCuisine extends StatelessWidget {
  final String type;
  final int? numeroTable;
  final List<Map<String, dynamic>> lignes;

  const DetailsCommandeCuisine({
    super.key,
    required this.type,
    required this.numeroTable,
    required this.lignes,
  });

  String get _labelType {
    switch (type) {
      case 'sur_place':
        return 'Sur place';
      case 'a_emporter':
        return 'À emporter';
      case 'livraison':
        return 'Livraison';
      default:
        return type;
    }
  }

  bool get _dansLeRestaurant => type == 'sur_place' || type == 'a_emporter';

  Widget _puce(IconData icone, String texte, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: couleur),
          const SizedBox(width: 4),
          Text(
            texte,
            style: TextStyle(color: couleur, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _puce(Icons.restaurant, _labelType, Colors.pink),
            if (_dansLeRestaurant)
              numeroTable != null
                  ? _puce(Icons.table_restaurant, 'Table $numeroTable', Colors.blue)
                  : _puce(Icons.warning_amber, 'Table non indiquée', Colors.orange),
          ],
        ),
        const SizedBox(height: 10),
        if (lignes.isEmpty)
          const Text('Aucun produit', style: TextStyle(color: Colors.grey))
        else
          for (final l in lignes)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Text(
                    '${l['quantite']} × ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink),
                  ),
                  Expanded(child: Text('${l['produitNom']}')),
                ],
              ),
            ),
      ],
    );
  }
}