import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pili_pili/controllers/commande_cuisine_controller.dart';
import 'package:pili_pili/models/commande.dart';

class CommandeCuisineProvider extends ChangeNotifier {
  final CommandeCuisineController _controller = CommandeCuisineController();

  List<Commande> _commandes = [];
  List<Commande> get commandesEnAttente =>
      _commandes.where((c) => c.statut == 'en_attente').toList();
  List<Commande> get commandesEnPreparation =>
      _commandes.where((c) => c.statut == 'en_preparation').toList();

  // Durées suggérées par commande (id -> minutes), issues de la requête
  final Map<int, int> _dureesSuggerees = {};
  int dureeSuggeree(int commandeId) => _dureesSuggerees[commandeId] ?? 10;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _erreur;
  String? get erreur => _erreur;

  Timer? _timer;

  CommandeCuisineProvider() {
    // Rafraîchit l'affichage du countdown chaque seconde, et vérifie les expirations
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> chargerCommandes() async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      final maps = await _controller.chargerCommandesCuisine();
      _commandes = maps.map((m) => Commande.fromMap(m)).toList();
      _dureesSuggerees.clear();
      for (final m in maps) {
        if (m['id'] != null) {
          _dureesSuggerees[m['id']] = m['dureeSuggereeMinutes'] ?? 10;
        }
      }
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> accepterCommande(int commandeId, int dureeMinutes) async {
    try {
      await _controller.accepterCommande(commandeId, dureeMinutes);
      await chargerCommandes();
    } catch (e) {
      _erreur = "Erreur: $e";
      notifyListeners();
    }
  }

  // Vérifie chaque seconde si une commande en préparation est arrivée à 0
  void _tick() {
    bool changement = false;
    for (final commande in commandesEnPreparation) {
      if (commande.estExpiree && commande.id != null) {
        _controller.marquerTerminee(commande.id!);
        changement = true;
      }
    }
    if (changement) {
      chargerCommandes(); // recharge pour faire disparaître la commande terminée de la liste
    } else {
      notifyListeners(); // juste pour rafraîchir l'affichage des countdowns
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}