/// The five buckets every double-entry ledger sorts accounts into.
///
/// Stored as the enum index, so the order of these values must never change —
/// only append. Existing rows on a user's phone hold the old numbers.
enum AccountType {
  /// Money and things owed to the household. Cash, bank, an advance handed to
  /// domestic staff that has not been worked off yet.
  asset,

  /// Money the household owes. Committee/BC obligations, a shopkeeper's khata.
  liability,

  /// Money coming in. Salary, business, rent received.
  income,

  /// Money going out. Groceries, bills, school fees, staff salary.
  expense,

  /// Opening balances and corrections. Keeps the books balanced on day one
  /// without inventing fake income.
  equity,
}

extension AccountTypeBehaviour on AccountType {
  /// True when a positive stored balance is the account's natural state.
  ///
  /// Every posting is stored signed and every entry sums to zero, so an
  /// account's raw balance is just the sum of its postings. For assets and
  /// expenses that number reads naturally. For liabilities, income and equity
  /// the natural balance is negative internally, so [displayBalanceSign]
  /// flips it before it reaches the screen — a user should see income of
  /// Rs 80,000, not Rs -80,000.
  bool get normalBalanceIsDebit =>
      this == AccountType.asset || this == AccountType.expense;

  int get displayBalanceSign => normalBalanceIsDebit ? 1 : -1;

  /// Whether this account can be the source of money in a simple expense
  /// entry — i.e. something the household actually holds money in.
  bool get isSpendable => this == AccountType.asset;
}
