/// An amount of Pakistani rupees, stored as a whole number of paisa.
///
/// Money is never a `double` in this app. `0.1 + 0.2` is not `0.3` in binary
/// floating point, and a ledger that is off by a hundredth of a rupee is a
/// ledger the user stops trusting. Every amount is an integer of the smallest
/// unit and only becomes a decimal string at the moment it is displayed.
class Money implements Comparable<Money> {
  const Money(this.paisa);

  /// 100 paisa = 1 rupee.
  static const int paisaPerRupee = 100;

  static const Money zero = Money(0);

  final int paisa;

  factory Money.rupees(int rupees) => Money(rupees * paisaPerRupee);

  /// Rounds half away from zero, matching how a person rounds by hand.
  factory Money.fromDouble(double rupees) =>
      Money((rupees * paisaPerRupee).round());

  /// Parses what a user typed. Accepts `1200`, `1,200`, `1200.50`, `Rs 1200`,
  /// and Urdu-Arabic digits. Returns null when the text is not a number.
  static Money? tryParse(String input) {
    final StringBuffer digits = StringBuffer();
    bool seenDot = false;
    bool negative = false;

    for (int i = 0; i < input.length; i++) {
      final int code = input.codeUnitAt(i);
      if (code == 0x2D && digits.isEmpty) {
        negative = true;
      } else if (code >= 0x30 && code <= 0x39) {
        digits.writeCharCode(code);
      } else if (code >= 0x0660 && code <= 0x0669) {
        // Arabic-Indic ٠..٩
        digits.writeCharCode(code - 0x0660 + 0x30);
      } else if (code >= 0x06F0 && code <= 0x06F9) {
        // Extended Arabic-Indic ۰..۹ as used in Urdu keyboards
        digits.writeCharCode(code - 0x06F0 + 0x30);
      } else if ((code == 0x2E || code == 0x066B) && !seenDot) {
        seenDot = true;
        digits.write('.');
      }
      // Anything else — spaces, commas, "Rs", "روپے" — is ignored.
    }

    final String cleaned = digits.toString();
    if (cleaned.isEmpty || cleaned == '.') return null;

    final int dot = cleaned.indexOf('.');
    if (dot < 0) {
      final int? whole = int.tryParse(cleaned);
      if (whole == null) return null;
      return Money((negative ? -whole : whole) * paisaPerRupee);
    }

    final int? whole = int.tryParse(cleaned.substring(0, dot).isEmpty
        ? '0'
        : cleaned.substring(0, dot));
    if (whole == null) return null;

    String fraction = cleaned.substring(dot + 1);
    if (fraction.length > 2) fraction = fraction.substring(0, 2);
    fraction = fraction.padRight(2, '0');
    final int? fractionValue = int.tryParse(fraction);
    if (fractionValue == null) return null;

    final int total = whole * paisaPerRupee + fractionValue;
    return Money(negative ? -total : total);
  }

  bool get isZero => paisa == 0;
  bool get isNegative => paisa < 0;
  bool get isPositive => paisa > 0;

  Money get abs => Money(paisa.abs());
  Money operator -() => Money(-paisa);
  Money operator +(Money other) => Money(paisa + other.paisa);
  Money operator -(Money other) => Money(paisa - other.paisa);
  Money operator *(int factor) => Money(paisa * factor);

  bool operator >(Money other) => paisa > other.paisa;
  bool operator <(Money other) => paisa < other.paisa;
  bool operator >=(Money other) => paisa >= other.paisa;
  bool operator <=(Money other) => paisa <= other.paisa;

  double get asDouble => paisa / paisaPerRupee;

  /// Formats for display.
  ///
  /// Grouping follows the South Asian convention — 1,00,000 rather than
  /// 100,000 — because that is how the number is read aloud in Urdu (ek lakh)
  /// and how it appears on every utility bill and bank slip in the country.
  /// Dart's own `NumberFormat` groups in threes for `en`, which is why this
  /// is written by hand.
  ///
  /// Paisa are hidden unless asked for. Nobody in a Pakistani kitchen budget
  /// tracks half a rupee, and the extra `.00` on every row is visual noise on
  /// a small screen.
  String format({bool symbol = true, bool paisaDigits = false}) {
    final int magnitude = paisa.abs();
    final int rupees = magnitude ~/ paisaPerRupee;
    final int remainder = magnitude % paisaPerRupee;

    final StringBuffer out = StringBuffer();
    if (paisa < 0) out.write('-');
    if (symbol) out.write('Rs ');
    out.write(_groupSouthAsian(rupees.toString()));
    if (paisaDigits || remainder != 0) {
      out.write('.');
      out.write(remainder.toString().padLeft(2, '0'));
    }
    return out.toString();
  }

  /// Short form for tight spaces: `1.2 lakh`, `3.4 crore`.
  String formatShort({bool symbol = true}) {
    final int rupees = paisa.abs() ~/ paisaPerRupee;
    final String sign = paisa < 0 ? '-' : '';
    final String prefix = symbol ? 'Rs ' : '';

    if (rupees >= 10000000) {
      return '$sign$prefix${_trim(rupees / 10000000)} crore';
    }
    if (rupees >= 100000) {
      return '$sign$prefix${_trim(rupees / 100000)} lakh';
    }
    if (rupees >= 1000) {
      return '$sign$prefix${_trim(rupees / 1000)}k';
    }
    return format(symbol: symbol);
  }

  static String _trim(double value) {
    final String text = value.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  /// Last three digits stay together, everything above is grouped in twos.
  static String _groupSouthAsian(String digits) {
    if (digits.length <= 3) return digits;

    final String last3 = digits.substring(digits.length - 3);
    String head = digits.substring(0, digits.length - 3);

    final List<String> pairs = <String>[];
    while (head.length > 2) {
      pairs.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) pairs.insert(0, head);

    return '${pairs.join(',')},$last3';
  }

  @override
  int compareTo(Money other) => paisa.compareTo(other.paisa);

  @override
  bool operator ==(Object other) => other is Money && other.paisa == paisa;

  @override
  int get hashCode => paisa.hashCode;

  @override
  String toString() => format();
}
