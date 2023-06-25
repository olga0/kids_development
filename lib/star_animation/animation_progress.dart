import 'dart:math';

/// Utility class to compute an animation progress between two points in time.
///
/// On creation you specify a [startTime] and a [duration].
///
/// You can query the progress value - a value between `0.0` and `11.0` - by
/// calling [progress] and passing the current time.
class AnimationProgress {
  final Duration duration;
  final Duration startTime;

  /// Creates an [AnimationProgress].
  AnimationProgress({required this.duration, required this.startTime});

  /// Queries the current progress value based on the specified [startTime] and
  /// [duration] as a value between `0.0` and `1.0`. It will automatically
  /// clamp values this interval to fit in.
  double progress(Duration time) => max(0.0,
      min((time - startTime).inMilliseconds / duration.inMilliseconds, 1.0));
}