import 'package:flutter/material.dart';
import 'package:pili_pili/style/style.dart';

class HasardCategorie extends StatelessWidget{
  const HasardCategorie({super.key});

  @override
  Widget build(BuildContext context){
     return Container(
        width: 200,
        height: 100,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Card(
          color: Colors.red,
          elevation: 10,
        ),
      );
  }
 
}

class LesCategories extends StatelessWidget{
  const LesCategories({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
      margin: EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed:() {}, 
        icon: Icon(Icons.category, color: StyleApplication.coloriconInPage),
        label: Text("Tout"),
       // style: StyleApplication.styleboutonCategorie,
        ),
    );
  }
}

class LesPlusPopulaires extends StatelessWidget{
  final List<Map<String, dynamic>> items;
  const LesPlusPopulaires({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8
        ),
        itemCount: items.length, 
      itemBuilder: (context, index){
        final item = items[index];
        return Card(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(item['nom'] ?? 'nom'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item['prix'] ?? 0} fcfa'),
                      IconButton(
                        onPressed: (){}, 
                        icon: Icon(Icons.add_shopping_cart, color: Colors.pink,)
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }
      );

  }
}

//bottom navbar
class BottomNavBar extends StatelessWidget{
  final int currentIndex;
  final Function(int) onTap;  
  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
          ),
           BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favoris',
          ),
           BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Commandes',
          ),
           BottomNavigationBarItem(
          icon: Icon(Icons.verified_user),
          label: 'Profil',
          )
      ],
      );
  }
}

