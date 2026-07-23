// widgets/stat_card.dart
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool showValue;

  const StatCard({
    super.key,
    required this.label,
    this.value,
    required this.icon,
    this.color,
    this.onTap,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color ??  Colors.pink,
              ),
              const SizedBox(height: 8),
              if(showValue && value != null)
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}