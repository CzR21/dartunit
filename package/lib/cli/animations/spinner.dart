import 'dart:async';
import 'dart:io';

import '../../utils/ansi_helper.dart';

/// A terminal spinner for indicating progress during async operations.
class Spinner {
  static const _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  final String message;
  final bool useColor;

  int _index = 0;
  Timer? _timer;

  Spinner(this.message, {this.useColor = true});

  void start() {
    _hideCursor();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      final frame = ANSIHelper.cyan(_frames[_index % _frames.length], useColor);
      stdout.write('\r  $frame $message');
      _index++;
    });
  }

  void stop({String? doneMessage}) {
    _timer?.cancel();
    _timer = null;
    stdout.write('\r  ${ANSIHelper.green('✓', useColor)} ${doneMessage ?? message}\n');
    _showCursor();
  }

  void fail({String? errorMessage}) {
    _timer?.cancel();
    _timer = null;
    stdout.write('\r  ${ANSIHelper.red('✗', useColor)} ${errorMessage ?? message}\n');
    _showCursor();
  }

  void _hideCursor() => stdout.write('\x1B[?25l');
  void _showCursor() => stdout.write('\x1B[?25h');
}
