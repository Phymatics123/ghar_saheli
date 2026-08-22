import '../core/money.dart';
import '../data/database.dart';
import 'account_type.dart';

/// An account plus its current balance, already sign-corrected for display.
class AccountBalance {
  const AccountBalance({required this.account, required this.rawBalance});

  final AccountRow account;

  /// Sum of the account's live postings, in the ledger's internal sign.
  final Money rawBalance;

  /// What the user should see. Income of Rs 80,000 reads as a positive
  /// number even though it is stored as a credit.
  Money get displayBalance => rawBalance * account.type.displayBalanceSign;

  String get id => account.id;
  String get code => account.code;
  AccountType get type => account.type;

  @override
  String toString() => '${account.code}: ${displayBalance.format()}';
}

/// One line of a draft entry, before it is written.
class DraftPosting {
  const DraftPosting({
    required this.accountId,
    required this.amount,
    this.memo,
  });

  final String accountId;

  /// Signed. Positive debits the account, negative credits it.
  final Money amount;

  final String? memo;
}

/// An entry the caller wants to record.
///
/// Validation lives here rather than in the repository so a screen can check
/// a form before it ever touches the database.
class DraftEntry {
  DraftEntry({
    required this.description,
    required this.postings,
    DateTime? occurredOn,
    this.note,
  }) : occurredOn = dateOnly(occurredOn ?? DateTime.now());

  final DateTime occurredOn;
  final String description;
  final String? note;
  final List<DraftPosting> postings;

  /// Strips the time of day. Entries are dated, not timestamped — "Tuesday's
  /// shopping" is the fact, 4:07pm is noise, and keeping times would make
  /// day-boundary grouping depend on the hour the user happened to type.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Money get total {
    Money sum = Money.zero;
    for (final DraftPosting posting in postings) {
      sum = sum + posting.amount;
    }
    return sum;
  }

  /// The magnitude a user would call "the amount of this entry".
  Money get magnitude {
    int debits = 0;
    for (final DraftPosting posting in postings) {
      if (posting.amount.isPositive) debits += posting.amount.paisa;
    }
    return Money(debits);
  }

  /// Throws [LedgerValidationError] if this entry would corrupt the books.
  void validate() {
    if (description.trim().isEmpty) {
      throw const LedgerValidationError('An entry needs a description.');
    }
    if (postings.length < 2) {
      throw const LedgerValidationError(
        'Double-entry needs at least two lines: where the money came from and '
        'where it went.',
      );
    }
    for (final DraftPosting posting in postings) {
      if (posting.amount.isZero) {
        throw const LedgerValidationError('A line cannot be for zero rupees.');
      }
      if (posting.accountId.trim().isEmpty) {
        throw const LedgerValidationError('A line is missing its account.');
      }
    }
    if (!total.isZero) {
      throw LedgerValidationError(
        'Entry does not balance — debits and credits differ by '
        '${total.abs.format()}.',
      );
    }
  }
}

/// An entry read back with its lines and the accounts they touch.
class EntryWithPostings {
  const EntryWithPostings({
    required this.entry,
    required this.lines,
  });

  final LedgerEntryRow entry;
  final List<PostingWithAccount> lines;

  String get id => entry.id;
  bool get isVoided => entry.isVoided;
  DateTime get occurredOn => entry.occurredOn;

  /// Total debited — the headline figure for a receipt or a list row.
  Money get magnitude {
    int debits = 0;
    for (final PostingWithAccount line in lines) {
      if (line.amount.isPositive) debits += line.amount.paisa;
    }
    return Money(debits);
  }

  /// The expense or income category this entry is "about", for list display.
  /// Falls back to the first line when an entry is a pure transfer.
  PostingWithAccount? get primaryLine {
    for (final PostingWithAccount line in lines) {
      if (line.account.type == AccountType.expense && line.amount.isPositive) {
        return line;
      }
    }
    for (final PostingWithAccount line in lines) {
      if (line.account.type == AccountType.income && line.amount.isNegative) {
        return line;
      }
    }
    return lines.isEmpty ? null : lines.first;
  }
}

class PostingWithAccount {
  const PostingWithAccount({required this.posting, required this.account});

  final PostingRow posting;
  final AccountRow account;

  Money get amount => Money(posting.amountMinor);
}

/// Totals for a calendar month, per category.
class PeriodSummary {
  const PeriodSummary({
    required this.from,
    required this.to,
    required this.income,
    required this.expense,
    required this.byCategory,
  });

  final DateTime from;
  final DateTime to;
  final Money income;
  final Money expense;

  /// Expense accounts with a non-zero total, largest first.
  final List<CategoryTotal> byCategory;

  /// Positive when the household took in more than it spent.
  Money get net => income - expense;

  int get dayCount => to.difference(from).inDays + 1;
}

class CategoryTotal {
  const CategoryTotal({required this.account, required this.total});

  final AccountRow account;
  final Money total;
}

/// Thrown when a write would break double-entry invariants.
///
/// Its own type so callers can show the message to the user instead of a
/// generic failure — these are always the user's input being wrong, not a bug.
class LedgerValidationError implements Exception {
  const LedgerValidationError(this.message);

  final String message;

  @override
  String toString() => message;
}
