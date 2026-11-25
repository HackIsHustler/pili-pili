import 'package:flutter/material.dart';
import 'package:pili_pili/models/produit.dart';
import 'package:pili_pili/models/panier_item_model.dart';
import 'package:pili_pili/models/table.dart';
import 'package:pili_pili/controllers/table_controller.dart';

class PanierProvider extends ChangeNotifier {
  final TableController _tableController = TableController();
  final List<PanierItemModel> _items = [];
  List<PanierItemModel> get items => _items;

  String _typeCommande = 'a_emporter'; // 'sur_place' | 'a_emporter' | 'livraison'
  String get typeCommande => _typeCommande;

  String _adresseLivraison = '';
  String get adresseLivraison => _adresseLivraison;

  //recupere la liste des tables pour le choix de la table
  List<TableRestaurant> _tables = [];
  List<TableRestaurant> get tables => _tables;

  int? _tableId;
  int? get tableId => _tableId;

  PanierProvider() {
    _chargerTables();
  }

  Future<void> _chargerTables() async {
    try {
      final tables = await _tableController.chargerTables();
      tables.sort((a, b) => a.numero.compareTo(b.numero));
      _tables = tables;
      notifyListeners();
    } catch (_) {
      // silencieux si ca echoue, le dropdown sera juste vide pas bloquant
    }
  }

  int get nombreArticles => _items.fold(0, (total, item) => total + item.quantite);

  int get total => _items.fold(0, (total, item) => total + item.sousTotal);

  bool get necessiteTable => _typeCommande == 'sur_place' || _typeCommande == 'a_emporter';

  bool get peutPasserCommande => _items.isNotEmpty && (!necessiteTable || _tableId != null);

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
    if (type == 'livraison') {
      _tableId = null; // pas de table pour livraison
    }
    notifyListeners();
  }

  void definirAdresseLivraison(String adresse) {
    _adresseLivraison = adresse;
    notifyListeners();
  }
  void definirTableId(int? tableId) {
    _tableId = tableId;
    notifyListeners();
  }

  void vider() {
    _items.clear();
    _typeCommande = 'a_emporter';
    _adresseLivraison = '';
    notifyListeners();
  }
}