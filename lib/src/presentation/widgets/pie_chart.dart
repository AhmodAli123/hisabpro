import 'dart:math' as math;

import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  const PieChart({
    super.key,
    required this.segments,
  });

  final List<PieChartSegment> segments;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _PieChartPainter(segments),
        child: Center(
          child: Text(
            'Spending',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

class PieChartSegment {
  const PieChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter(this.segments);

  final List<PieChartSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final double total = segments.fold(0, (double sum, PieChartSegment seg) => sum + seg.value);
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) * 0.42;
    double startAngle = -math.pi / 2;

    for (final PieChartSegment segment in segments) {
      final double sweep = total > 0 ? (segment.value / total) * math.pi * 2 : 0;
      final Paint paint = Paint()..color = segment.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );
      startAngle += sweep;
    }

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, ring);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
