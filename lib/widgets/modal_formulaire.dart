// widgets/modal_formulaire.dart
import 'package:flutter/material.dart';

class ModalFormulaire extends StatelessWidget {
  final String titre;
  final List<Widget> champs;
  final VoidCallback onValider;
  final bool isLoading;
  final String texteBouton;

  const ModalFormulaire({
    super.key,
    required this.titre,
    required this.champs,
    required this.onValider,
    this.isLoading = false,
    this.texteBouton = "Valider",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titre),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: champs,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : onValider,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  texteBouton,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}