import 'package:flutter/material.dart';
import 'package:pili_pili/controllers/notification_controller.dart';
import 'package:pili_pili/models/notification.dart' as noti;
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/services/session_manager.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationController _controller = NotificationController();

  List<noti.Notification> _notifications = [];
  List<noti.Notification> get notifications => _notifications;

  //etats des notifications liees aux notifations: commandesID ->livreurId(nulle si pas encore prise)
  final Map<int, int?> _livreurIdParCommande = {};

  int _nonLues = 0;
  int get nonLues => _nonLues;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _erreur;
  String? get erreur => _erreur;

  Future<void> chargerNotifications() async {
    final userId = await SessionManager.getUserId();

    if (userId == null) {
      _notifications = [];
      _nonLues = 0;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _controller.chargerNotifications(userId);
      _nonLues = await _controller.compterNonLues(userId);

      //pour chaque nottif liee a une commande recupere letat actuel du livreurId
      _livreurIdParCommande.clear();
      for (final notif in _notifications){
        if (notif.commandeId != null){
          final commande = await DatabaseManager.getCommandeById(notif.commandeId!);
          _livreurIdParCommande[notif.commandeId!] = commande?.livreurId;
        }
      }
    } catch (e) {
      _erreur = "Erreur: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  //null = pas encore prise; sinon l'id du livreur qui l'a prise
  int? livreurIdPourCommande(int commandeId) => _livreurIdParCommande[commandeId];

  Future<void> marquerCommeLue(int id) async {
    await _controller.marquerCommeLue(id);
    await chargerNotifications();
  }

  // true = livraison obtenue par l'utilisateur courant, false = déjà prise
  Future<bool> accepterLivraison(int commandeId) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return false;

    final succes = await _controller.tenterAccepterLivraison(commandeId, userId);
    await chargerNotifications();
    return succes;
  }
}