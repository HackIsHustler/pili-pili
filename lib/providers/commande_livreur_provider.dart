import 'package:flutter/material.dart';
import 'package:pili_pili/controllers/commande_livreur_controller.dart';

class CommandeLivreurProvider extends ChangeNotifier {
  final CommandeLivreurController _controller = CommandeLivreurController();

  List<Map<String, dynamic>> _commandes = [];
  List<Map<String, dynamic>> get commandes => _commandes;
  List<Map<String, dynamic>> _historique = [];
  List<Map<String, dynamic>> get historique => _historique;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _erreur;
  String? get erreur => _erreur;
  void effacerErreur() => _erreur = null;

  Future<void> chargerCommandes() async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      _commandes = await _controller.chargerCommandesALivrer();
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // true = statut changé ; false = l'état de la commande avait changé entre-temps
  Future<bool> demarrerLivraison(int commandeId) async {
    final succes = await _controller.demarrerLivraison(commandeId);
    await chargerCommandes();
    return succes;
  }

  Future<bool> marquerLivree(int commandeId) async {
    final succes = await _controller.marquerLivree(commandeId);
    await chargerCommandes();
    await chargerHistorique(silencieux: true);
    return succes;
  }

  // ---------- Historique paginé ----------
  static const int _taillePage = 20;

// Calculés en SQL sur TOUT l'historique, pas sur la liste chargée
  int _nombreLivraisons = 0;
  int get nombreLivraisons => _nombreLivraisons;

  int _totalLivre = 0;
  int get totalLivre => _totalLivre;

  bool _isLoadingHistorique = true;
  bool get isLoadingHistorique => _isLoadingHistorique;

  bool _isLoadingPlusHistorique = false;
  bool _paginationEnEchec = false;

  bool get resteHistorique =>
      !_paginationEnEchec && _historique.length < _nombreLivraisons;

  String? _curseurDate;
  int? _curseurId;

  void _memoriserCurseur(List<Map<String, dynamic>> maps) {
    if (maps.isEmpty) return;
    _curseurDate = maps.last['created_at'] as String?;
    _curseurId = maps.last['id'] as int?;
  }

// Première page + totaux (réinitialise la liste)
  Future<void> chargerHistorique({bool silencieux = false}) async {
    if (!silencieux) {
      _isLoadingHistorique = true;
      notifyListeners();
    }
    _paginationEnEchec = false;

    try {
      final maps = await _controller.chargerHistorique(limite: _taillePage);
      final stats = await _controller.chargerStatsHistorique();
      _historique = maps;
      _nombreLivraisons = stats['nombre']!;
      _totalLivre = stats['somme']!;
      _memoriserCurseur(maps);
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isLoadingHistorique = false;
    notifyListeners();
  }

// Page suivante, appelée par ChargeurDeSuite
  Future<void> chargerPlusHistorique() async {
    if (_isLoadingPlusHistorique || !resteHistorique || _curseurDate == null) return;

    _isLoadingPlusHistorique = true;

    try {
      final maps = await _controller.chargerHistorique(
        limite: _taillePage,
        curseurDate: _curseurDate,
        curseurId: _curseurId,
      );

      if (maps.isEmpty) {
        _paginationEnEchec = true; // plus rien à charger malgré le compteur : on arrête
      } else {
        _historique = [..._historique, ...maps];
        _memoriserCurseur(maps);
      }
    } catch (e) {
      _paginationEnEchec = true;
      _erreur = "Erreur: $e";
    }

    _isLoadingPlusHistorique = false;
    notifyListeners();
  }

}