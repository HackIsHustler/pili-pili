import 'package:flutter/material.dart';
import 'package:pili_pili/pages/page_panier.dart';
import '../widgets/widgets_page_accueil.dart';
import '../data/mock_data.dart';
import '../style/style.dart';

class PageAccueil  extends StatelessWidget{
  const PageAccueil({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("PILI-PILI", style: StyleApplication.titre,),
        backgroundColor: Colors.pink,
        centerTitle: true,
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/images/logob.png'),
          radius: 25,
          
        ),
        actions: [
          GestureDetector(
            onTap: (){
              Navigator.push(
                context, MaterialPageRoute(
                  builder: (context) => const PagePanier(),
                  )
                );
            },
            child:  Container(
            margin: EdgeInsets.all(8.0),
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              ),
              child: Icon(Icons.shopping_cart, size: 30, color: StyleApplication.coloriconInPage),
            ),
          )
        
        ],
      ),
      body:ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
                ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, subIndex){
                      return HasardCategorie();
                    }
                    ),
                ),

                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, subIndex){
                      return LesCategories();
                    }
                    ),
                  ),

                  SizedBox(
                   child: LesPlusPopulaires(
                    items: MockData.produitsPopulaires,
                    )
                  ),     
            ],
          );
        }
        )
    );
  }
}