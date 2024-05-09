import 'dart:async';

class CustomStopwatch {
  final Stopwatch _stopwatch = Stopwatch();
  final StreamController<String> _streamController =
      StreamController.broadcast();
  Timer? _timer;

  Stream<String> get tickStream => _streamController.stream;

  void start() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
        final formattedTime = _formatElapsedTime(_stopwatch.elapsed);
        _streamController.add(formattedTime);
      });
    }
  }

  void stop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    }
  }

  void reset() {
    _stopwatch.reset();
    _streamController.add(_formatElapsedTime(_stopwatch.elapsed));
  }

  String _formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds =
        twoDigits((duration.inMilliseconds.remainder(1000) / 10).floor());
    return "$minutes:$seconds.$milliseconds";
  }

  void dispose() {
    _streamController.close();
    _timer?.cancel();
  }
}
