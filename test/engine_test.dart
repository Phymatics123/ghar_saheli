import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_saheli/src/core/hlc.dart';
import 'package:ghar_saheli/src/core/money.dart';
import 'package:ghar_saheli/src/core/ulid.dart';
import 'package:ghar_saheli/src/domain/models.dart';

/// Pure-logic tests. No database, no device, no plugins — so they run in a
/// second on the laptop with `flutter test`.
///
/// Database behaviour is checked on a real phone through the self-check button
/// on the dev screen instead. Running SQLite inside `flutter test` on Windows
/// needs a native sqlite3 library beside the test runner, and that is a setup
/// problem, not a correctness one.
void main() {
  group('Money', () {
    test('stores paisa, never floating point', () {
      expect(Money.rupees(1).paisa, 100);
      expect((Money.rupees(10) + Money.rupees(20)).paisa, 3000);
      expect((Money.rupees(10) - Money.rupees(25)).paisa, -1500);
    });

    test('groups digits the South Asian way', () {
      expect(Money.rupees(999).format(symbol: false), '999');
      expect(Money.rupees(1000).format(symbol: false), '1,000');
      expect(Money.rupees(100000).format(symbol: false), '1,00,000');
      expect(Money.rupees(12345678).format(symbol: false), '1,23,45,678');
    });

    test('hides paisa unless there are any', () {
      expect(Money.rupees(2500).format(), 'Rs 2,500');
      expect(const Money(250050).format(), 'Rs 2,500.50');
    });

    test('parses what people actually type', () {
      expect(Money.tryParse('1200')?.paisa, 120000);
      expect(Money.tryParse('Rs 1,250.50')?.paisa, 125050);
      expect(Money.tryParse('  2,500 ')?.paisa, 250000);
      expect(Money.tryParse('-300')?.paisa, -30000);
      // Urdu / Arabic-Indic digits from a localised keyboard.
      expect(Money.tryParse('۱۲۳')?.paisa, 12300);
      expect(Money.tryParse('٤٥')?.paisa, 4500);
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse(''), isNull);
    });

    test('truncates beyond two decimal places instead of rounding up', () {
      expect(Money.tryParse('10.999')?.paisa, 1099);
    });

    test('short form uses lakh and crore', () {
      expect(Money.rupees(150000).formatShort(symbol: false), '1.5 lakh');
      expect(Money.rupees(25000000).formatShort(symbol: false), '2.5 crore');
    });
  });

  group('Hlc', () {
    test('advances even when the wall clock stands still', () {
      const Hlc start = Hlc(1000, 0, 'deviceA');
      final Hlc next = start.tick(1000);
      expect(next.millis, 1000);
      expect(next.counter, 1);
      expect(next > start, isTrue);
    });

    test('advances when the wall clock moves forward', () {
      const Hlc start = Hlc(1000, 5, 'deviceA');
      final Hlc next = start.tick(2000);
      expect(next.millis, 2000);
      expect(next.counter, 0);
    });

    test('never goes backwards when the phone clock does', () {
      const Hlc start = Hlc(5000, 0, 'deviceA');
      final Hlc next = start.tick(1000); // clock was set back
      expect(next.millis, 5000);
      expect(next.counter, 1);
      expect(next > start, isTrue);
    });

    test('orders past an event from a device that is ahead', () {
      const Hlc local = Hlc(1000, 0, 'deviceA');
      const Hlc remote = Hlc(4000, 3, 'deviceB');
      final Hlc merged = local.merge(remote, 1000);
      expect(merged > remote, isTrue);
      expect(merged.nodeId, 'deviceA');
    });

    test('refuses a remote clock that is wildly ahead', () {
      const Hlc local = Hlc(1000, 0, 'deviceA');
      final Hlc absurd = Hlc(1000 + Hlc.maxDriftMillis + 1, 0, 'deviceB');
      expect(() => local.merge(absurd, 1000), throwsStateError);
    });

    test('packed form sorts the same as compareTo', () {
      const Hlc a = Hlc(1000, 0, 'deviceA');
      const Hlc b = Hlc(1000, 1, 'deviceA');
      const Hlc c = Hlc(2000, 0, 'deviceA');
      final List<String> packed = <String>[c.packed, a.packed, b.packed]..sort();
      expect(packed, <String>[a.packed, b.packed, c.packed]);
    });

    test('survives a round trip through text', () {
      const Hlc original = Hlc(1723456789012, 7, '01HQ8ZK9');
      expect(Hlc.parse(original.packed), original);
    });
  });

  group('Ulid', () {
    test('is 26 characters and unique', () {
      final Set<String> seen = <String>{};
      for (int i = 0; i < 2000; i++) {
        final String id = Ulid.generate();
        expect(id.length, 26);
        expect(seen.add(id), isTrue, reason: 'duplicate id $id');
      }
    });

    test('sorts chronologically as plain text', () {
      final String older =
          Ulid.generate(DateTime.fromMillisecondsSinceEpoch(1000));
      final String newer =
          Ulid.generate(DateTime.fromMillisecondsSinceEpoch(2000));
      expect(older.compareTo(newer) < 0, isTrue);
    });

    test('carries its timestamp', () {
      final DateTime when = DateTime.fromMillisecondsSinceEpoch(1723456789012);
      expect(Ulid.timestampOf(Ulid.generate(when)), when);
    });
  });

  group('DraftEntry', () {
    DraftPosting line(String account, int rupees) => DraftPosting(
          accountId: account,
          amount: Money.rupees(rupees),
        );

    test('accepts an entry whose lines cancel out', () {
      final DraftEntry entry = DraftEntry(
        description: 'Raashan',
        postings: <DraftPosting>[
          line('expense.groceries', 2500),
          line('asset.cash', -2500),
        ],
      );
      expect(entry.validate, returnsNormally);
      expect(entry.magnitude, Money.rupees(2500));
    });

    test('refuses an entry that does not balance', () {
      final DraftEntry entry = DraftEntry(
        description: 'Wrong',
        postings: <DraftPosting>[
          line('expense.groceries', 2500),
          line('asset.cash', -2000),
        ],
      );
      expect(entry.validate, throwsA(isA<LedgerValidationError>()));
    });

    test('refuses a single-sided entry', () {
      final DraftEntry entry = DraftEntry(
        description: 'Half an entry',
        postings: <DraftPosting>[line('expense.groceries', 2500)],
      );
      expect(entry.validate, throwsA(isA<LedgerValidationError>()));
    });

    test('refuses a zero line', () {
      final DraftEntry entry = DraftEntry(
        description: 'Nothing',
        postings: <DraftPosting>[
          line('expense.groceries', 0),
          line('asset.cash', 0),
        ],
      );
      expect(entry.validate, throwsA(isA<LedgerValidationError>()));
    });

    test('refuses a blank description', () {
      final DraftEntry entry = DraftEntry(
        description: '   ',
        postings: <DraftPosting>[
          line('expense.groceries', 100),
          line('asset.cash', -100),
        ],
      );
      expect(entry.validate, throwsA(isA<LedgerValidationError>()));
    });

    test('keeps the date and drops the time', () {
      final DraftEntry entry = DraftEntry(
        description: 'Evening shopping',
        occurredOn: DateTime(2026, 8, 6, 22, 47),
        postings: <DraftPosting>[
          line('expense.groceries', 100),
          line('asset.cash', -100),
        ],
      );
      expect(entry.occurredOn, DateTime(2026, 8, 6));
    });

    test('a three-line entry balances — advance netted against salary', () {
      // Nasreen is owed Rs 12,000 but already took Rs 5,000 as peshgi.
      final DraftEntry entry = DraftEntry(
        description: 'Nasreen salary',
        postings: <DraftPosting>[
          line('expense.staff', 12000),
          line('asset.staff.nasreen.advance', -5000),
          line('asset.cash', -7000),
        ],
      );
      expect(entry.validate, returnsNormally);
      expect(entry.magnitude, Money.rupees(12000));
    });
  });
}
