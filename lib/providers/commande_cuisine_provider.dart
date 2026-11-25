import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pili_pili/controllers/commande_cuisine_controller.dart';
import 'package:pili_pili/providers/commande_provider.dart';
import 'package:pili_pili/models/commande.dart';

class CommandeCuisineProvider extends ChangeNotifier {
  final CommandeCuisineController _controller = CommandeCuisineController();

  List<Commande> _commandes = [];
  List<Commande> get commandesEnAttente =>
      _commandes.where((c) => c.statut == 'en_attente').toList();
  List<Commande> get commandesEnPreparation =>
      _commandes.where((c) => c.statut == 'en_preparation').toList();

  static const int _taillePage = 20;
  List<Commande> _terminees = [];
  List<Commande> get commandesTerminees => _terminees;

  int _totalTerminees = 0;
  int get totalTerminees => _totalTerminees;

  // Durées suggérées par commande (id -> minutes), issues de la requête
  final Map<int, int> _dureesSuggerees = {};
  int dureeSuggeree(int commandeId) => _dureesSuggerees[commandeId] ?? 10;

  // Détails affichés sur les cartes (clé = id de la commande)
  final Map<int, List<Map<String, dynamic>>> _lignes = {};
  final Map<int, int?> _numerosTable = {};
  List<Map<String, dynamic>> lignesPour(int commandeId) => _lignes[commandeId] ?? [];
  int? numeroTable(int commandeId) => _numerosTable[commandeId];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingTerminees = true;
  bool get isLoadingTerminees => _isLoadingTerminees;

  bool _isLoadingPlusTerminees = false;
  bool get isLoadingPlusTerminees => _isLoadingPlusTerminees;

  bool _paginationEnEchec = false;
  bool get resteTerminees => !_paginationEnEchec && _terminees.length < _totalTerminees;

  String? _curseurDate;
  int? _curseurId;

  void _memoriserCurseur(List<Map<String, dynamic>> maps) {
    if (maps.isEmpty) return;
    _curseurDate = maps.last['dateDebutPreparation'] as String?;
    _curseurId = maps.last['id'] as int?;
  }

  String? _erreur;
  String? get erreur => _erreur;
  void effacerErreur() => _erreur = null;

  CommandeProvider? _commandeProviderClient;

  // Commandes en cours de passage à "terminé" (évite de les traiter plusieurs fois)
  final Set<int> _enCoursDeTerminaison = {};

  Timer? _timer;

  CommandeCuisineProvider() {
    // Rafraîchit l'affichage du compte à rebours chaque seconde
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  // ⚠️ TEMPORAIRE — à remplacer par Supabase Realtime
  void lierCommandeProviderClient(CommandeProvider provider) {
    _commandeProviderClient = provider;
  }

  // Charge produits et numéro de table pour une liste de commandes
  Future<void> _chargerDetails(List<Map<String, dynamic>> maps) async {
    final ids = maps.map((m) => m['id'] as int).toList();
    final lignes = await _controller.chargerLignes(ids);

    for (final id in ids) {
      _lignes[id] = [];
    }
    for (final l in lignes) {
      _lignes[l['commandeId'] as int]?.add(l);
    }
    for (final m in maps) {
      _numerosTable[m['id'] as int] = m['tableNumero'] as int?;
    }
  }

  // silencieux = ne pas afficher le spinner (utile pour les rechargements en arrière-plan)
  Future<void> chargerCommandes({bool silencieux = false}) async {
    if (!silencieux) {
      _isLoading = true;
      _erreur = null;
      notifyListeners();
    }

    try {
      final maps = await _controller.chargerCommandesCuisine();
      _commandes = maps.map((m) => Commande.fromMap(m)).toList();

      _dureesSuggerees.clear();
      for (final m in maps) {
        _dureesSuggerees[m['id'] as int] = (m['dureeSuggereeMinutes'] as int?) ?? 10;
      }

      await _chargerDetails(maps);
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // premiere page
  Future<void> chargerTerminees({bool silencieux = false}) async {
    if (!silencieux) {
      _isLoadingTerminees = true;
      notifyListeners();
    }
    _paginationEnEchec = false;

    try {
      final maps = await _controller.chargerTerminees(limite: _taillePage);
      _totalTerminees = await _controller.compterTerminees();
      _terminees = maps.map((m) => Commande.fromMap(m)).toList();
      _memoriserCurseur(maps);
      await _chargerDetails(maps);
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isLoadingTerminees = false;
    notifyListeners();
  }

  //page suivante (appeler quand on approche du bas de la liste)
  Future<void> chargerPlusTerminees() async {
    if (_isLoadingPlusTerminees || !resteTerminees || _curseurDate == null) return;

    _isLoadingPlusTerminees = true;
    notifyListeners();

    try {
      final maps = await _controller.chargerTerminees(
        limite: _taillePage,
        curseurDate: _curseurDate,
        curseurId: _curseurId,
      );
      if (maps.isEmpty) {
        _totalTerminees = _terminees.length;
      } else {
        _terminees.addAll(maps.map((m) => Commande.fromMap(m)));
        _memoriserCurseur(maps);
        await _chargerDetails(maps);
      }
    } catch (e) {
      _paginationEnEchec = true;
      _erreur = "Erreur: $e";
    }
    _isLoadingPlusTerminees = false;
    notifyListeners();
  }

  Future<void> accepterCommande(int commandeId, int dureeMinutes) async {
    try {
      await _controller.accepterCommande(commandeId, dureeMinutes);
      await chargerCommandes(silencieux: true);
      _commandeProviderClient?.chargerCommandes(silencieux: true);
    } catch (e) {
      _erreur = "Erreur: $e";
      notifyListeners();
    }
  }

  void _tick() {
    final expirees = commandesEnPreparation
        .where((c) =>
    c.id != null && c.estExpiree && !_enCoursDeTerminaison.contains(c.id))
        .toList();

    if (expirees.isEmpty) {
      notifyListeners(); // rafraîchit seulement l'affichage des comptes à rebours
      return;
    }

    _terminerExpirees(expirees);
  }

  Future<void> _terminerExpirees(List<Commande> expirees) async {
    for (final c in expirees) {
      _enCoursDeTerminaison.add(c.id!);
    }

    try {
      for (final c in expirees) {
        await _controller.marquerTerminee(c.id!); // on attend la base avant de relire
      }
      await chargerCommandes(silencieux: true);
      await chargerTerminees(silencieux: true);
      _commandeProviderClient?.chargerCommandes(silencieux: true);
    } catch (e) {
      _erreur = "Erreur: $e";
      notifyListeners();
    } finally {
      for (final c in expirees) {
        _enCoursDeTerminaison.remove(c.id!);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}