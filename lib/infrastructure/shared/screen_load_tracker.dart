import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Global runtime switch for debug-mode screen load logging.
///
/// Logging is automatically disabled in release builds via `kDebugMode`.
class ScreenLoadTrackerConfig {
  /// Set to `false` to disable logging while keeping code in place.
  static bool enabled = true;

  static bool get shouldLog => kDebugMode && enabled;
}

/// Measures time from `initState()` until the first rendered frame.
///
/// Intended for wrapping a screen that might not be a `StatefulWidget`
/// (for example, your `BaseView` pages).
class ScreenLoadTracker extends StatefulWidget {
  final Widget child;

  /// If omitted, defaults to the wrapped widget's type name.
  final String? screenName;

  /// Optional: log an extra "data-ready" metric once [dataReadyCondition] becomes true.
  ///
  /// This is useful when your screen shows initial UI first and then fills it
  /// with async/API data in a later frame.
  final bool Function()? dataReadyCondition;

  /// Optional: which listenables should trigger re-checking [dataReadyCondition].
  ///
  /// Typically pass relevant GetX `Rx*` observables (they implement [Listenable]).
  ///
  /// Note: GetX's `Rx*` types don't always implement Flutter's `Listenable`
  /// interface in a way that Dart's type system accepts, so we keep this as
  /// `List<Object>` and call `addListener/removeListener` dynamically.
  final List<Object>? dataReadyListenables;

  const ScreenLoadTracker({
    super.key,
    required this.child,
    this.screenName,
    this.dataReadyCondition,
    this.dataReadyListenables,
  });

  @override
  State<ScreenLoadTracker> createState() => _ScreenLoadTrackerState();
}

class _ScreenLoadTrackerState extends State<ScreenLoadTracker> {
  Stopwatch? _paintStopwatch;
  Stopwatch? _dataReadyStopwatch;
  bool _paintLogged = false;
  bool _dataReadyLogged = false;

  late final String _name = widget.screenName?.trim().isNotEmpty == true
      ? widget.screenName!.trim()
      : widget.child.runtimeType.toString().split('.').last;

  Timer? _dataPollTimer;

  bool get _hasDataReadyConfig => widget.dataReadyCondition != null;

  @override
  void initState() {
    super.initState();

    if (!ScreenLoadTrackerConfig.shouldLog) return;

    _paintStopwatch = Stopwatch()..start();
    if (_hasDataReadyConfig) {
      _dataReadyStopwatch = Stopwatch()..start();
      // Re-check immediately in case data is already ready by the time we build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeLogDataReady();
      });

      // Debug-only polling is more reliable across GetX reactive types than
      // assuming Flutter's listener interfaces are implemented.
      _dataPollTimer = Timer.periodic(const Duration(milliseconds: 75), (_) {
        _maybeLogDataReady();

        // Safety stop: avoid infinite polling if the condition never becomes true.
        final elapsed = _dataReadyStopwatch?.elapsed;
        if (elapsed != null && elapsed >= const Duration(seconds: 20)) {
          _dataPollTimer?.cancel();
          _dataPollTimer = null;
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Widget can be disposed quickly during navigation transitions.
      if (!mounted || _paintLogged) return;

      _paintLogged = true;
      _paintStopwatch?.stop();

      final ms = _paintStopwatch?.elapsedMilliseconds ?? 0;
      debugPrint('🚀 [$_name] Load Time: $ms ms');
    });
  }

  @override
  void dispose() {
    _dataPollTimer?.cancel();
    _dataPollTimer = null;
    super.dispose();
  }

  void _maybeLogDataReady() {
    if (!mounted || _dataReadyLogged) return;

    if (widget.dataReadyCondition?.call() != true) return;

    _dataReadyLogged = true;
    // Wait for the next frame so the populated state has a chance to paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _dataReadyStopwatch?.stop();
      _dataPollTimer?.cancel();
      _dataPollTimer = null;

      final ms = _dataReadyStopwatch?.elapsedMilliseconds ?? 0;
      debugPrint('🚀 [$_name] Data Ready Load Time: $ms ms');
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

