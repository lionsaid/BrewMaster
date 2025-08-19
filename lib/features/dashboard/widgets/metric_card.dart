import 'package:flutter/material.dart';
import 'package:brew_master/core/widgets/app_card.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Gradient? gradient;

  const MetricCard({super.key, required this.icon, required this.label, required this.value, this.gradient});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(radius: 16, child: Icon(icon, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );

    return FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: content,
      ),
    );
  }
} 