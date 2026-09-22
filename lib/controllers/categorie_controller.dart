import 'package:pili_pili/models/categorie.dart';
import 'package:pili_pili/services/database_manager.dart';

class CategorieController {
  Future<List<Categorie>> chargerCategories() {
    return DatabaseManager.getAllCategorie();
  }
}