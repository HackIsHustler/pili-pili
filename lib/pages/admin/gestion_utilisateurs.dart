import 'package:flutter/material.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';
import 'package:pili_pili/widgets/widget_confirmation_dialogue.dart';
import 'package:pili_pili/style/style.dart';

class ListeUtilisateurs extends StatefulWidget {
  const ListeUtilisateurs({super.key});

  @override
  State<ListeUtilisateurs> createState() => _ListeUtilisateursState();
}

class _ListeUtilisateursState extends State<ListeUtilisateurs> {
  List<dynamic> _utilisateurs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    try {
      _utilisateurs = await DatabaseManager.getAllUtilisateurs();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackBarHelper.error(context, "Erreur: $e");
      }
    }
  }

  Future<void> _supprimerCompte(int id) async {
    try {
      await DatabaseManager.deleteUtilisateur(id);
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

  void _voirDetails(dynamic utilisateur) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${utilisateur.prenom} ${utilisateur.nom}",
                style: StyleApplication.sousTitre,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.email, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(utilisateur.email),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(utilisateur.telephone),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "Inscrit le ${utilisateur.createdAt.day.toString().padLeft(2, '0')}-${utilisateur.createdAt.month.toString().padLeft(2, '0')}-${utilisateur.createdAt.year}",
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
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
          "Liste des utilisateurs",
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
                child: _utilisateurs.isEmpty
                    ? const Center(child: Text("Aucun utilisateur trouvé"))
                    : ListView.builder(
                        itemCount: _utilisateurs.length,
                        itemBuilder: (context, index) {
                          final utilisateur = _utilisateurs[index];

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
                                          "${utilisateur.prenom} ${utilisateur.nom}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          utilisateur.email,
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
                                      Icons.visibility,
                                      color: Colors.blue,
                                    ),
                                    tooltip: "Voir les détails",
                                    onPressed: () => _voirDetails(utilisateur),
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
                                            "Voulez-vous vraiment supprimer définitivement le compte de ${utilisateur.prenom} ${utilisateur.nom} ? Cette action est irréversible.",
                                        confirmText: "Supprimer",
                                        confirmColor: Colors.red,
                                        onConfirm: () {
                                          _supprimerCompte(utilisateur.id!);
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
            ),
    );
  }
}