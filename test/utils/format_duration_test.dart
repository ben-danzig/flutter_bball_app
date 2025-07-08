import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/utils/format_duration.dart';

void main() {
  group('formatDuration', () {
    test('formats minutes and seconds for 60 seconds or more', () {
      expect(formatDuration(300), '5:00'); // 5 minutes
      expect(formatDuration(69), '1:09'); // 1 minute, 9 seconds
      expect(formatDuration(60), '1:00'); // exactly 1 minute
    });

    test('formats seconds only for 10-59 seconds', () {
      expect(formatDuration(59), '59');
      expect(formatDuration(10), '10');
      expect(formatDuration(11), '11');
    });

    test('formats single digit for 0-9 seconds', () {
      expect(formatDuration(9), '9');
      expect(formatDuration(1), '1');
      expect(formatDuration(0), '0');
    });
  });
} 