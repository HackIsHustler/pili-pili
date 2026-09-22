import 'package:flutter/material.dart';
import 'package:pili_pili/providers/panier_provider.dart';
import 'package:provider/provider.dart';
import 'package:pili_pili/pages/admin/gestion_utilisateurs.dart';
import 'package:pili_pili/pages/auth/login_register.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/pages/admin/page_admin.dart';
import 'package:pili_pili/providers/categorie_provider.dart';
import 'package:pili_pili/providers/produit_provider.dart';
import 'package:pili_pili/providers/commande_provider.dart';
import './widgets/widgets_page_accueil.dart';
import 'pages/ma_page_accueil.dart';
import './pages/page_favoris.dart';
import './pages/page_commandes.dart';
import './pages/page_profil.dart';
import './routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseManager.initDb();
  try {
    final db = await DatabaseManager.initDb();
    final result = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    print(" Tables dans la base :");
    for (var table in result) {
      print("  - ${table['name']}");
    }
    final users = await db.rawQuery('SELECT COUNT(*) as count FROM utilisateurs');
    print("👤 Nombre d'utilisateurs : ${users.first['count']}");
    final perso = await db.rawQuery('SELECT COUNT(*) as count FROM personnels');
    print("👤 Nombre personnels : ${perso.first['count']}");
    final prod = await db.rawQuery('SELECT COUNT(*) as count FROM produits');
    print("👤 Nombre produits : ${prod.first['count']}");
  } catch (e) {
    print(" Erreur: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategorieProvider()..chargerCategories()),
        ChangeNotifierProvider(create: (_) => ProduitProvider()..chargerProduits()),
        ChangeNotifierProvider(create: (_) => CommandeProvider()..chargerCommandes()),
        ChangeNotifierProvider(create: (_) => PanierProvider()),
      ],
      child: const MonAppli(),
    ),
  );
}

class MonAppli extends StatelessWidget {
  const MonAppli({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'pili-pili',
      initialRoute: AppRoutes.accueil,
      routes: {
        AppRoutes.accueil: (context) => const MainPage(),
        AppRoutes.favoris: (context) => const PageFavoris(),
        AppRoutes.commandes: (context) => const PageCommandes(),
        AppRoutes.profil: (context) => const PageProfil(),
        AppRoutes.loginRegister: (context) => const LoginRegisterPage(),
        AppRoutes.admin: (context) => const DashboardAdmin(),
        AppRoutes.utilisateur: (context) => const ListeUtilisateurs(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PageAccueil(),
    PageFavoris(),
    PageCommandes(),
    PageProfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}