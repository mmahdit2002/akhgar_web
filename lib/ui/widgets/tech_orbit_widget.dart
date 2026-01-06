import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import to access ThemeCubit
import 'dart:math' as math;
import '../../theme/theme_cubit.dart'; // Import your ThemeCubit
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
    // 1. Detect Theme Mode
    final isDark = context.select((ThemeCubit c) => c.isDark);

    // 2. Define Colors based on mode
    final centerBgColor = isDark ? const Color(0xFF050814).withOpacity(0.8) : Colors.white.withOpacity(0.9);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final iconColor = WebColors.primary;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1D1E);
    final subtitleColor = isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF6C757D);

    return SizedBox(
      width: 500,
      height: 500,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            // Pass isDark to the painter
            painter: _TechRingPainter(_controller.value, isDark),
            child: Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: centerBgColor,
                  boxShadow: [
                    BoxShadow(
                      color: WebColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.precision_manufacturing_outlined, size: 48, color: iconColor),
                    const SizedBox(height: 12),
                    Text(
                      "سیستم‌هایی با",
                      style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    Text(
                      "دقت بالا",
                      style: TextStyle(color: subtitleColor, fontSize: 10, letterSpacing: 4),
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
  final bool isDark; // Add isDark field

  _TechRingPainter(this.progress, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..style = PaintingStyle.stroke;

    // Define base colors for rings
    final baseRingColor = isDark ? Colors.white : Colors.black;

    // Ring 1: Outer Dashed (Slow Rotate Clockwise)
    paint.color = baseRingColor.withOpacity(0.05);
    paint.strokeWidth = 1;
    _drawDashedCircle(canvas, center, 240, paint, 40, progress * math.pi);

    // Ring 2: Primary Arc (Rotate Counter-Clockwise)
    // Keep secondary color but adjust opacity for light mode visibility
    paint.color = WebColors.secondary.withOpacity(isDark ? 0.3 : 0.6);
    paint.strokeWidth = 2;
    final rect2 = Rect.fromCircle(center: center, radius: 200);
    canvas.drawArc(rect2, -progress * 2 * math.pi, math.pi / 2, false, paint);
    canvas.drawArc(rect2, -progress * 2 * math.pi + math.pi, math.pi / 2, false, paint);

    // Ring 3: Accent Ticks (Fast Rotate)
    paint.color = WebColors.primary.withOpacity(isDark ? 0.4 : 0.8);
    paint.strokeWidth = 4;
    final rect3 = Rect.fromCircle(center: center, radius: 160);
    canvas.drawArc(rect3, progress * 3 * math.pi, math.pi / 6, false, paint);
    canvas.drawArc(rect3, progress * 3 * math.pi + math.pi, math.pi / 6, false, paint);

    // Ring 4: Static Decorative Ring
    paint.color = baseRingColor.withOpacity(0.03);
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
  bool shouldRepaint(covariant _TechRingPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
