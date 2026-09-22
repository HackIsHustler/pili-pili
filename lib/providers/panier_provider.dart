import 'package:flutter/material.dart';
import 'package:pili_pili/models/produit.dart';
import 'package:pili_pili/models/panier_item_model.dart';

class PanierProvider extends ChangeNotifier {
  final List<PanierItemModel> _items = [];
  List<PanierItemModel> get items => _items;

  String _typeCommande = 'a_emporter'; // 'sur_place' | 'a_emporter' | 'livraison'
  String get typeCommande => _typeCommande;

  String _adresseLivraison = '';
  String get adresseLivraison => _adresseLivraison;

  int get nombreArticles => _items.fold(0, (total, item) => total + item.quantite);

  int get total => _items.fold(0, (total, item) => total + item.sousTotal);

  void ajouterProduit(Produit produit) {
    final index = _items.indexWhere((item) => item.produit.id == produit.id);
    if (index != -1) {
      _items[index].quantite++;
    } else {
      _items.add(PanierItemModel(produit: produit));
    }
    notifyListeners();
  }

  void incrementerQuantite(int index) {
    _items[index].quantite++;
    notifyListeners();
  }

  void decrementerQuantite(int index) {
    if (_items[index].quantite > 1) {
      _items[index].quantite--;
      notifyListeners();
    }
  }

  void supprimerProduit(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void definirTypeCommande(String type) {
    _typeCommande = type;
    notifyListeners();
  }

  void definirAdresseLivraison(String adresse) {
    _adresseLivraison = adresse;
    notifyListeners();
  }

  void vider() {
    _items.clear();
    _typeCommande = 'a_emporter';
    _adresseLivraison = '';
    notifyListeners();
  }
}