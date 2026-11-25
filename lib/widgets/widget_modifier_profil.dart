import 'package:flutter/material.dart';
import 'package:pili_pili/controllers/profil_controller.dart';
import 'package:pili_pili/models/utilisateur.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/style/style.dart';

Future<void> afficherModifierProfil(
    BuildContext context, {
      required VoidCallback onSucces,
    }) async {
  final controller = ProfilController();
  final utilisateur = await controller.chargerUtilisateurCourant();

  if (!context.mounted) return;

  if (utilisateur == null) {
    SnackBarHelper.error(context, "Impossible de charger votre profil");
    return;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _FormModifierProfil(
      utilisateur: utilisateur,
      controller: controller,
      onSucces: onSucces,
    ),
  );
}

class _FormModifierProfil extends StatefulWidget {
  final Utilisateur utilisateur;
  final ProfilController controller;
  final VoidCallback onSucces;

  const _FormModifierProfil({
    required this.utilisateur,
    required this.controller,
    required this.onSucces,
  });

  @override
  State<_FormModifierProfil> createState() => _FormModifierProfilState();
}

class _FormModifierProfilState extends State<_FormModifierProfil> {
  late final TextEditingController _nom;
  late final TextEditingController _prenom;
  late final TextEditingController _telephone;
  late final TextEditingController _email;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nom = TextEditingController(text: widget.utilisateur.nom);
    _prenom = TextEditingController(text: widget.utilisateur.prenom);
    _telephone = TextEditingController(text: widget.utilisateur.telephone);
    _email = TextEditingController(text: widget.utilisateur.email);
  }

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _telephone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    setState(() => _isSaving = true);

    try {
      final erreur = await widget.controller.modifierProfil(
        actuel: widget.utilisateur,
        nom: _nom.text.trim(),
        prenom: _prenom.text.trim(),
        email: _email.text.trim(),
        telephone: _telephone.text.trim(),
      );

      if (!mounted) return;

      if (erreur != null) {
        setState(() => _isSaving = false);
        SnackBarHelper.warning(context, erreur);
        return;
      }

      SnackBarHelper.success(context, "Profil mis à jour");
      Navigator.pop(context);
      widget.onSucces();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackBarHelper.error(context, "Erreur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Modifier mon profil", style: StyleApplication.sousTitre),
            const SizedBox(height: 20),
            TextField(
              controller: _nom,
              decoration: const InputDecoration(
                labelText: "Nom",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prenom,
              decoration: const InputDecoration(
                labelText: "Prénom",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telephone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Téléphone",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _enregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
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
      ),
    );
  }
}