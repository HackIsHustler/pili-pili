// widgets/formulaire_personnel.dart
import 'package:flutter/material.dart';
import 'package:pili_pili/widgets/champ_de_saisie.dart';

class FormulairePersonnel extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final TextEditingController telephoneController;
  final TextEditingController passwordController;
  final String selectedRole;
  final Function(String) onRoleChanged;

  const FormulairePersonnel({
    super.key,
    required this.emailController,
    required this.nomController,
    required this.prenomController,
    required this.telephoneController,
    required this.passwordController,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  State<FormulairePersonnel> createState() => _FormulairePersonnelState();
}

class _FormulairePersonnelState extends State<FormulairePersonnel> {
  final List<String> _roles = ['admin', 'serveur', 'cuisinier', 'livreur'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthTextField(
          controller: widget.emailController,
          hintText: "Email",
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        AuthTextField(
          controller: widget.nomController,
          hintText: "Nom",
        ),
        const SizedBox(height: 10),
        AuthTextField(
          controller: widget.prenomController,
          hintText: "Prénom",
        ),
        const SizedBox(height: 10),
        AuthTextField(
          controller: widget.telephoneController,
          hintText: "Téléphone",
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        AuthTextField(
          controller: widget.passwordController,
          hintText: "Mot de passe",
          isPassword: true,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: widget.selectedRole,
          items: _roles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onRoleChanged(value);
            }
          },
          decoration: const InputDecoration(
            hintText: "Rôle",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}