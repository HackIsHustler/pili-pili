import 'package:flutter/material.dart';
import 'package:pili_pili/routes/app_routes.dart';
import 'package:pili_pili/widgets/widget_confirmation_dialogue.dart';
import 'package:pili_pili/services/session_manager.dart';
import '../widgets/widget_page_profil.dart';
import '../style/style.dart';

class PageProfil extends StatefulWidget {
  const PageProfil({super.key});

  @override
  State<PageProfil> createState() => _PageProfilState();
}

class _PageProfilState extends State<PageProfil> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _nom = 'Utilisateur';
  String _prenom = '';
  String _email = 'utilisateur@email.com';
  String _role = 'client';

  @override
  void initState() {
    super.initState();
    _chargerInfos();
  }

  Future<void> _chargerInfos() async {
    setState(() => _isLoading = true);

    try {
      final isLoggedIn = await SessionManager.isLoggedIn();
      if (isLoggedIn) {
        final nom = await SessionManager.getUserNom();
        final prenom = await SessionManager.getUserPrenom();
        final email = await SessionManager.getUserEmail();
        final role = await SessionManager.getUserRole();
    
        setState(() {
          _isLoggedIn = true;
          _nom = nom ?? 'Utilisateur';
          _prenom = prenom ?? '';
          _email = email ?? 'utilisateur@email.com';
          _role = role ?? 'client';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    ConfirmationDialogue.show(
      context,
      title: "Déconnexion",
      message: "Voulez-vous vraiment vous déconnecter ?",
      confirmText: "Se déconnecter",
      canceltext: "Annuler",
      confirmColor: Colors.red,
      onConfirm: () async {
        await SessionManager.endSession();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginRegister);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: StyleApplication.titre),
        backgroundColor: Colors.pink,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            )
          : Column(
              children: [
                // Section profil utilisateur
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.pink.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.pink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isLoggedIn ? "$_prenom $_nom" : "Invité",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLoggedIn ? _email : "Connectez-vous pour plus de fonctionnalités",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Menu
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: _buildMenuItems(),
                  ),
                ),
              ],
            ),
    );
  }

  // MENU DYNAMIQUE SELON LE RÔLE 

  List<Widget> _buildMenuItems() {
    final items = <Widget>[];

    // 1. Items communs à tous
    items.add(ProfilItem(
      icon: Icons.person_outline,
      label: 'Modifier le profil',
    ));

    // 2. Menu selon le rôle
    if (_isLoggedIn) {
      switch (_role) {
        case 'admin':
          items.add(const Divider());
          items.add(ProfilItem(
            icon: Icons.dashboard,
            label: 'Dashboard Admin',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.admin);
            },
          ));
          items.add(ProfilItem(
            icon: Icons.people,
            label: 'Gérer les utilisateurs',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.utilisateur);
            },
          ));
          items.add(ProfilItem(
            icon: Icons.restaurant_menu,
            label: 'Gérer les produits',
          ));
          items.add(ProfilItem(
            icon: Icons.table_restaurant,
            label: 'Gérer les tables',
          ));
          break;

        case 'serveur':
          items.add(const Divider());
          items.add(ProfilItem(
            icon: Icons.table_restaurant,
            label: 'Mes tables',
          ));
          items.add(ProfilItem(
            icon: Icons.shopping_bag,
            label: 'Commandes en cours',
          ));
          break;

        case 'cuisinier':
          items.add(const Divider());
          items.add(ProfilItem(
            icon: Icons.kitchen,
            label: 'Commandes à préparer',
          ));
          items.add(ProfilItem(
            icon: Icons.check_circle,
            label: 'Commandes terminées',
          ));
          break;

        case 'livreur':
          items.add(const Divider());
          items.add(ProfilItem(
            icon: Icons.delivery_dining,
            label: 'Commandes à livrer',
          ));
          items.add(ProfilItem(
            icon: Icons.history,
            label: 'Historique des livraisons',
          ));
          break;

        default: // Client
          items.add(ProfilItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Mes commandes',
          ));
          items.add(ProfilItem(
            icon: Icons.favorite_outline,
            label: 'Mes favoris',
          ));
          items.add(ProfilItem(
            icon: Icons.location_on_outlined,
            label: 'Adresses de livraison',
          ));
          items.add(ProfilItem(
            icon: Icons.payment_outlined,
            label: 'Moyens de paiement',
          ));
            items.add(ProfilItem(
            icon: Icons.dashboard,
            label: 'Dashboard Admin',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.admin);
            },
          ));
          break;
      }
    } else {
      //  Non connecté : afficher un bouton "Se connecter"
      items.add(const Divider());
      items.add(ProfilItem(
        icon: Icons.login,
        label: 'Se connecter / Créer un compte',
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.loginRegister);
        },
      ));
    }

    // 3. Items communs en bas
    items.add(const Divider(height: 30));
    items.add(ProfilItem(
      icon: Icons.notifications_outlined,
      label: 'Notifications',
    ));
    items.add(ProfilItem(
      icon: Icons.help_outline,
      label: 'Aide',
    ));

    // 4. Déconnexion (si connecté)
    if (_isLoggedIn) {
      items.add(ProfilItem(
        icon: Icons.logout,
        label: 'Se déconnecter',
        isDanger: true,
        onTap: () {
          _showLogoutDialog(context);
        },
      ));
    }

    return items;
  }

  // ========== DRAWER ==========

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.pink,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isLoggedIn ? "$_prenom $_nom" : "Invité",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isLoggedIn ? _email : "Connectez-vous",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Accueil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.accueil);
                  },
                ),
                if (_isLoggedIn && _role == 'admin')
                  ListTile(
                    leading: const Icon(Icons.dashboard, color: Colors.pink),
                    title: const Text('Dashboard Admin'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.admin);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profil'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                if (!_isLoggedIn)
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Se connecter'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.loginRegister);
                    },
                  ),
                if (_isLoggedIn)
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Se déconnecter',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}