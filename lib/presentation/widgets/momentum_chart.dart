import 'package:flutter/material.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/core/utils/momentum_calculator.dart';

class MomentumChart extends StatelessWidget {
  final List<Rally> rallies;

  const MomentumChart({required this.rallies, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rallies.isEmpty) {
      return const SizedBox.shrink();
    }

    final computer = MomentumComputer(rallies);
    final points = computer.computeMomentumPoints();
    final runs = computer.detectRuns();

    return CustomPaint(
      painter: MomentumChartPainter(points, runs),
      child: Container(),
    );
  }
}

class MomentumChartPainter extends CustomPainter {
  final List<MomentumPoint> points;
  final List<MomentumRun> runs;

  MomentumChartPainter(this.points, this.runs);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Find min/max for scaling
    final maxDiff = points.map((p) => p.cumulativeScoreDiff.abs()).reduce(
          (a, b) => a > b ? a : b,
        );
    final range = maxDiff * 2 + 2;

    // Draw center line
    final centerY = size.height / 2;
    final centerLinePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerLinePaint,
    );

    // Calculate step width
    final stepWidth = size.width / points.length;

    // Highlight runs
    for (final run in runs) {
      final runPaint = Paint()
        ..color = (run.isUp ? Colors.green : Colors.red).withOpacity(0.1)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTRB(
          run.startIndex * stepWidth,
          0,
          (run.endIndex + 1) * stepWidth,
          size.height,
        ),
        runPaint,
      );
    }

    // Draw steps
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final x = i * stepWidth;
      final nextX = (i + 1) * stepWidth;

      // Calculate y position (inverted: up = positive score diff)
      final y = centerY - (point.cumulativeScoreDiff / range) * size.height;

      // Draw step
      paint.color = point.weScored ? Colors.green : Colors.red;

      if (i > 0) {
        final prevPoint = points[i - 1];
        final prevY =
            centerY - (prevPoint.cumulativeScoreDiff / range) * size.height;

        // Horizontal line from previous point
        canvas.drawLine(Offset(x, prevY), Offset(x, prevY), paint);

        // Vertical line (step up or down)
        canvas.drawLine(Offset(x, prevY), Offset(x, y), paint);
      }

      // Horizontal line for this point (always draw to end of chart for last point)
      canvas.drawLine(Offset(x, y), Offset(nextX, y), paint);

      // Draw outcome label in the step box
      final textPainter = TextPainter(
        text: TextSpan(
          text: point.outcome,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Position text: below the line for our points, above for opponent points
      final textX = x + (stepWidth - textPainter.width) / 2;
      final textY = point.weScored 
          ? y + 2  // Below the line for our points
          : y - textPainter.height - 2;  // Above the line for opponent points
      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
