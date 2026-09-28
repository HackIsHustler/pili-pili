import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pili_pili/controllers/commande_controller.dart';
import 'package:pili_pili/models/panier_item_model.dart';

class CommandeProvider extends ChangeNotifier {
  final CommandeController _controller = CommandeController();

  List<Map<String, dynamic>> _commandes = [];
  List<Map<String, dynamic>> get commandes => _commandes;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _erreur;
  String? get erreur => _erreur;

  //notification pontuelle: id de la commande qui vient de terminer
  int? _dernierIdTermine;
  int? get dernierIdTermine => _dernierIdTermine;
  void consommerNotificationFin() => _dernierIdTermine = null;

  final Set<int> _idsDejaSignales = {};
  Timer? _timer;

  CommandeProvider() {
    _timer = Timer.periodic(const Duration(seconds:1), (_) => _tick());
  }

  Future<void> chargerCommandes() async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      _commandes = await _controller.chargerCommandes();
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
        modePaiement: modePaiement,
      );
      await chargerCommandes(); // rafraîchit la liste pour PageCommandes
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isSubmitting = false;
    notifyListeners();
    return numero;
  }

  void _tick(){
    bool changement = false;

    for (final commande in _commandes) {
      if (commande['statut'] != 'en_preparation') continue;

      final id = commande['id'];
      final dateDebutStr = commande['dateDebutPreparation'];
      final duree = commande['dureeEstimeeMinutes'] ;
      
      if (id == null || dateDebutStr == null || duree == null) continue;
      if (_idsDejaSignales.contains(id)) continue;

      final dateDebut = DateTime.parse(dateDebutStr);
      final fin = dateDebut.add(Duration(minutes: duree as int ));

      if (DateTime.now().isAfter(fin)){
        _idsDejaSignales.add(id);
        _dernierIdTermine = id;
        _controller.marquerTerminee(id);
        changement = true;
      }
    }

    if (changement) {
      chargerCommandes();
    } else {
      notifyListeners(); //rafraichir juste l'affichage des countdowns
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}