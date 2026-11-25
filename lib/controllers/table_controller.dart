import 'package:pili_pili/models/table.dart';
import 'package:pili_pili/services/database_manager.dart';

class TableController {
  Future<List<TableRestaurant>> chargerTables()  {
    return DatabaseManager.getAllTable();
  }
}