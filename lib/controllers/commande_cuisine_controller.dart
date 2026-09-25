import 'package:pili_pili/services/database_manager.dart';

class CommandeCuisineController {
  Future<List<Map<String, dynamic>>> chargerCommandesCuisine() {
    return DatabaseManager.getCommandesCuisine();
  }

  Future<void> accepterCommande(int commandeId, int dureeMinutes) {
    return DatabaseManager.demarrerPreparation(commandeId, dureeMinutes)
        .then((_) => null);
  }

  Future<void> marquerTerminee(int commandeId) {
    return DatabaseManager.updateStatutCommande(commandeId, 'termine')
        .then((_) => null);
  }
}