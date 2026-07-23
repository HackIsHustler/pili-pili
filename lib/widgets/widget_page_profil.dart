import 'package:flutter/material.dart';

class ProfilItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDanger;

  const ProfilItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDanger ? Colors.red : Colors.pink,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDanger ? Colors.red : Colors.black,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}