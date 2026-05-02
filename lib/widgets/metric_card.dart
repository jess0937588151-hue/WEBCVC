import 'package:flutter/material.dart';
import 'package:stockflow_flutter_pro/app/app_theme.dart';
import 'package:stockflow_flutter_pro/widgets/glass_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    this.highlightColor = AppTheme.primary,
  });

  final String label;
  final String value;
  final String caption;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlightColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
