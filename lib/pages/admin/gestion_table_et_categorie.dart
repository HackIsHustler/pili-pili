import 'package:flutter/material.dart';
import 'package:pili_pili/pages/admin/liste_tables_page.dart';
import 'package:pili_pili/pages/admin/liste_categories_page.dart';
import 'package:pili_pili/style/style.dart';
import 'package:pili_pili/utils/transition_page.dart';


enum ModeAction { modifier, supprimer }

class GestionTablesCategories extends StatelessWidget {
  const GestionTablesCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StyleApplication.backgroundcolorPage,
      appBar: AppBar(
        title: const Text(
          "Gestion tables & catégories", 
          style: StyleApplication.titre
          ),
        backgroundColor: Colors.pink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _boutonMenu(
              context,
              icon: Icons.edit,
              label: "Modifier une table",
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                slideRoute(const ListeTablesPage(mode: ModeAction.modifier),)
              )
            ),
            const SizedBox(height: 12),
            _boutonMenu(
              context,
              icon: Icons.edit,
              label: "Modifier une catégorie",
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                slideRoute(const ListeCategoriesPage(mode: ModeAction.modifier),)
               
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(thickness: 1),
            ),

            _boutonMenu(
              context,
              icon: Icons.delete,
              label: "Supprimer une table",
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                slideRoute(const ListeTablesPage(mode: ModeAction.supprimer),)
              ),
            ),
            const SizedBox(height: 12),
            _boutonMenu(
              context,
              icon: Icons.delete,
              label: "Supprimer une catégorie",
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                slideRoute(const ListeCategoriesPage(mode: ModeAction.supprimer),)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boutonMenu(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: color),
        ),
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: StyleApplication.textSurLeBouton.copyWith(color: color),
        ),
      ),
    );
  }
}