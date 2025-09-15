import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularCountdownBadge extends StatelessWidget {
  final int remainingSeconds; // remaining seconds (>=0)
  final int totalSeconds; // initial total seconds (>0)
  final String subtitle; // e.g., 'until pickup' or 'ends in'
  final double size; // overall diameter
  final double strokeWidth;
  final Color? trackColor;
  final Color? progressColor;
  final bool showProgressArc;

  const CircularCountdownBadge({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.subtitle,
    this.size = 64,
    this.strokeWidth = 6,
    this.trackColor,
    this.progressColor,
    this.showProgressArc = true,
  });
  

  // String _formatMMSS(int seconds) {
  //   final s = seconds.clamp(0, 359999); // max 99:59:59 safeguard
  //   final mm = (s ~/ 60).toString().padLeft(2, '0');
  //   final ss = (s % 60).toString().padLeft(2, '0');
  //   return '$mm:$ss';
  // }

  // Always show as Hh Mm Ss (e.g., 0h 56m 45s)
  String _formatHMS(int seconds) {
    final s = seconds.clamp(0, 359999); // cap at 99:59:59
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    return '${h}h ${m}m ${sec}s';
  }

  @override
  Widget build(BuildContext context) {

    
    final theme = Theme.of(context);
    final Color track = trackColor ?? Colors.white.withOpacity(0.25);
    final Color progress = progressColor ?? Colors.white;

    final int tot = totalSeconds > 0 ? totalSeconds : 1; // avoid div by 0
    final int rem = remainingSeconds.clamp(0, tot);
    final double fraction = rem / tot; // 1 -> 0
    final bool isCompleted = rem <= 0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track (only if showing progress arc and not completed)
          if (showProgressArc && !isCompleted)
            CustomPaint(
              size: Size.square(size),
              painter: _CirclePainter(
                color: track,
                strokeWidth: strokeWidth,
                sweepFraction: 1.0,
              ),
            ),
          // Progress (only after pickup starts and not completed)
          if (showProgressArc && !isCompleted)
            CustomPaint(
              size: Size.square(size),
              painter: _CirclePainter(
                color: progress,
                strokeWidth: strokeWidth,
                sweepFraction: fraction,
              ),
            ),
          // White border when arc is hidden or when completed
          if (!showProgressArc || isCompleted)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: strokeWidth),
              ),
            ),
          // Center labels
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCompleted)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size - strokeWidth * 5, // keep within circle padding
                  ),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 9,
                    ),
                  ),
                ),
              if (!isCompleted) const SizedBox(height: 2),
              if (!isCompleted)
                Text(
                  _formatHMS(rem),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              if (isCompleted)
                Text(
                  'Pickup Time Completed',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double sweepFraction; // 0..1

  _CirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Start from top (-pi/2) and sweep clockwise
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * sweepFraction.clamp(0.0, 1.0);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.sweepFraction != sweepFraction;
  }
}