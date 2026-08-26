import 'package:bright_fortune/relay/core/landing.dart';
import 'package:flutter_test/flutter_test.dart';

/// The verdict wire format and the persisted route memory are the two
/// contracts the backend and older installs depend on. A rename or a
/// changed truthiness rule here silently misroutes users, so both are
/// pinned by tests rather than by convention.
void main() {
  group('Verdict.fromJson', () {
    test('approved reply with a url yields a destination', () {
      final Verdict v = Verdict.fromJson(<String, dynamic>{
        'ok': true,
        'url': 'https://example.com/landing',
        'expires': 1893456000,
      });

      expect(v.approved, isTrue);
      expect(v.hasDestination, isTrue);
      expect(v.url, 'https://example.com/landing');
      expect(v.expiresAt, 1893456000);
    });

    test('approved reply without a url is not a destination', () {
      final Verdict v = Verdict.fromJson(<String, dynamic>{'ok': true});
      expect(v.hasDestination, isFalse);
    });

    test('rejected reply keeps the note and routes nowhere', () {
      final Verdict v = Verdict.fromJson(<String, dynamic>{
        'ok': false,
        'message': 'organic',
      });
      expect(v.hasDestination, isFalse);
      expect(v.note, 'organic');
    });

    test('string expiry is coerced to an int', () {
      final Verdict v = Verdict.fromJson(<String, dynamic>{
        'ok': true,
        'url': 'https://example.com',
        'expires': '1893456000',
      });
      expect(v.expiresAt, 1893456000);
    });
  });

  group('RouteMemory', () {
    test('legacy wire values still resolve', () {
      expect(RouteMemory.parse('web'), RouteMemory.portal);
      expect(RouteMemory.parse('game'), RouteMemory.native);
    });

    test('unknown and missing values fall back to undecided', () {
      expect(RouteMemory.parse(null), RouteMemory.undecided);
      expect(RouteMemory.parse('nonsense'), RouteMemory.undecided);
    });

    test('wire values round-trip', () {
      for (final RouteMemory value in RouteMemory.values) {
        expect(RouteMemory.parse(value.wireValue), value);
      }
    });
  });
}
