import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:lottie/lottie.dart';

/// Self-contained countdown progress bar widget
/// - Starts full and shrinks from right to left over [totalMinutes] (default 5).
/// - Tortoise Lottie walks along the bar from right to left.
/// - Shows remaining time as MM:SS above the bar.
/// - Smooth animation and proper disposal of timers/controllers.
/// - Can be driven internally (by minutes-elapsed) or externally by remaining seconds.
class CountdownProgressBar extends StatefulWidget {
  /// Minutes elapsed since the event started. Used when [remainingSecondsExternal] is null.
  final int diffMinutes;

  /// If provided, widget uses this as the authoritative seconds left and
  /// animates smoothly every second without running its own timer.
  final int? remainingSecondsExternal;

  /// Total countdown minutes. Default 5.
  final int totalMinutes;

  /// Called once when countdown reaches zero.
  final VoidCallback? onFinished;

  /// Height of the progress bar.
  final double barHeight;

  /// Colors for track and fill.
  final Color? trackColor;
  final Color? fillColor;

  /// Path to the Lottie animation asset of the tortoise.
  /// Default: 'assets/tortoise_walk.json'.
  final String lottieAssetPath;

  const CountdownProgressBar({
    super.key,
    required this.diffMinutes,
    this.remainingSecondsExternal,
    this.totalMinutes = 5,
    this.onFinished,
    this.barHeight = 6,
    this.trackColor,
    this.fillColor,
    this.lottieAssetPath = 'assets/rabbit-running.json',
  });

  @override
  State<CountdownProgressBar> createState() => _CountdownProgressBarState();
}

class _CountdownProgressBarState extends State<CountdownProgressBar>
    with TickerProviderStateMixin {
  late int _totalSeconds; // total countdown seconds

  // Internal mode (when remainingSecondsExternal is null)
  AnimationController? _controller; // drives progress from current -> 0
  Animation<double>? _progress; // fraction remaining [1..0]
  Timer? _timer; // ticks once per second for MM:SS label
  int _remainingSeconds = 0; // remaining seconds for label
  bool _completedFired = false;

  // External mode support
  double _prevExternalFraction = 1.0;

  bool get _useExternal => widget.remainingSecondsExternal != null;

  @override
  void initState() {
    super.initState();
    _totalSeconds = math.max(0, widget.totalMinutes * 60);
    if (_useExternal) {
      // Initialize previous fraction
      final rs = widget.remainingSecondsExternal!.clamp(0, _totalSeconds);
      _prevExternalFraction = _totalSeconds == 0 ? 0.0 : rs / _totalSeconds;
    } else {
      _initInternalFromDiff(widget.diffMinutes, firstTime: true);
    }
  }

  @override
  void didUpdateWidget(covariant CountdownProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalMinutes != widget.totalMinutes) {
      _totalSeconds = math.max(0, widget.totalMinutes * 60);
    }

    if (_useExternal) {
      // Stop internal resources when switching to external
      _stopTimer();
      _disposeControllerIfAny();
      // If reached zero, fire once
      if ((widget.remainingSecondsExternal ?? 0) <= 0 && !_completedFired) {
        _completedFired = true;
        widget.onFinished?.call();
      }
    } else {
      // Internal mode: re-init only if diffMinutes or totalMinutes changed
      if (oldWidget.diffMinutes != widget.diffMinutes ||
          oldWidget.totalMinutes != widget.totalMinutes) {
        _initInternalFromDiff(widget.diffMinutes);
      }
    }
  }

  void _initInternalFromDiff(int diffMinutes, {bool firstTime = false}) {
    // Elapsed from diffMinutes (clamped to total)
    final int elapsed = math.min(math.max(0, diffMinutes) * 60, _totalSeconds);
    final int newRemaining = _totalSeconds - elapsed;

    if (newRemaining <= 0) {
      _stopTimer();
      _disposeControllerIfAny();
      _remainingSeconds = 0;
      _completedFired = true;
      _buildController(beginFraction: 0, durationSeconds: 0);
      setState(() {});
      return;
    }

    _completedFired = false;

    if (!firstTime) {
      _stopTimer();
      _disposeControllerIfAny();
    }

    _remainingSeconds = newRemaining;
    final double beginFraction =
        _totalSeconds == 0 ? 0.0 : newRemaining / _totalSeconds; // 1.0 -> 0.0
    _buildController(
        beginFraction: beginFraction, durationSeconds: newRemaining);

    // Start ticking for label
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        if (!_completedFired) {
          _completedFired = true;
          widget.onFinished?.call();
        }
        t.cancel();
        return;
      }
      setState(() {
        _remainingSeconds = math.max(0, _remainingSeconds - 1);
      });
    });
  }

  void _buildController(
      {required double beginFraction, required int durationSeconds}) {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSeconds),
    );
    _progress = Tween<double>(begin: beginFraction, end: 0)
        .animate(CurvedAnimation(parent: _controller!, curve: Curves.linear));
    _controller!.forward();
  }

  void _disposeControllerIfAny() {
    try {
      _controller?.dispose();
      _controller = null;
      _progress = null;
    } catch (_) {
      // ignore
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _disposeControllerIfAny();
    super.dispose();
  }

  String _formatMMSS(int totalSeconds) {
    final int mm = (totalSeconds ~/ 60);
    final int ss = (totalSeconds % 60);
    final String mmStr = mm.toString().padLeft(2, '0');
    final String ssStr = ss.toString().padLeft(2, '0');
    return '$mmStr:$ssStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color track =
        widget.trackColor ?? theme.colorScheme.outlineVariant.withOpacity(0.2);
    final Color fill = widget.fillColor ?? theme.colorScheme.primary;

    final double barVisualHeight = math.max(32, widget.barHeight + 20);

    if (_useExternal) {
      final int rs = widget.remainingSecondsExternal!.clamp(0, _totalSeconds);
      final double fraction = _totalSeconds == 0 ? 0.0 : rs / _totalSeconds;

      // When hitting zero for the first time, notify
      if (rs <= 0 && !_completedFired) {
        _completedFired = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onFinished?.call();
        });
      }

      final timeLabel = _formatMMSS(rs);
      return SizedBox(
        height: barVisualHeight,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 0,
              bottom: (widget.barHeight) + 6,
              child: Container(
              
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsTheme.colFF4E4E.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  
                ),
                child: Text(
                  timeLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ColorsTheme.colFF4E4E,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _buildBar(track, fill, fraction),
            ),
          ],
        ),
      );
    }

    // Internal mode using animation controller
    return AnimatedBuilder(
      animation: _progress!,
      builder: (context, child) {
        final timeLabel = _formatMMSS(_remainingSeconds);
        final double fraction = _progress!.value.clamp(0.0, 1.0);
        return SizedBox(
          height: barVisualHeight,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                bottom: (widget.barHeight) + 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    timeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: _buildBar(track, fill, fraction),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(Color track, Color fill, double fraction) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;
        final double clamped = fraction.clamp(0.0, 1.0);

        // Tortoise size and position
        const double tortoiseW = 40;
        const double tortoiseH = 40;
        double tortoiseLeft = barWidth * clamped - (tortoiseW / 2);
        tortoiseLeft = tortoiseLeft.clamp(0.0, barWidth - tortoiseW);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomLeft,
          children: [
            // Track
            Container(
              height: widget.barHeight,
              width: barWidth,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(widget.barHeight / 2),
              ),
            ),
            // Fill (shrinks from right to left)
            Container(
              height: widget.barHeight,
              width: barWidth * clamped,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(widget.barHeight / 2),
              ),
            ),
            // Tortoise Lottie walking along the bar

            Positioned(
              left: tortoiseLeft,
              bottom: (widget.barHeight) - 2,
              child: IgnorePointer(
                  child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                child: Lottie.asset(
                  widget.lottieAssetPath,
                  width: tortoiseW,
                  height: tortoiseH,
                  repeat: true,
                ),
              )),
            ),
          ],
        );
      },
    );
  }
}
