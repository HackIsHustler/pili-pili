// pages/admin/dashboard_admin.dart
import 'package:flutter/material.dart';
import 'package:pili_pili/models/categorie.dart';
import 'package:pili_pili/pages/admin/ajout_categorie.dart';
import 'package:pili_pili/pages/admin/ajout_personnel.dart';
import 'package:pili_pili/pages/admin/ajout_produit.dart';
import 'package:pili_pili/pages/admin/ajout_table.dart';
import 'package:pili_pili/pages/admin/gestion_affectations.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/widgets/widget_page_admin_card.dart';
import 'package:pili_pili/style/style.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _nbCommandes = 0;
  int _nbTables = 0;
  int _nbCategories = 0;
  int _nbPersonnels = 0;
  bool _isLoading = true;

  @override
  void initState(){
    super.initState();
    _chargerStats();
  }

  Future<void> _chargerStats() async {
    setState(() {
      _isLoading = true;
    });

  try {
    final commandes = await DatabaseManager.countCommandes();
    final tables = await DatabaseManager.countTables();
    final categories = await DatabaseManager.countCategories();
    final personnels = await DatabaseManager.countPersonnels();

    setState(() {
      _nbCommandes = commandes;
      _nbTables = tables;
      _nbCategories = categories;
      _nbPersonnels = personnels;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
  }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Tableau de bord",
            style: StyleApplication.titre,
          ),
        ),
        backgroundColor: Colors.pink,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Déconnexion
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ligne des statistiques (4 cartes)
            Row(
              children: [
                Expanded(child: StatCard(
                  label: "Commandes", 
                  value: _nbCommandes.toString(), 
                  icon : Icons.shopping_cart)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(
                  label: "Tables", 
                  value: _nbTables.toString(), 
                  icon: Icons.table_restaurant
                  )),
                  const SizedBox(width: 10,),
                Expanded(child: StatCard(
                  label: "Categories", 
                  value: _nbCategories.toString(), 
                  icon: Icons.category_outlined
                  )),
                  const SizedBox(width: 10),
                Expanded(child: StatCard(
                  label: "Personnels", 
                  value: _nbPersonnels.toString(), 
                  icon: Icons.person)),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Partie Admin", 
                    style: StyleApplication.sousTitre,
                    ),
                ),
                Container(
                 decoration: BoxDecoration(
                  border: Border.all(color: Colors.pink, width: 2.0),
                  borderRadius: BorderRadius.circular(5.0)
                 ),
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(12.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 2.0,
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 20) / 5,
                        child: StatCard(
                          label: "Personnels",  
                          icon: Icons.person_add,
                          showValue: false,
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AjoutPersonnelPage(),
                                )
                               ).then((result) {
                                if (result == true){
                                  _chargerStats();
                                }
                               });
                          },
                          )
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 20) /5,
                        child: StatCard(
                          label: "Categories",  
                          icon: Icons.category,
                          showValue: false,
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AjoutCategoriePage(),
                                )
                              ).then((result){
                                if (result == true){
                                  _chargerStats();
                                }
                              });
                          },
                          )
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 20) / 5,
                        child: StatCard(
                          label: "Tables",  
                          icon: Icons.table_bar,
                          showValue: false,
                          onTap: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const AjoutTablePage(),
                                )
                              ).then((result) {
                                if (result == true){
                                  _chargerStats();
                                }
                              });
                          },
                          )
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 20) / 5,
                        child: StatCard(
                          label: "Produits",  
                          icon: Icons.fastfood,
                          showValue: false,
                          onTap: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const AjoutProduitPage(),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  _chargerStats();
                                }
                              });
                          },
                          )
                        ),

                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 20) / 5,
                        child: StatCard(
                          label: "Attribuer Table",  
                          icon: Icons.swap_horiz,
                          showValue: false,
                          onTap: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const GestionAffectations(),
                                )
                              );
                          },
                          )
                        ),
                           SizedBox(
                          width: (MediaQuery.of(context).size.width - 20) / 5,
                        child: StatCard(
                          label: "Voir personnel",  
                          icon: Icons.visibility,
                          showValue: false,
                          onTap: (){},
                          )
                        ),
                    ],
                  ),
                  
                ),
                Column(
                children: [
                  Row(
                    children: [
                      // ✅ Carte 1
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Commandes / Jrs",
                              style: StyleApplication.sousTitre,
                            ),
                            Container(
                              width: double.infinity,
                              child: StatCard(
                                label: "Nombre",
                                value: _nbCommandes.toString(),
                                icon: Icons.shopping_bag,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      // Carte 2
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Prix / Jours",
                              style: StyleApplication.sousTitre,
                            ),
                            Container(
                              width: double.infinity,
                              child: StatCard(
                                label: "Total",
                                value: "${10.toStringAsFixed(2)} FCFA",
                                icon: Icons.trending_up,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
              ],
            ),
            const SizedBox(height: 20),

            // Section : Dernières commandes
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Dernières commandes",
                style: StyleApplication.sousTitre,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 0,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("Aucune commande pour le moment"),
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