import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/services/session_manager.dart';

class CommandeLivreurController {
  Future<List<Map<String, dynamic>>> chargerCommandesALivrer() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return [];
    return DatabaseManager.getCommandesALivrer(userId);
  }

  Future<bool> demarrerLivraison(int commandeId) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return false;
    return DatabaseManager.demarrerLivraison(commandeId, userId);
  }

  Future<bool> marquerLivree(int commandeId) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return false;
    return DatabaseManager.marquerCommandeLivree(commandeId, userId);
  }

  Future<List<Map<String, dynamic>>> chargerHistorique({
    int limite = 20,
    String? curseurDate,
    int? curseurId,
  }) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return [];
    return DatabaseManager.getHistoriqueLivraisons(
      userId,
      limite: limite,
      curseurDate: curseurDate,
      curseurId: curseurId,
    );
  }

  Future<Map<String, int>> chargerStatsHistorique() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return {'nombre': 0, 'somme': 0};
    return DatabaseManager.getStatsHistoriqueLivraisons(userId);
  }
}