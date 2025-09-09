import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TopBorderCountdownBar extends StatefulWidget {
  final Duration totalDuration;            // e.g., 5 minutes
  final Duration initialRemaining;         // computed once when screen opens
  final String lottieAssetPath;            // 'assets/tortoise_walk.json'
  final double barHeight;                  // thickness of the top border bar
  final double tortoiseSize;               // size of the lottie animation
  final Color trackColor;                  // background of the bar
  final Color fillColor;                   // filled color of the bar
  final Color timeTextColor;               // color for MM:SS text
  final EdgeInsetsGeometry padding;        // inner padding
  final bool showTimeBelow;                // time label position (below the bar)
  final VoidCallback? onCompleted;         // called at 0

  const TopBorderCountdownBar({
    super.key,
    this.totalDuration = const Duration(minutes: 5),
    required this.initialRemaining,
    this.lottieAssetPath = 'assets/confirm-order.json',
    this.barHeight = 6.0,
    this.tortoiseSize = 36.0,
    this.trackColor = const Color(0xFFE5E7EB),
    this.fillColor = const Color(0xFF10B981),
    this.timeTextColor = const Color(0xFF111827),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.showTimeBelow = true,
    this.onCompleted,
  });

  @override
  State<TopBorderCountdownBar> createState() => _TopBorderCountdownBarState();
}

class _TopBorderCountdownBarState extends State<TopBorderCountdownBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _elapsedFromRemaining(Duration remaining) {
    final total = widget.totalDuration.inMilliseconds;
    final rem = remaining.inMilliseconds.clamp(0, total);
    return total == 0 ? 1.0 : (total - rem) / total;
  }

  void _startFromInitialRemaining() {
    final clamped = Duration(
      milliseconds: widget.initialRemaining.inMilliseconds.clamp(
        0,
        widget.totalDuration.inMilliseconds,
      ),
    );
    _controller.value = _elapsedFromRemaining(clamped);
    if (_controller.value >= 1.0) {
      widget.onCompleted?.call();
    } else {
      _controller.forward();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.totalDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted?.call();
        }
      });
    _startFromInitialRemaining();
  }

  @override
  void didUpdateWidget(covariant TopBorderCountdownBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalDuration != widget.totalDuration) {
      final p = _controller.value;
      _controller.duration = widget.totalDuration;
      _controller.value = p.clamp(0.0, 1.0);
    }
    if (oldWidget.initialRemaining != widget.initialRemaining) {
      _startFromInitialRemaining();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final s = d.inSeconds.clamp(0, 359999);
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final remainingFraction = 1.0 - _controller.value; // 1..0
          final remaining = Duration(
            milliseconds:
                (widget.totalDuration.inMilliseconds * remainingFraction).round(),
          );

          final timeLabel = Text(
            _fmt(remaining),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.timeTextColor,
            ),
          );

          final bar = LayoutBuilder(
            builder: (_, constraints) {
              final width = constraints.maxWidth;
              final filledWidth = (width * remainingFraction).clamp(0.0, width);
              final tortoiseW = widget.tortoiseSize;

              double tortoiseLeft = filledWidth - (tortoiseW / 2);
              tortoiseLeft = tortoiseLeft.clamp(0.0, width - tortoiseW);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  Container(
                    height: widget.barHeight,
                    width: width,
                    decoration: BoxDecoration(
                      color: widget.trackColor,
                      borderRadius: BorderRadius.circular(widget.barHeight / 2),
                    ),
                  ),
                  // Fill (shrinks right -> left)
                  Container(
                    height: widget.barHeight,
                    width: filledWidth,
                    decoration: BoxDecoration(
                      color: widget.fillColor,
                      borderRadius: BorderRadius.circular(widget.barHeight / 2),
                    ),
                  ),
                  // Tortoise traveling right -> left
                  Positioned(
                    left: tortoiseLeft,
                    top: -((widget.tortoiseSize - widget.barHeight) / 2),
                    child: SizedBox(
                      width: widget.tortoiseSize,
                      height: widget.tortoiseSize,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                        child: Lottie.asset(
                          widget.lottieAssetPath,
                          repeat: remaining > Duration.zero,
                          animate: remaining > Duration.zero,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.hourglass_top_rounded,
                            color: Colors.green,
                            size: widget.tortoiseSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.showTimeBelow
                ? [bar, const SizedBox(height: 8), timeLabel]
                : [timeLabel, const SizedBox(height: 8), bar],
          );
        },
      ),
    );
  }
}