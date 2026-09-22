import 'package:flutter/material.dart';
import 'package:pili_pili/controllers/categorie_controller.dart';
import 'package:pili_pili/models/categorie.dart';

class CategorieProvider extends ChangeNotifier {
  final CategorieController _controller = CategorieController();

  List<Categorie> _categories = [];
  List<Categorie> get categories => _categories;

  int? _categorieSelectionneeId; // null = "Tout"
  int? get categorieSelectionneeId => _categorieSelectionneeId;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _erreur;
  String? get erreur => _erreur;

  Future<void> chargerCategories() async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      _categories = await _controller.chargerCategories();
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectionnerCategorie(int? id) {
    _categorieSelectionneeId = id;
    notifyListeners();
  }
}