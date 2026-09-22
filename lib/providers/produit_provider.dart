// providers/produit_provider.dart
import 'package:flutter/material.dart';
import 'package:pili_pili/controllers/produit_controller.dart';
import 'package:pili_pili/models/produit.dart';

class ProduitProvider extends ChangeNotifier {
  final ProduitController _controller = ProduitController();

  List<Produit> _produits = [];
  List<Produit> get produits => _produits;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _erreur;
  String? get erreur => _erreur;

  // État des likes par produit, tenu en mémoire pour un accès instantané dans l'UI
  final Map<int, bool> _likesEtat = {};
  bool estLikeCharge(int produitId) => _likesEtat[produitId] ?? false;
  bool estLikeConnu(int produitId) => _likesEtat.containsKey(produitId);

  Future<void> chargerProduits() async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      _produits = await _controller.chargerProduitsParPopularite();
      // Précharge l'état de like de chaque produit
      for (final produit in _produits) {
        if (produit.id != null) {
          _likesEtat[produit.id!] = await _controller.estLike(produit.id!);
        }
      }
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(int produitId) async {
    final etaitLike = _likesEtat[produitId] ?? false;

    // Mise à jour optimiste
    _likesEtat[produitId] = !etaitLike;
    _mettreAJourCompteurLocal(produitId, etaitLike ? -1 : 1);
    notifyListeners();

    try {
      if (etaitLike) {
        await _controller.retirerLike(produitId);
      } else {
        await _controller.liker(produitId);
      }
    } catch (e) {
      // Rollback en cas d'erreur
      _likesEtat[produitId] = etaitLike;
      _mettreAJourCompteurLocal(produitId, etaitLike ? 1 : -1);
      _erreur = "Erreur: $e";
      notifyListeners();
    }
  }

  void _mettreAJourCompteurLocal(int produitId, int delta) {
    final index = _produits.indexWhere((p) => p.id == produitId);
    if (index != -1) {
      final produit = _produits[index];
      produit.nombreLikes = (produit.nombreLikes ?? 0) + delta;
    }
  }

  List<Produit> produitsFiltres(int? categorieId) {
    if (categorieId == null) return _produits;
    return _produits.where((p) => p.categorieId == categorieId).toList();
  }
}