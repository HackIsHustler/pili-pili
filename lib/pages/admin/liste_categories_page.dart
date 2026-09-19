import 'package:flutter/material.dart';
import 'package:pili_pili/models/categorie.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/widgets/widget_confirmation_dialogue.dart';
import 'package:pili_pili/pages/admin/gestion_table_et_categorie.dart';
import 'package:pili_pili/style/style.dart';

class ListeCategoriesPage extends StatefulWidget {
  final ModeAction mode;
  const ListeCategoriesPage({super.key, required this.mode});

  @override
  State<ListeCategoriesPage> createState() => _ListeCategoriesPageState();
}

class _ListeCategoriesPageState extends State<ListeCategoriesPage> {
  List<Categorie> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerCategories();
  }

  Future<void> _chargerCategories() async {
    setState(() => _isLoading = true);
    try {
      _categories = await DatabaseManager.getAllCategorie();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _supprimerCategorie(int id) async {
    try {
      await DatabaseManager.deleteCategorie(id);
      if (mounted) {
        SnackBarHelper.success(context, "Catégorie supprimée");
      }
      _chargerCategories();
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _modifierCategorie(Categorie categorie) async {
    final nomController = TextEditingController(text: categorie.nom);
    final descriptionController =
        TextEditingController(text: categorie.description ?? '');
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
                      "Modifier la catégorie",
                      style: StyleApplication.sousTitre,
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: nomController,
                      decoration: const InputDecoration(
                        labelText: "Nom",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Description (optionnelle)",
                        border: OutlineInputBorder(),
                      ),
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
                                final nom = nomController.text.trim();
                                final description =
                                    descriptionController.text.trim();

                                if (nom.isEmpty) {
                                  SnackBarHelper.warning(
                                    context,
                                    "Le nom est obligatoire",
                                  );
                                  return;
                                }

                                setModalState(() => isSaving = true);

                                try {
                                  final categorieMaj = Categorie(
                                    id: categorie.id,
                                    nom: nom,
                                    description: description.isNotEmpty
                                        ? description
                                        : null,
                                    createdAt: categorie.createdAt,
                                  );

                                  await DatabaseManager.updateCategorie(
                                    categorieMaj,
                                  );

                                  if (mounted) {
                                    Navigator.pop(context);
                                    SnackBarHelper.success(
                                      context,
                                      "Catégorie mise à jour avec succès",
                                    );
                                  }
                                  _chargerCategories();
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
          modeModifier ? "Modifier une catégorie" : "Supprimer une catégorie",
          style: StyleApplication.titre,
        ),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _chargerCategories,
              child: _categories.isEmpty
                  ? const Center(child: Text("Aucune catégorie enregistrée"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final categorie = _categories[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.category,
                              color: Colors.pink,
                            ),
                            title: Text(categorie.nom),
                            subtitle: Text(
                              categorie.description ?? "Aucune description",
                            ),
                            trailing: modeModifier
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () =>
                                        _modifierCategorie(categorie),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      ConfirmationDialogue.show(
                                        context,
                                        title: "Supprimer la catégorie",
                                        message:
                                            "Voulez-vous vraiment supprimer la catégorie \"${categorie.nom}\" ? Cette action est irréversible.",
                                        confirmText: "Supprimer",
                                        confirmColor: Colors.red,
                                        onConfirm: () {
                                          _supprimerCategorie(categorie.id!);
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