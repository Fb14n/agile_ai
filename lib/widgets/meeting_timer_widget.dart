import 'package:flutter/material.dart';

/// Kreisförmiger Timer-Ring mit Countdown-Anzeige für Zeremonien.
class MeetingTimerWidget extends StatelessWidget {
  final int elapsedSeconds;
  final int maxSeconds;
  final bool running;
  final VoidCallback onStartPause;
  final VoidCallback onReset;

  const MeetingTimerWidget({
    super.key,
    required this.elapsedSeconds,
    required this.maxSeconds,
    required this.running,
    required this.onStartPause,
    required this.onReset,
  });

  String get _formatted {
    final remaining = (maxSeconds - elapsedSeconds).clamp(0, maxSeconds);
    final min = (remaining ~/ 60).toString().padLeft(2, '0');
    final sec = (remaining % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  double get _progress =>
      maxSeconds > 0 ? (elapsedSeconds / maxSeconds).clamp(0.0, 1.0) : 0.0;

  bool get _expired => maxSeconds > 0 && elapsedSeconds >= maxSeconds;

  Color _color(BuildContext context) {
    if (_expired) return Colors.red;
    if (_progress > 0.8) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey[300],
                  color: _color(context),
                ),
                Center(
                  child: Icon(
                    _expired ? Icons.alarm_off : Icons.timer,
                    size: 14,
                    color: _color(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatted,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _color(context),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(running ? Icons.pause : Icons.play_arrow, size: 18),
            onPressed: onStartPause,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          IconButton(
            icon: const Icon(Icons.replay, size: 16),
            onPressed: onReset,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}
