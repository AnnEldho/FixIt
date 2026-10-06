import 'package:flutter_test/flutter_test.dart';

import 'package:fixit/core/utils/date_formatter.dart';
import 'package:fixit/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);
    });

    test('phone', () {
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('+91 98765 43210'), isNull);
    });

    test('password', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('confirmPassword', () {
      final validate = Validators.confirmPassword(() => 'secret1');
      expect(validate('other'), isNotNull);
      expect(validate('secret1'), isNull);
    });
  });

  group('DateFormatter', () {
    test('date formats day-month-year', () {
      expect(DateFormatter.date(DateTime(2026, 10, 6)), '06 Oct 2026');
      expect(DateFormatter.date(null), '—');
    });

    test('timeAgo handles recent times', () {
      expect(DateFormatter.timeAgo(DateTime.now()), 'just now');
    });
  });
}
