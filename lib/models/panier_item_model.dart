import 'package:pili_pili/models/produit.dart';

class PanierItemModel {
  final Produit produit;
  int quantite;

  PanierItemModel({
    required this.produit,
    this.quantite = 1,
  });

  int get sousTotal => (produit.prix * quantite).toInt();
}