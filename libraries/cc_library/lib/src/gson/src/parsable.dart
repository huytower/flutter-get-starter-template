library gson_parsable;

import 'package:ansicolor/ansicolor.dart';
import 'package:cc_library/src/gson/src/prog.dart';

import 'terminal_web.dart' if (dart.library.io) 'terminal_vm.dart' as io;

/// A parsable object for the GsonDecoder to use
class GsonParsable extends ErrorGenerator {
  final String _parsable;
  int _position = 0;
  bool _ended = false;

  String get parsable => _parsable;

  int get position => _position;

  bool get ended => _ended;

  GsonParsable(this._parsable, {int position = 0}) {
    _position = position;
  }

  /// Get actual and go one forward
  String next() {
    skip();
    return parsable.substring(position - 1, position);
  }

  /// Skip one
  void skip() {
    if (ended) {
      throw error('Input ended');
    }
    _position += 1;
    _checkEnded();
  }

  /// Go Steps back
  void goBack(int number) {
    _position -= number;
    if (_position < 0) {
      _position = 0;
    }
    _checkEnded();
  }

  /// Get actual
  String actual() {
    return parsable.substring(position, position + 1);
  }

  /// peek forward
  String peek(int number) {
    return has(number)
        ? parsable.substring(position + number, position + number + 1)
        : throw error('Not enough space to peek $number');
  }

  /// test if has next symbol
  bool hasNext() {
    return has(1);
  }

  /// test if has amount of symbols left
  bool has(int space) {
    return parsable.length > position + space;
  }

  /// generate a error at the position of the parsable
  @override
  Exception error(String message, {int from = 0, int to = 0}) {
    return Exception(message + ' at ' + toString(from: from, to: to, err: true));
  }

  /// reformat error
  Exception reformatError(Exception e, [StackTrace? stack]) {
    return Exception(e.toString().substring(10) + 'at ' + toString() + (stack != null ? stack.toString() : ''));
  }

  /// String representation of parsable (marks actual position)
  @override
  String toString({int from = 0, int to = 0, bool err = false}) {
    final red = AnsiPen()..red();
    final redBg = AnsiPen()..red(bg: true);
    if (parsable.length > io.terminalColumns) {
      var start = parsable.length > io.terminalColumns ? (position - (io.terminalColumns / 2) + 3).round() : 0;
      var end = parsable.length > io.terminalColumns
          ? (position + (io.terminalColumns / 2) - 4).round()
          : parsable.length - 1;

      if (start < 0) {
        end += start * -1;
        start = 0;
      }
      if (end >= parsable.length) {
        start -= end - parsable.length + 1;
        end = parsable.length - 1;
      }

      String startletters = '(+$start)', startletters_;
      String endletters = '(+${parsable.length - end + 7})', endletters_;
      end -= endletters.length + startletters.length;

      do {
        endletters_ = endletters;
        startletters = '(+$end)';
        if (endletters.length - endletters_.length > 0) {
          end -= endletters.length - endletters_.length;
        }
      } while (endletters_.length != endletters.length);

      do {
        startletters_ = startletters;
        startletters = '(+$start)';
        if (startletters.length - startletters_.length > 0) {
          end -= startletters.length - startletters_.length;
        }
      } while (startletters_.length != startletters.length);

      if (start < 0) {
        end += start * -1;
        start = 0;
      }

      var pos = position - start + startletters.length + 3;
      var code = '$startletters...' + parsable.substring(start, end) + '...$endletters\n';

      var beforeSelect = code.substring(0, pos - from);
      var selected = code.substring(pos - from, pos + to + 1);
      var afterSelect = code.substring(pos + to + 1);

      var bottom = _repeatString(' ', pos - from) + _repeatString('^', 1 + from + to) + '\n';
      if (err) {
        bottom = red(bottom);
        selected = redBg(selected);
      }

      return 'position ${position + 1}/${parsable.length} (\"${actual()}\")\n\nHere:\n' +
          beforeSelect +
          selected.toString() +
          afterSelect +
          bottom.toString();
    }

    var beforeSelect = parsable.substring(0, position - from);
    var selected = parsable.substring(position - from, position + to + 1);
    var afterSelect = parsable.substring(position + to + 1);

    var bottom = _repeatString(' ', position - from) + _repeatString('^', 1 + from + to) + '\n';

    if (err) {
      bottom = red(bottom);
      selected = redBg(selected);
    }

    return 'position ${position + 1}/${parsable.length} (\"${actual()}\")\n\nHere:\n' +
        beforeSelect +
        selected.toString() +
        afterSelect +
        '\n' +
        bottom.toString();
  }

  String _repeatString(String s, int number) {
    var ret = '';
    for (var i = 0; i < number; i++) {
      ret += s;
    }
    return ret;
  }

  void _checkEnded() {
    _ended = position >= parsable.length - 1;
  }
}
