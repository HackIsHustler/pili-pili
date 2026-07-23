
import 'package:flutter/material.dart';
import 'package:pili_pili/models/table.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/widgets/champ_de_saisie.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/style/style.dart';

class AjoutTablePage extends StatefulWidget {
  const AjoutTablePage({super.key});

  @override
  State<AjoutTablePage> createState() => _AjoutTablePageState();
}

class _AjoutTablePageState extends State<AjoutTablePage> {
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _capaciteController = TextEditingController();
  String _statut = 'libre';
  bool _isSubmitting = false;

  final List<String> _statuts = ['libre', 'occupee', 'reservee'];

  Future<void> _ajouterTable() async {
    final numeroText = _numeroController.text.trim();
    final capaciteText = _capaciteController.text.trim();

    if (numeroText.isEmpty || capaciteText.isEmpty) {
      SnackBarHelper.warning(context, "Veuillez remplir tous les champs");
      return;
    }

    final numero = int.tryParse(numeroText);
    final capacite = int.tryParse(capaciteText);

    if (numero == null || numero <= 0) {
      SnackBarHelper.warning(context, "Le numéro de table doit être un nombre valide");
      return;
    }

    if (capacite == null || capacite <= 0) {
      SnackBarHelper.warning(context, "La capacité doit être un nombre valide");
      return;
    }
    
    //verifie si le numero existe deja
    final existe = await DatabaseManager.tableNumeroExiste(numero);
    if (!mounted) return;
    if (existe) {
      SnackBarHelper.warning(context, "Ce numero de table existe deja!");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final table = TableRestaurant(
        numero: numero,
        capacite: capacite,
        statut: _statut,
        createdAt: DateTime.now(),
      );

      final id = await DatabaseManager.insertTable(table);

      if (!mounted) return;

      if (id > 0) {
        SnackBarHelper.success(context, "Table ajoutée avec succès !");
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
          "Ajouter une table",
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
              controller: _numeroController,
              hintText: "Numéro de la table",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _capaciteController,
              hintText: "Capacité (nombre de personnes)",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _statut,
              items: _statuts.map((statut) {
                return DropdownMenuItem(
                  value: statut,
                  child: Text(statut.toLowerCase(), style: StyleApplication.taillTextSimple,),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _statut = value!;
                });
              },
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Statut",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _ajouterTable,
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
                        style: TextStyle(color: Colors.pink),
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
    _numeroController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }
}