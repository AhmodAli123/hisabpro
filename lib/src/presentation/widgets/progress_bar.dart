import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final double value;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text('${(value * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant,
            color: foregroundColor ?? Theme.of(context).colorScheme.primary,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
