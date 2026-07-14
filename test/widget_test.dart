import 'package:flutter_test/flutter_test.dart';
import 'package:our_story/core/utils/date_formatter.dart';
import 'package:our_story/core/services/auth_service.dart';

void main() {
  group('DateFormatter', () {
    test('daysSince computes a non-negative day count for a past date', () {
      final start = DateTime(2017, 10, 1);
      final later = DateTime(2017, 10, 11);
      expect(DateFormatter.daysSince(start, later), 10);
    });
  });

  group('AuthService', () {
    test('hashing the same password twice produces the same hash', () {
      final auth = AuthService.instance;
      final a = auth.hash('our-story-2026');
      final b = auth.hash('our-story-2026');
      expect(a, b);
    });

    test('verify succeeds only for the correct password', () {
      final auth = AuthService.instance;
      final hash = auth.hash('correct-password');
      expect(auth.verify('correct-password', hash), isTrue);
      expect(auth.verify('wrong-password', hash), isFalse);
    });
  });
}
