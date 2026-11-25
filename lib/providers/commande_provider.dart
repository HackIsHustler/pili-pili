import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pili_pili/controllers/commande_controller.dart';
import 'package:pili_pili/providers/notification_provider.dart';
import 'package:pili_pili/models/panier_item_model.dart';

class CommandeProvider extends ChangeNotifier {
  final CommandeController _controller = CommandeController();
  static const int _taillePage = 20;

  List<Map<String, dynamic>> _commandes = [];
  List<Map<String, dynamic>> get commandes => _commandes;

  bool _resteCommandes = false;
  bool get resteCommandes => _resteCommandes;

  bool _isLoadingPlus = false;

  String? _curseurDate;
  int? _curseurId;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _erreur;
  String? get erreur => _erreur;

  void effacerErreur() => _erreur = null;

  void _memoriserCurseur(List<Map<String, dynamic>> maps) {
    if (maps.isEmpty) return;
    _curseurDate = maps.last['created_at'] as String?;
    _curseurId = maps.last['id'] as int?;
  }

  //page suivante, appelee par le chargeur de suite
  Future<void> chargerPlusCommandes() async {
    if (_isLoadingPlus || !_resteCommandes || _curseurDate == null) return;

    _isLoadingPlus = true;

    try {
      final maps = await _controller.chargerCommandes(
        limite: _taillePage,
        curseurDate: _curseurDate,
        curseurId: _curseurId,
      );
      _commandes = [..._commandes, ...maps];
      _resteCommandes = maps.length >= _taillePage;
      _memoriserCurseur(maps);
    } catch (e){
      _resteCommandes = false;
      _erreur = "Erreur: $e";
    }
    _isLoadingPlus = false;
    notifyListeners();
  }

  NotificationProvider? _notificationProvider;
  void lierNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  //notification pontuelle: id de la commande qui vient de terminer
  int? _dernierIdTermine;
  int? get dernierIdTermine => _dernierIdTermine;
  void consommerNotificationFin() => _dernierIdTermine = null;

  final Set<int> _idsDejaSignales = {};
  Timer? _timer;

  CommandeProvider() {
    _timer = Timer.periodic(const Duration(seconds:1), (_) => _tick());
  }

  Future<void> chargerCommandes({bool silencieux = false}) async {
   if (!silencieux) {
     _isLoading = true;
     _erreur = null;
     notifyListeners();
   }

    try {
     final limite = (silencieux && _commandes.length > _taillePage)
     ? _commandes.length
     : _taillePage;

     final maps = await _controller.chargerCommandes(limite: limite);
      _commandes = maps;
      _resteCommandes = maps.length >= limite;
      _memoriserCurseur(maps);
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Retourne le numéro de commande en cas de succès, null en cas d'échec
  Future<String?> passerCommande({
    required List<PanierItemModel> items,
    required String type,
    String? adresseLivraison,
    int? tableId,
    required String modePaiement,
  }) async {
    _isSubmitting = true;
    _erreur = null;
    notifyListeners();

    String? numero;
    try {
      numero = await _controller.passerCommande(
        items: items,
        type: type,
        adresseLivraison: adresseLivraison,
        tableId: tableId,
        modePaiement: modePaiement,
      );
      await chargerCommandes(silencieux: true); // rafraîchit la liste pour PageCommandes
      _notificationProvider?.chargerNotifications(); // rafraîchit la liste pour PageNotifications
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isSubmitting = false;
    notifyListeners();
    return numero;
  }

  void _tick() {
    final expirees = <int>[];

    for (final commande in _commandes) {
      if (commande['statut'] != 'en_preparation') continue;

      final id = commande['id'];
      final dateDebutStr = commande['dateDebutPreparation'];
      final duree = commande['dureeEstimeeMinutes'];

      if (id == null || dateDebutStr == null || duree == null) continue;
      if (_idsDejaSignales.contains(id)) continue;

      final fin = DateTime.parse(dateDebutStr).add(Duration(minutes: duree as int));

      if (DateTime.now().isAfter(fin)) {
        _idsDejaSignales.add(id);
        expirees.add(id);
      }
    }

    if (expirees.isEmpty) {
      notifyListeners(); // rafraîchit seulement l'affichage des comptes à rebours
      return;
    }

    _dernierIdTermine = expirees.last;
    _terminerExpirees(expirees);
  }

  Future<void> _terminerExpirees(List<int> ids) async {
    try {
      for (final id in ids) {
        await _controller.marquerTerminee(id); // on attend la base avant de relire
      }
      await chargerCommandes(silencieux: true);
    } catch (e) {
      _erreur = "Erreur: $e";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}