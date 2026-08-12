import 'package:flutter/material.dart';

class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.bars,
  });

  final List<BarChartData> bars;

  @override
  Widget build(BuildContext context) {
    final double maxAmount = bars.fold(0, (double max, BarChartData bar) => bar.amount > max ? bar.amount : max);
    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars.map((BarChartData bar) {
          final double height = maxAmount > 0 ? (bar.amount / maxAmount) * 180 : 0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: bar.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(bar.label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BarChartData {
  const BarChartData({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;
}
