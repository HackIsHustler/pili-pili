import 'package:pili_pili/models/notification.dart' as noti;
import 'package:pili_pili/services/database_manager.dart';

class NotificationController {
  Future<List<noti.Notification>> chargerNotifications(int utilisateurId) {
    return DatabaseManager.getNotificationsByUtilsateur(utilisateurId);
  }

  Future<int> compterNonLues(int utilisateurId) {
    return DatabaseManager.countNotificationsNonLues(utilisateurId);
  }

  Future<void> marquerCommeLue(int id) {
    return DatabaseManager.marquerNotificationCommeLu(id).then((_) => null);
  }

  // true = cette tentative a réussi à prendre la livraison ; false = déjà prise par un autre
  Future<bool> tenterAccepterLivraison(int commandeId, int livreurId) {
    return DatabaseManager.accepterLivraison(commandeId, livreurId);
  }
}