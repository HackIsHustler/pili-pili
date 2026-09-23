import 'package:flutter/material.dart';
import 'package:pili_pili/models/table.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/widgets/widget_confirmation_dialogue.dart';
import 'package:pili_pili/pages/admin/gestion_table_et_categorie.dart';
import 'package:pili_pili/style/style.dart';

class ListeTablesPage extends StatefulWidget {
  final ModeAction mode;
  const ListeTablesPage({super.key, required this.mode});

  @override
  State<ListeTablesPage> createState() => _ListeTablesPageState();
}

class _ListeTablesPageState extends State<ListeTablesPage> {
  List<TableRestaurant> _tables = [];
  bool _isLoading = true;

  final List<String> _statuts = ["libre", "occupee"];

  @override
  void initState() {
    super.initState();
    _chargerTables();
  }

  Future<void> _chargerTables() async {
    setState(() => _isLoading = true);
    try {
      _tables = await DatabaseManager.getAllTable();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _supprimerTable(int id) async {
    try {
      await DatabaseManager.deleteTable(id);
      if (mounted) {
        SnackBarHelper.success(context, "Table supprimée");
      }
      _chargerTables();
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _modifierTable(TableRestaurant table) async {
    final numeroController =
        TextEditingController(text: table.numero.toString());
    final capaciteController =
        TextEditingController(text: table.capacite.toString());
    String statutSelectionne = table.statut;
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Modifier la table ${table.numero}",
                      style: StyleApplication.sousTitre,
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: numeroController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Numéro de table",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: capaciteController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Capacité (places)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: statutSelectionne,
                      decoration: const InputDecoration(
                        labelText: "Statut",
                        border: OutlineInputBorder(),
                      ),
                      items: _statuts.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() => statutSelectionne = value!);
                      },
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                final numeroText =
                                    numeroController.text.trim();
                                final capaciteText =
                                    capaciteController.text.trim();

                                final numero = int.tryParse(numeroText);
                                final capacite = int.tryParse(capaciteText);

                                if (numero == null || capacite == null) {
                                  SnackBarHelper.warning(
                                    context,
                                    "Veuillez entrer des valeurs valides",
                                  );
                                  return;
                                }

                                setModalState(() => isSaving = true);

                                try {
                                  // Vérifie l'unicité du numéro seulement s'il a changé
                                  if (numero != table.numero) {
                                    final existe = await DatabaseManager
                                        .tableNumeroExiste(numero);
                                    if (existe) {
                                      setModalState(() => isSaving = false);
                                      if (mounted) {
                                        SnackBarHelper.warning(
                                          context,
                                          "Ce numéro de table existe déjà",
                                        );
                                      }
                                      return;
                                    }
                                  }

                                  final tableMaj = TableRestaurant(
                                    id: table.id,
                                    numero: numero,
                                    capacite: capacite,
                                    statut: statutSelectionne,
                                    createdAt: table.createdAt,
                                  );

                                  await DatabaseManager.updateTable(tableMaj);

                                  if (mounted) {
                                    Navigator.pop(context);
                                    SnackBarHelper.success(
                                      context,
                                      "Table mise à jour avec succès",
                                    );
                                  }
                                  _chargerTables();
                                } catch (e) {
                                  setModalState(() => isSaving = false);
                                  if (mounted) {
                                    SnackBarHelper.error(
                                      context,
                                      "Erreur: $e",
                                    );
                                  }
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Enregistrer",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool modeModifier = widget.mode == ModeAction.modifier;

    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: Text(
          modeModifier ? "Modifier une table" : "Supprimer une table",
          style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _chargerTables,
              child: _tables.isEmpty
                  ? const Center(child: Text("Aucune table enregistrée", style: TextStyle(fontSize: 20, color: Colors.white)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        final table = _tables[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.table_restaurant,
                              color: Colors.pink,
                            ),
                            title: Text("Table ${table.numero}"),
                            subtitle: Text(
                              "${table.capacite} places · ${table.statut}",
                            ),
                            trailing: modeModifier
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _modifierTable(table),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      ConfirmationDialogue.show(
                                        context,
                                        title: "Supprimer la table",
                                        message: table.statut == "occupee"
                                            ? "La table ${table.numero} est actuellement occupée. Voulez-vous vraiment la supprimer ? Cette action est irréversible."
                                            :
                                            "Voulez-vous vraiment supprimer la table ${table.numero} ? Cette action est irréversible.",
                                        confirmText: "Supprimer",
                                        confirmColor: Colors.red,
                                        onConfirm: () {
                                          _supprimerTable(table.id!);
                                        },
                                      );
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}