import 'dart:math';

import 'package:flutter/material.dart';

class CircleSegmentWidget extends StatefulWidget {
  final int current;
  final int target;

  const CircleSegmentWidget({
    super.key,
    required this.current,
    required this.target,
  });

  @override
  State<CircleSegmentWidget> createState() => _CircleSegmentWidgetState();
}

class _CircleSegmentWidgetState extends State<CircleSegmentWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.current < widget.target) Text(widget.current.toString()),
        if (widget.current == widget.target) const Icon(Icons.check_rounded),
        CustomPaint(
          size: const Size(60, 60), // Size of the canvas
          painter: CircleArcPainter(widget.current, widget.target),
        ),
      ],
    );
  }
}

class CircleArcPainter extends CustomPainter {
  final int coloredSegments;
  final int totalSegments;

  CircleArcPainter(this.coloredSegments, this.totalSegments);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0 // Increase stroke width for the arcs
      ..color = Colors.grey; // Change the uncolored arcs to grey

    final Paint coloredPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0 // Increase stroke width for the colored arcs
      ..color = coloredSegments == totalSegments
          ? const Color.fromARGB(255, 2, 179, 8)
          : const Color.fromARGB(255, 33, 150, 243);

    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        min(size.width / 2, size.height / 2) - 15; // Adjust radius for padding

    // Calculate angle for each segment
    final double anglePerSegment = 2 * pi / totalSegments;

    // Draw each arc segment along the circumference
    for (int i = 0; i < totalSegments; i++) {
      final startAngle = i * anglePerSegment;
      final sweepAngle = anglePerSegment - 0.05; // Small gap between arcs

      // Draw the arc for circumference
      final rect = Rect.fromCircle(center: center, radius: radius);

      // Color the arc if within the coloredSegments count
      if (i < coloredSegments) {
        canvas.drawArc(rect, startAngle, sweepAngle, false, coloredPaint);
      } else {
        // Draw the grey arc for the remaining segments
        canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Repaint when state changes
  }
}
