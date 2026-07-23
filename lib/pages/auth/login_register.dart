import 'package:flutter/material.dart';
import 'package:pili_pili/style/style.dart';
import 'package:pili_pili/widgets/champ_de_saisie.dart';
import 'package:pili_pili/services/database_manager.dart';
import 'package:pili_pili/services/session_manager.dart';
import 'package:pili_pili/models/utilisateur.dart';
import 'package:pili_pili/widgets/zone_de_message.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoginMode = true; // true = connexion, false = inscription
  bool _isLoading = false;

  // Méthode de connexion
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if(mounted){
          SnackBarHelper.warning(context," Veuillez remplir tous les champs !");
        }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await DatabaseManager.getUtilisateursByEmail(email);

      if (user == null) {
        if(mounted){
          SnackBarHelper.error(context,"Utilisateur non trouve !");
        }
        setState(() => _isLoading = false);
        return;
      }

      if (user.motDePasse != password) {
        if(mounted){
          SnackBarHelper.error(context," Mot de passe ou email incorrect !");
        }
        setState(() => _isLoading = false);
        return;
      }

      await SessionManager.startSession(
        userId: user.id!, 
        email: user.email, 
        nom: user.nom, 
        prenom: user.prenom,
        role: 'client'
        );

      //verifie si lutilisateur est un utilisateur
      final role = await DatabaseManager.getRoleByUtilisateurId(user.id!);
      print('role: $role');

      //si c'est un personnel stocker le role en session
      if (role != null){
        await SessionManager.setUserRole(role);
      } else{
        await SessionManager.setUserRole('client');
      }

      //  Connexion réussie
      if(mounted){
          SnackBarHelper.success(context," Connexion reuissie  !");
        }

      // Rediriger vers Dashboard Admin
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      });

    } catch (e) {
      if(mounted){
          SnackBarHelper.warning(context," Erreur $e !");
        }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Méthode d'inscription
  Future<void> _register() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final telephone = _telephoneController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || password.isEmpty || telephone.isEmpty || confirmPassword.isEmpty) {
      if(mounted){
          SnackBarHelper.warning(context," Veuillez remplir tous les champs !");
        }
      return;
    }

    //verifions que les mots de passe se correspondent
    if(password != confirmPassword) {
      if (mounted) {
        SnackBarHelper.warning(context, "Les deux mots de passe ne se correspondent pas!");
      }
      return;
    }

    if (password.length < 6) {
      if(mounted){
          SnackBarHelper.warning(context," Mot de passe doit contenir au moins six caracteres !");
        }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Vérifier si l'email existe déjà
      final existingUser = await DatabaseManager.getUtilisateursByEmail(email);
      if (existingUser != null) {
        if(mounted){
          SnackBarHelper.info(context," Cet utilisateur existe deja !");
        }
        setState(() => _isLoading = false);
        return;
      }

      // Créer l'utilisateur
      final user = Utilisateur(
        nom: nom,
        prenom: prenom,
        email: email,
        motDePasse: password,
        telephone: telephone,
        createdAt: DateTime.now(),
      );

      final id = await DatabaseManager.insertUtilisateur(user);
      
      if (id > 0) {
        if(mounted){
          SnackBarHelper.success(context," Compte créé avec succès !");
        }
        // Bascule en mode connexion
        setState(() {
          _isLoginMode = true;
          _isLoading = false;
        });
      } else {
        if(mounted){
        SnackBarHelper.error(context, "Erreur lors de la création");
        }
      }
    } catch (e) {
      if(mounted){
      SnackBarHelper.error(context, "Erreur: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logob.png',
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.4,
                      fit: BoxFit.contain,
                    ),
              
                    Text(
                      _isLoginMode ? "Connexion" : "Inscription",
                      style: StyleApplication.titre.copyWith(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Champs dynamiques
                    if (!_isLoginMode) ...[
                      AuthTextField(
                        controller: _nomController,
                        hintText: "Nom"
                        ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller:_prenomController,
                        hintText:  "Prénom"
                        ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _telephoneController, 
                        hintText: "Téléphone", 
                        keyboardType: TextInputType.phone
                        ),
                      const SizedBox(height: 12),
                      ],

                    AuthTextField(
                      controller: _emailController, 
                      hintText: "Adresse Email", 
                      keyboardType: TextInputType.emailAddress
                      ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _passwordController,
                      hintText: "Mot de passe",
                      isPassword: true,
                    ),
                    const SizedBox(height: 12,),
                    
                    if(!_isLoginMode) ...[
                      AuthTextField(
                        controller: _confirmPasswordController, 
                        hintText: "Confirmer mot de passe",
                        isPassword: true,
                        ),

                        const SizedBox(height: 12,)
                    ],
                 
                    const SizedBox(height: 20),

                    // Bouton
                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isLoginMode ? _login : _register,
                          child: Text(
                            _isLoginMode ? "Se connecter" : "S'inscrire",
                            style: const TextStyle(
                              color: Color(0xff1f48ff),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 15),
                    
                    // Switch entre Connexion/Inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLoginMode
                              ? "Vous n'avez pas de compte ?"
                              : "Vous avez déjà un compte ?",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLoginMode = !_isLoginMode;
                              // Réinitialiser les champs
                              _emailController.clear();
                              _passwordController.clear();
                              _nomController.clear();
                              _prenomController.clear();
                              _telephoneController.clear();
                              _confirmPasswordController.clear();
                            });
                          },
                          child: Text(
                            _isLoginMode ? "S'inscrire" : "Se connecter",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose(){
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

}