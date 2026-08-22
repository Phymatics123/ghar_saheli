import 'account_type.dart';

/// A seeded account definition.
class SeedAccount {
  const SeedAccount({
    required this.code,
    required this.name,
    required this.nameUr,
    required this.type,
    required this.iconKey,
    this.parentCode,
    this.sortOrder = 0,
  });

  final String code;
  final String name;
  final String nameUr;
  final AccountType type;
  final String iconKey;
  final String? parentCode;
  final int sortOrder;

  /// Deterministic id derived from the slug.
  ///
  /// Two phones in one household seed independently and still agree on the id
  /// for "Groceries", so a later sync merges instead of producing two
  /// identical-looking categories.
  String get id => 'sys.$code';
}

/// The starting chart of accounts.
///
/// Chosen from how a Pakistani household actually splits money rather than
/// from a generic budgeting template: raashan is its own line because it is
/// the biggest and most volatile one, bijli/gas/paani are separate because
/// each arrives as its own bill on its own date, and mehmaan-nawazi is here
/// because guest expense is real, recurring, and quietly wrecks a monthly
/// budget when it is lumped into groceries.
///
/// Users can add their own; these exist so the app is useful in the first
/// thirty seconds, before anyone has configured anything.
const List<SeedAccount> kSeedAccounts = <SeedAccount>[
  // ---- Where money sits ----
  SeedAccount(
    code: 'asset.cash',
    name: 'Cash in Hand',
    nameUr: 'نقد رقم',
    type: AccountType.asset,
    iconKey: 'wallet',
    sortOrder: 10,
  ),
  SeedAccount(
    code: 'asset.bank',
    name: 'Bank Account',
    nameUr: 'بینک اکاؤنٹ',
    type: AccountType.asset,
    iconKey: 'bank',
    sortOrder: 20,
  ),
  SeedAccount(
    code: 'asset.savings',
    name: 'Savings',
    nameUr: 'بچت',
    type: AccountType.asset,
    iconKey: 'savings',
    sortOrder: 30,
  ),

  // ---- Money coming in ----
  SeedAccount(
    code: 'income.salary',
    name: 'Salary',
    nameUr: 'تنخواہ',
    type: AccountType.income,
    iconKey: 'salary',
    sortOrder: 10,
  ),
  SeedAccount(
    code: 'income.business',
    name: 'Business',
    nameUr: 'کاروبار',
    type: AccountType.income,
    iconKey: 'shop',
    sortOrder: 20,
  ),
  SeedAccount(
    code: 'income.other',
    name: 'Other Income',
    nameUr: 'دیگر آمدنی',
    type: AccountType.income,
    iconKey: 'plus',
    sortOrder: 30,
  ),

  // ---- Money going out ----
  SeedAccount(
    code: 'expense.groceries',
    name: 'Groceries',
    nameUr: 'راشن',
    type: AccountType.expense,
    iconKey: 'groceries',
    sortOrder: 10,
  ),
  SeedAccount(
    code: 'expense.vegetables',
    name: 'Vegetables & Fruit',
    nameUr: 'سبزی پھل',
    type: AccountType.expense,
    iconKey: 'vegetables',
    sortOrder: 20,
  ),
  SeedAccount(
    code: 'expense.milk',
    name: 'Milk & Dairy',
    nameUr: 'دودھ دہی',
    type: AccountType.expense,
    iconKey: 'milk',
    sortOrder: 30,
  ),
  SeedAccount(
    code: 'expense.electricity',
    name: 'Electricity Bill',
    nameUr: 'بجلی کا بل',
    type: AccountType.expense,
    iconKey: 'bulb',
    sortOrder: 40,
  ),
  SeedAccount(
    code: 'expense.gas',
    name: 'Gas Bill',
    nameUr: 'گیس کا بل',
    type: AccountType.expense,
    iconKey: 'flame',
    sortOrder: 50,
  ),
  SeedAccount(
    code: 'expense.water',
    name: 'Water Bill',
    nameUr: 'پانی کا بل',
    type: AccountType.expense,
    iconKey: 'water',
    sortOrder: 60,
  ),
  SeedAccount(
    code: 'expense.rent',
    name: 'Rent',
    nameUr: 'کرایہ',
    type: AccountType.expense,
    iconKey: 'home',
    sortOrder: 70,
  ),
  SeedAccount(
    code: 'expense.education',
    name: 'School Fees',
    nameUr: 'بچوں کی فیس',
    type: AccountType.expense,
    iconKey: 'school',
    sortOrder: 80,
  ),
  SeedAccount(
    code: 'expense.medical',
    name: 'Medical',
    nameUr: 'علاج معالجہ',
    type: AccountType.expense,
    iconKey: 'medical',
    sortOrder: 90,
  ),
  SeedAccount(
    code: 'expense.transport',
    name: 'Transport & Fuel',
    nameUr: 'آمد و رفت',
    type: AccountType.expense,
    iconKey: 'transport',
    sortOrder: 100,
  ),
  SeedAccount(
    code: 'expense.mobile',
    name: 'Mobile & Internet',
    nameUr: 'موبائل انٹرنیٹ',
    type: AccountType.expense,
    iconKey: 'mobile',
    sortOrder: 110,
  ),
  SeedAccount(
    code: 'expense.staff',
    name: 'Household Staff',
    nameUr: 'ملازمین',
    type: AccountType.expense,
    iconKey: 'staff',
    sortOrder: 120,
  ),
  SeedAccount(
    code: 'expense.guests',
    name: 'Guests & Hospitality',
    nameUr: 'مہمان نوازی',
    type: AccountType.expense,
    iconKey: 'guests',
    sortOrder: 130,
  ),
  SeedAccount(
    code: 'expense.clothing',
    name: 'Clothing',
    nameUr: 'کپڑے',
    type: AccountType.expense,
    iconKey: 'clothing',
    sortOrder: 140,
  ),
  SeedAccount(
    code: 'expense.charity',
    name: 'Charity & Sadqa',
    nameUr: 'صدقہ خیرات',
    type: AccountType.expense,
    iconKey: 'charity',
    sortOrder: 150,
  ),
  SeedAccount(
    code: 'expense.other',
    name: 'Other',
    nameUr: 'متفرق',
    type: AccountType.expense,
    iconKey: 'other',
    sortOrder: 999,
  ),

  // ---- Owed ----
  SeedAccount(
    code: 'liability.borrowed',
    name: 'Borrowed Money',
    nameUr: 'قرض لیا ہوا',
    type: AccountType.liability,
    iconKey: 'debt',
    sortOrder: 10,
  ),
  SeedAccount(
    code: 'liability.committee',
    name: 'Committee / BC',
    nameUr: 'کمیٹی',
    type: AccountType.liability,
    iconKey: 'committee',
    sortOrder: 20,
  ),

  // ---- Bookkeeping ----
  SeedAccount(
    code: 'equity.opening',
    name: 'Opening Balance',
    nameUr: 'ابتدائی رقم',
    type: AccountType.equity,
    iconKey: 'start',
    sortOrder: 10,
  ),
  SeedAccount(
    code: 'equity.adjustment',
    name: 'Adjustment',
    nameUr: 'ترمیم',
    type: AccountType.equity,
    iconKey: 'adjust',
    sortOrder: 20,
  ),
];

/// Codes the app itself relies on, so screens do not hardcode raw strings.
class AccountCodes {
  AccountCodes._();

  static const String cash = 'asset.cash';
  static const String bank = 'asset.bank';
  static const String openingBalance = 'equity.opening';
  static const String adjustment = 'equity.adjustment';
  static const String otherExpense = 'expense.other';
  static const String staff = 'expense.staff';

  static String idOf(String code) => 'sys.$code';
}
