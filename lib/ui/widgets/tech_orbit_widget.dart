import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/web_colors.dart';

class TechOrbitWidget extends StatefulWidget {
  const TechOrbitWidget({super.key});

  @override
  State<TechOrbitWidget> createState() => _TechOrbitWidgetState();
}

class _TechOrbitWidgetState extends State<TechOrbitWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 500,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _TechRingPainter(_controller.value),
            child: Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF050814).withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(color: WebColors.primary.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.precision_manufacturing_outlined, size: 48, color: WebColors.primary),
                    const SizedBox(height: 12),
                    const Text(
                      "HIGH PRECISION",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    Text(
                      "SYSTEMS",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 4),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TechRingPainter extends CustomPainter {
  final double progress;

  _TechRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..style = PaintingStyle.stroke;

    // Ring 1: Outer Dashed (Slow Rotate Clockwise)
    paint.color = Colors.white.withOpacity(0.05);
    paint.strokeWidth = 1;
    _drawDashedCircle(canvas, center, 240, paint, 40, progress * math.pi);

    // Ring 2: Primary Arc (Rotate Counter-Clockwise)
    paint.color = WebColors.secondary.withOpacity(0.3);
    paint.strokeWidth = 2;
    final rect2 = Rect.fromCircle(center: center, radius: 200);
    canvas.drawArc(rect2, -progress * 2 * math.pi, math.pi / 2, false, paint);
    canvas.drawArc(rect2, -progress * 2 * math.pi + math.pi, math.pi / 2, false, paint);

    // Ring 3: Accent Ticks (Fast Rotate)
    paint.color = WebColors.primary.withOpacity(0.4);
    paint.strokeWidth = 4;
    final rect3 = Rect.fromCircle(center: center, radius: 160);
    canvas.drawArc(rect3, progress * 3 * math.pi, math.pi / 6, false, paint);
    canvas.drawArc(rect3, progress * 3 * math.pi + math.pi, math.pi / 6, false, paint);

    // Ring 4: Static Decorative Ring
    paint.color = Colors.white.withOpacity(0.03);
    paint.strokeWidth = 20;
    canvas.drawCircle(center, 130, paint);
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint, int dashes, double rotationOffset) {
    const double gap = 0.1; // rad
    final double sweep = (2 * math.pi / dashes) - gap;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < dashes; i++) {
      final double start = (i * 2 * math.pi / dashes) + rotationOffset;
      canvas.drawArc(rect, start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
