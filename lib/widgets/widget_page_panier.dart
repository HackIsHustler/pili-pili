import 'dart:io';
import 'package:flutter/material.dart';
import '../style/style.dart';

class PanierItem extends StatelessWidget {
  final String nom;
  final int prix;
  final int quantite;
  final String imageUrl; // ✅ ajouté
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const PanierItem({
    super.key,
    required this.nom,
    required this.prix,
    required this.quantite,
    required this.imageUrl, // ✅ ajouté
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  Widget _construireImage() {
    final file = File(imageUrl);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.grey, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _construireImage(), // ✅ remplace l'ancien Container fixe

            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$prix fcfa',
                    style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: onDecrement,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: const Center(
                      child: Text('-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$quantite', style: StyleApplication.taillTextSimple),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onIncrement,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(8)),
                    child: const Center(
                      child: Text('+', style: StyleApplication.textSurBagde),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}