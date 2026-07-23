import 'package:flutter/material.dart';
import 'package:pili_pili/models/categorie.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/widgets/champ_de_saisie.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/style/style.dart';

class AjoutCategoriePage extends StatefulWidget {
  const AjoutCategoriePage({super.key});

  @override
  State<AjoutCategoriePage> createState() => _AjoutCategoriePageState();
}

class _AjoutCategoriePageState extends State<AjoutCategoriePage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _ajouterCategorie() async {
    final nom = _nomController.text.trim();
    final description = _descriptionController.text.trim();

    if (nom.isEmpty || description.isEmpty) {
      SnackBarHelper.warning(context, "Veuillez entrer un nom de catégorie");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final categorie = Categorie(
        nom: nom,
        description: description.isNotEmpty ? description : null,
        createdAt: DateTime.now(),
      );

      final id = await DatabaseManager.insertCategorie(categorie);

      if (!mounted) return;

      if (id > 0) {
        SnackBarHelper.success(context, "Catégorie ajoutée avec succès !");
        Navigator.pop(context, true);
      } else {
        SnackBarHelper.error(context, "Erreur lors de l'ajout");
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.pink,
      appBar: AppBar(
        title: const Text(
          "Ajouter une catégorie",
          style: StyleApplication.titre,
          ),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AuthTextField(
              controller: _nomController,
              hintText: "Nom de la catégorie",
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _descriptionController,
              hintText: "Description (optionnelle)",
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _ajouterCategorie,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Ajouter",
                        style: TextStyle(color: Colors.black),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}