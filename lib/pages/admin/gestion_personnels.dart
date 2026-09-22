import 'package:flutter/material.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/widgets/widget_confirmation_dialogue.dart';
import 'package:pili_pili/models/utilisateur.dart';
import 'package:pili_pili/pages/admin/gestion_utilisateurs.dart';
import 'package:pili_pili/style/style.dart';

class GestionPersonnels extends StatefulWidget {
  const GestionPersonnels({super.key});

  @override
  State<GestionPersonnels> createState() => _GestionPersonnelsState();
}

class _GestionPersonnelsState extends State<GestionPersonnels> {
  List<Map<String, dynamic>> _personnels = [];
  int _totalUtilisateurs = 0;
  bool _isLoading = true;

  final List<String> _roles = ["admin", "serveur", "cuisinier", "livreur"];

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    try {
      _personnels = await DatabaseManager.getAllPersonnelsWithUsers();
      final utilisateurs = await DatabaseManager.getAllUtilisateurs();
      _totalUtilisateurs = utilisateurs.length;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _changerStatut(int personnelId, bool actif) async {
    try {
      await DatabaseManager.updateStatutPersonnel(personnelId, !actif);
      if (mounted) {
        SnackBarHelper.success(
          context,
          !actif ? "Compte réactivé" : "Compte désactivé",
        );
      }
      _chargerDonnees();
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _supprimerCompte(int utilisateurId) async {
    try {
      await DatabaseManager.deleteUtilisateur(utilisateurId);
      if (mounted) {
        SnackBarHelper.success(context, "Compte supprimé");
      }
      _chargerDonnees();
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _modifierPersonnel(Map<String, dynamic> personnel) async {
    final utilisateur = await DatabaseManager.getUtilisateursById(
      personnel['utilisateurId'],
    );

    if (utilisateur == null) {
      if (mounted) {
        SnackBarHelper.error(context, "Utilisateur introuvable");
      }
      return;
    }

    final nomController = TextEditingController(text: utilisateur.nom);
    final prenomController = TextEditingController(text: utilisateur.prenom);
    final telephoneController =
        TextEditingController(text: utilisateur.telephone);
    final emailController = TextEditingController(text: utilisateur.email);
    String roleSelectionne = personnel['role'];
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
                      "Modifier ${utilisateur.prenom} ${utilisateur.nom}",
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
                      controller: prenomController,
                      decoration: const InputDecoration(
                        labelText: "Prénom",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: telephoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Téléphone",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: roleSelectionne,
                      decoration: const InputDecoration(
                        labelText: "Rôle",
                        border: OutlineInputBorder(),
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          roleSelectionne = value!;
                        });
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
                                final nom = nomController.text.trim();
                                final prenom = prenomController.text.trim();
                                final telephone =
                                    telephoneController.text.trim();
                                final email = emailController.text.trim();

                                if (nom.isEmpty ||
                                    prenom.isEmpty ||
                                    telephone.isEmpty ||
                                    email.isEmpty) {
                                  SnackBarHelper.warning(
                                    context,
                                    "Veuillez remplir tous les champs",
                                  );
                                  return;
                                }

                                setModalState(() => isSaving = true);

                                try {
                                  // Vérifier que l'email n'est pas déjà pris
                                  // par un AUTRE utilisateur
                                  final emailPris = await DatabaseManager
                                      .emailExisteChezAutreUtilisateur(
                                    email,
                                    utilisateur.id!,
                                  );

                                  if (emailPris) {
                                    setModalState(() => isSaving = false);
                                    if (mounted) {
                                      SnackBarHelper.warning(
                                        context,
                                        "Cet email est déjà utilisé par un autre compte",
                                      );
                                    }
                                    return;
                                  }

                                  // Mise à jour de l'utilisateur
                                  final utilisateurMaj = Utilisateur(
                                    id: utilisateur.id,
                                    nom: nom,
                                    prenom: prenom,
                                    email: email,
                                    motDePasse: utilisateur.motDePasse,
                                    telephone: telephone,
                                    createdAt: utilisateur.createdAt,
                                  );
                                  await DatabaseManager.updateUtilisateur(
                                    utilisateurMaj,
                                  );

                                  // Mise à jour du rôle
                                  await DatabaseManager.updateRolePersonnel(
                                    personnel['id'],
                                    roleSelectionne,
                                  );

                                  if (mounted) {
                                    Navigator.pop(context);
                                    SnackBarHelper.success(
                                      context,
                                      "Personnel mis à jour avec succès",
                                    );
                                  }
                                  _chargerDonnees();
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
    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text(
          "Gestion des personnels",
          style: StyleApplication.titre,
          ),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _chargerDonnees,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Card cliquable — nombre d'utilisateurs
                    Card(
                      elevation: 3,
                      color: Colors.pink,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ListeUtilisateurs(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Utilisateurs de l'application",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$_totalUtilisateurs",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.people_alt,
                                color: Colors.white,
                                size: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Liste des personnels",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Liste des personnels
                    Expanded(
                      child: _personnels.isEmpty
                          ? const Center(
                              child: Text("Aucun personnel enregistré", style: TextStyle(fontSize: 20, color: Colors.white)),
                            )
                          : ListView.builder(
                              itemCount: _personnels.length,
                              itemBuilder: (context, index) {
                                final personnel = _personnels[index];
                                final bool actif = personnel['actif'] == 1;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${personnel['prenom']} ${personnel['nom']}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                personnel['role'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          tooltip: "Modifier",
                                          onPressed: () =>
                                              _modifierPersonnel(personnel),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            actif
                                                ? Icons.block
                                                : Icons.check_circle_outline,
                                            color: actif
                                                ? Colors.orange
                                                : Colors.green,
                                          ),
                                          tooltip: actif
                                              ? "Désactiver"
                                              : "Réactiver",
                                          onPressed: () {
                                            ConfirmationDialogue.show(
                                              context,
                                              title: actif
                                                  ? "Désactiver le compte"
                                                  : "Réactiver le compte",
                                              message:
                                                  "Voulez-vous vraiment ${actif ? 'désactiver' : 'réactiver'} le compte de ${personnel['prenom']} ${personnel['nom']} ?",
                                              confirmText: actif
                                                  ? "Désactiver"
                                                  : "Réactiver",
                                              confirmColor: actif
                                                  ? Colors.orange
                                                  : Colors.green,
                                              onConfirm: () {
                                                _changerStatut(
                                                  personnel['id'],
                                                  actif,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: "Supprimer",
                                          onPressed: () {
                                            ConfirmationDialogue.show(
                                              context,
                                              title: "Supprimer le compte",
                                              message:
                                                  "Voulez-vous vraiment supprimer définitivement le compte de ${personnel['prenom']} ${personnel['nom']} ? Cette action est irréversible.",
                                              confirmText: "Supprimer",
                                              confirmColor: Colors.red,
                                              onConfirm: () {
                                                _supprimerCompte(
                                                  personnel['utilisateurId'],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}