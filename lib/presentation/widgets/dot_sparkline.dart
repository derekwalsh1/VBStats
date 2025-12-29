import 'package:flutter/material.dart';

/// A sparkline that shows dots at specific rally indices to visualize when events occurred
class DotSparkline extends StatelessWidget {
  final List<int> occurrenceIndices;
  final int totalRallies;
  final Color color;
  final double height;
  final double dotSize;

  const DotSparkline({
    required this.occurrenceIndices,
    required this.totalRallies,
    required this.color,
    this.height = 20.0,
    this.dotSize = 3.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (occurrenceIndices.isEmpty || totalRallies == 0) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: DotSparklinePainter(
          occurrenceIndices: occurrenceIndices,
          totalRallies: totalRallies,
          color: color,
          dotSize: dotSize,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class DotSparklinePainter extends CustomPainter {
  final List<int> occurrenceIndices;
  final int totalRallies;
  final Color color;
  final double dotSize;

  DotSparklinePainter({
    required this.occurrenceIndices,
    required this.totalRallies,
    required this.color,
    required this.dotSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (occurrenceIndices.isEmpty || totalRallies == 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a light background line to show the timeline
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1;
    
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      bgPaint,
    );

    // Draw dots at occurrence positions
    for (final index in occurrenceIndices) {
      if (index < 0 || index >= totalRallies) continue;
      
      // Handle edge case where there's only 1 rally
      final x = totalRallies == 1 
          ? size.width / 2 
          : (index / (totalRallies - 1)) * size.width;
      final y = size.height / 2;
      
      canvas.drawCircle(
        Offset(x, y),
        dotSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
