import 'package:flutter/material.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/models/table.dart';
import 'package:pili_pili/models/affectation_table.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/widgets/widget_confirmation_dialogue.dart';
import 'package:pili_pili/style/style.dart';

class GestionAffectations extends StatefulWidget {
  const GestionAffectations({super.key});

  @override
  State<GestionAffectations> createState() => _GestionAffectationsState();
}

class _GestionAffectationsState extends State<GestionAffectations> {
  List<TableRestaurant> _tables = [];
  List<AffectationTable> _affectations = [];
  List<Map<String, dynamic>> _personnels = [];
  bool _isLoading = true;

  // Contrôleurs pour le formulaire
  int? _selectedServeurId;
  int? _selectedTableId;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);

    try {
      // 1. Récupérer les serveurs
       _personnels = await DatabaseManager.getAllPersonnelsWithUsers();

      final serveurs = _personnels.where((p) => p['role'] == 'serveur').toList();

      // 2. Récupérer les tables
      _tables = await DatabaseManager.getAllTable();

      // 3. Récupérer les affectations actives
      final allAffectations = await DatabaseManager.getAllAffectations();
      _affectations = allAffectations.where((a) => a.dateFin == null).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  String _formatDate(DateTime date) {
  final local = date.toLocal();
  final jour = local.day.toString().padLeft(2, '0');
  final mois = local.month.toString().padLeft(2, '0');
  final annee = (local.year % 100).toString().padLeft(2, '0'); // 2 derniers chiffres
  final heure = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return "$jour-$mois-$annee   $heure:$minute";
}



  Future<void> _attribuerTable() async {
    if (_selectedServeurId == null || _selectedTableId == null) {
      SnackBarHelper.warning(context, "Veuillez sélectionner un serveur et une table");
      return;
    }

    try {
      final affectation = AffectationTable(
        tableId: _selectedTableId!,
        utilisateurId: _selectedServeurId!,
        dateDebut: DateTime.now(),
      );

      await DatabaseManager.insertAffectationTable(affectation);

      // Mettre à jour le statut de la table
      await DatabaseManager.updateStatutTable(_selectedTableId!, "occupee");

      if (mounted) {
        SnackBarHelper.success(context, "Table attribuée avec succès !");
      }
      _chargerDonnees();

      // Réinitialiser la sélection
      setState(() {
        _selectedServeurId = null;
        _selectedTableId = null;
      });
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _libererTable(int affectationId, int tableId) async {
    try {
      await DatabaseManager.terminerAffectation(affectationId);
      await DatabaseManager.updateStatutTable(tableId, "libre");

      if (mounted) {
        SnackBarHelper.success(context, "Table libérée !");
      }
      _chargerDonnees();
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text("Attribution des tables", style: StyleApplication.titre,),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Formulaire d'attribution
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Sélection du serveur
                            DropdownButtonFormField<int>(
                              initialValue: _selectedServeurId,
                              hint: const Text("Sélectionner un serveur"),
                              items: _personnels
                              .where((p) => p['role'] == 'serveur')
                              .map<DropdownMenuItem<int>>((p) {
                                return DropdownMenuItem<int>(
                                  value: p['utilisateurId'],
                                  child: Text("${p['prenom']} ${p['nom']}"),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedServeurId = value;
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Serveur",
                              ),
                            ),
                            const SizedBox(height: 10),
            
                            // Sélection de la table
                            DropdownButtonFormField<int>(
                              initialValue: _selectedTableId,
                              hint: const Text("Sélectionner une table"),
                              items: _tables
                                  .where((t) => t.statut == "libre")
                                  .map((table) {
                                return DropdownMenuItem(
                                  value: table.id,
                                  child: Text("Table ${table.numero} - ${table.capacite} places"),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTableId = value;
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Table",
                              ),
                            ),
                            const SizedBox(height: 10),
            
                            // Bouton Attribuer
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _attribuerTable,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                ),
                                child: const Text(
                                  "Attribuer",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            
                    const SizedBox(height: 20),
            
                    // Liste des affectations en cours
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Affectations en cours",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
            
                    Expanded(
                      child: _affectations.isEmpty
                          ? const Center(
                              child: Text("Aucune affectation en cours", style: TextStyle(fontSize: 20, color: Colors.white)),
                            )
                          : ListView.builder(
                              itemCount: _affectations.length,
                              itemBuilder: (context, index) {
                                final affectation = _affectations[index];
                                final table = _tables.firstWhere(
                                  (t) => t.id == affectation.tableId,
                                );
                                final serveur = _personnels.firstWhere(
                                  (p) => p['utilisateurId'] == affectation.utilisateurId,
                                );
            
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.table_restaurant,
                                        color: Colors.pink),
                                    title: Text("Table ${table.numero}"),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Serveur: ${serveur['prenom']} ${serveur['nom']}"),
                                        Text(
                                          "Depuis: ${_formatDate(affectation.dateDebut)}",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () {
                                        ConfirmationDialogue.show(
                                          context, 
                                          title: "Liberer la table", 
                                          message: "Voulez-vous vraiment liberer la table ${table.numero} ?",
                                          confirmText: "Liberer",
                                          confirmColor: Colors.red,
                                          onConfirm: () {
                                            _libererTable(affectation.id!, table.id!);
                                          }
                                          );
                                      },
                                      tooltip: "Libérer la table",
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
    );
  }
}