import 'package:flutter/material.dart';

class FavorisItem extends StatelessWidget {
  final String nom;
  final int prix;
  final int likes;

  const FavorisItem({
    super.key,
    required this.nom,
    required this.prix,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image, color: Colors.grey),
        ),
        title: Text(
          nom,
        ),
        subtitle: Text(
          '$prix fcfa',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              '$likes',
            ),
          ],
        ),
      ),
    );
  }
}