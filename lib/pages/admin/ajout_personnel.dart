// pages/admin/ajout_personnel_page.dart
import 'package:flutter/material.dart';
import 'package:pili_pili/models/personnel.dart';
import 'package:pili_pili/models/utilisateur.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/style/style.dart';
import 'package:pili_pili/widgets/Champ_de_saisie.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';

class AjoutPersonnelPage extends StatefulWidget {
  const AjoutPersonnelPage({super.key});

  @override
  State<AjoutPersonnelPage> createState() => _AjoutPersonnelPageState();
}

class _AjoutPersonnelPageState extends State<AjoutPersonnelPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'serveur';
  bool _isSubmitting = false;

  final List<String> _roles = ['admin', 'serveur', 'cuisinier', 'livreur'];

  Future<void> _ajouterPersonnel() async {
    final email = _emailController.text.trim();
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final telephone = _telephoneController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || nom.isEmpty || prenom.isEmpty || telephone.isEmpty || password.isEmpty) {
      SnackBarHelper.warning(context, "Veuillez remplir tous les champs");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final existingUser = await DatabaseManager.getUtilisateursByEmail(email);
      if (!mounted) return;

      if (existingUser != null) {
        final existingPersonnel = await DatabaseManager.getPersonnelByutilisateurId(existingUser.id!);
        if (!mounted) return;

        if (existingPersonnel != null) {
          SnackBarHelper.warning(context, "Cet utilisateur est déjà un personnel !");
          setState(() => _isSubmitting = false);
          return;
        }

        final personnel = Personnel(
          utilisateurId: existingUser.id!,
          role: _selectedRole,
          createdAt: DateTime.now(),
        );
        await DatabaseManager.insertPersonnel(personnel);

        if (!mounted) return;
        SnackBarHelper.success(context, "Personnel ajouté avec succès !");
        Navigator.pop(context, true);
        return;
      }

      // Créer un nouvel utilisateur
      final nouveauUtilisateur = Utilisateur(
        nom: nom,
        prenom: prenom,
        email: email,
        motDePasse: password,
        telephone: telephone,
        createdAt: DateTime.now(),
      );

      final userId = await DatabaseManager.insertUtilisateur(nouveauUtilisateur);
      if (!mounted) return;

      if (userId > 0) {
        final personnel = Personnel(
          utilisateurId: userId,
          role: _selectedRole,
          createdAt: DateTime.now(),
        );
        await DatabaseManager.insertPersonnel(personnel);

        if (!mounted) return;
        SnackBarHelper.success(context, "Compte et personnel créés avec succès !");
        Navigator.pop(context, true);
      } else {
        SnackBarHelper.error(context, "Erreur lors de la création");
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
          "Ajouter un personnel",
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
              controller: _emailController,
              hintText: "Email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _nomController,
              hintText: "Nom",
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _prenomController,
              hintText: "Prénom",
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _telephoneController,
              hintText: "Téléphone",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              hintText: "Mot de passe",
              isPassword: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toLowerCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration:  InputDecoration(
                hintText: "Rôle",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _ajouterPersonnel,
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
    _emailController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}