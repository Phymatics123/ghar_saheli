import '../data/database.dart';

/// The three ways this app can speak.
///
/// **Roman Urdu is the default**, and comes first in every picker. It is what
/// most people in Pakistan already read and type on a phone every day, so it
/// is the option that needs no decision from a new user. Urdu script is right
/// there for anyone who prefers it.
///
/// English is a fallback for a user who asks for it, not the language the app
/// is designed around — on a money screen aimed at this household, English is
/// friction rather than clarity.
///
/// Order matters here: `AppLanguage.values` drives the order of the language
/// pickers. It is safe to reorder because the choice is persisted by `name`,
/// never by position, so an existing user's saved preference survives.
enum AppLanguage {
  /// Roman Urdu — Urdu words in Latin letters, the way most people text.
  roman,

  /// اردو — proper Urdu script, right to left.
  urdu,

  english,
}

extension AppLanguageInfo on AppLanguage {
  bool get isRtl => this == AppLanguage.urdu;

  /// Each language names itself in its own script, so the picker is readable
  /// to someone who cannot read the other two.
  String get ownName => switch (this) {
        AppLanguage.urdu => 'اردو',
        AppLanguage.roman => 'Roman Urdu',
        AppLanguage.english => 'English',
      };

  String get storageKey => name;

  static AppLanguage fromStorage(String? value) {
    return AppLanguage.values.firstWhere(
      (AppLanguage l) => l.name == value,
      // Roman Urdu for anyone who has never chosen — see the enum above.
      orElse: () => AppLanguage.roman,
    );
  }
}

/// Every user-facing string in the app.
///
/// Kept as one class of getters rather than generated `.arb` files: there are
/// under a hundred strings, all three languages need to stay visible side by
/// side while the wording is still being tuned with real users, and skipping
/// `flutter_localizations` keeps both the APK and the build simpler.
///
/// Arguments to [_pick] stay in the order (urdu, roman, english) regardless of
/// the enum's order, so the strings below do not all have to be rewritten to
/// change which language is the default.
class S {
  const S(this.lang);

  final AppLanguage lang;

  String _pick(String ur, String roman, String en) => switch (lang) {
        AppLanguage.urdu => ur,
        AppLanguage.roman => roman,
        AppLanguage.english => en,
      };

  // ---- App ----
  String get appName => _pick('گھر حساب', 'Ghar Hisaab', 'Ghar Hisaab');

  // ---- Home ----
  String get moneyInHand => _pick('ہاتھ میں', 'Haath mein', 'In hand');
  String get spentThisMonth =>
      _pick('اس مہینے کا خرچ', 'Is maheene ka kharch', 'Spent this month');
  String get earnedThisMonth =>
      _pick('اس مہینے کی آمدنی', 'Is maheene ki aamdani', 'Earned this month');
  String get quickAdd => _pick('جلدی لکھیں', 'Jaldi likhein', 'Quick add');
  String get nothingYet => _pick(
        'ابھی کوئی خرچ نہیں لکھا',
        'Abhi koi kharch nahi likha',
        'Nothing recorded yet',
      );
  String get startByAdding => _pick(
        'نیچے + دبا کر پہلا خرچ لکھیں',
        'Neeche + daba kar pehla kharch likhein',
        'Tap + below to add your first expense',
      );

  // ---- Entry ----
  String get expense => _pick('خرچ', 'Kharch', 'Expense');
  String get income => _pick('آمدنی', 'Aamdani', 'Income');
  String get addExpense => _pick('خرچ لکھیں', 'Kharch likhein', 'Add expense');
  String get addIncome =>
      _pick('آمدنی لکھیں', 'Aamdani likhein', 'Add income');
  String get chooseCategory =>
      _pick('کس چیز پر؟', 'Kis cheez par?', 'On what?');
  String get chooseIncomeSource =>
      _pick('کہاں سے آئے؟', 'Kahan se aaye?', 'From where?');
  String get howMuch => _pick('کتنے پیسے؟', 'Kitne paise?', 'How much?');
  String get paidFrom => _pick('کہاں سے', 'Kahan se', 'Paid from');
  String get receivedIn => _pick('کہاں رکھے', 'Kahan rakhe', 'Received in');
  String get save => _pick('محفوظ کریں', 'Mehfooz karein', 'Save');
  String get saved => _pick('لکھ لیا', 'Likh liya', 'Saved');
  String get removed => _pick('مٹا دیا', 'Mita diya', 'Removed');
  String get remove => _pick('مٹائیں', 'Mitayein', 'Remove');
  String get note => _pick('تفصیل', 'Tafseel', 'Note');
  String get optional => _pick('اختیاری', 'Ikhtiyari', 'optional');

  // ---- Dates ----
  String get today => _pick('آج', 'Aaj', 'Today');
  String get yesterday => _pick('کل', 'Kal', 'Yesterday');
  String get dayBefore => _pick('پرسوں', 'Parson', '2 days ago');

  String monthName(int month) {
    const List<String> ur = <String>[
      'جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون',
      'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر',
    ];
    const List<String> latin = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final int index = (month - 1).clamp(0, 11);
    return lang == AppLanguage.urdu ? ur[index] : latin[index];
  }

  /// "آج", "کل", or "6 اگست".
  String dayLabel(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime todayDate = DateTime(now.year, now.month, now.day);
    final int daysAgo = todayDate.difference(date).inDays;
    if (daysAgo == 0) return today;
    if (daysAgo == 1) return yesterday;
    if (daysAgo == 2) return dayBefore;
    return '${date.day} ${monthName(date.month)}';
  }

  // ---- Onboarding ----
  String get welcome => _pick('خوش آمدید', 'Khush aamdeed', 'Welcome');
  String get welcomeLine => _pick(
        'گھر کا حساب، آسان طریقے سے',
        'Ghar ka hisaab, aasaan tareeqe se',
        'Your household accounts, made simple',
      );
  String get howMuchNow => _pick(
        'ابھی آپ کے پاس کتنے پیسے ہیں؟',
        'Abhi aap ke paas kitne paise hain?',
        'How much money do you have right now?',
      );
  String get howMuchNowHelp => _pick(
        'نقد اور بینک ملا کر۔ بعد میں بھی بدل سکتی ہیں۔',
        'Naqad aur bank mila kar. Baad mein bhi badal sakti hain.',
        'Cash and bank together. You can change this later.',
      );
  String get start => _pick('شروع کریں', 'Shuru karein', 'Start');
  String get notNow => _pick('ابھی نہیں', 'Abhi nahi', 'Not now');
  String get chooseLanguage =>
      _pick('زبان چنیں', 'Zabaan chunein', 'Choose language');

  // ---- Lock ----
  String get enterPin =>
      _pick('پن نمبر لکھیں', 'PIN number likhein', 'Enter PIN');
  String get setPin =>
      _pick('نیا پن بنائیں', 'Naya PIN banayein', 'Create a PIN');
  String get confirmPin =>
      _pick('پن دوبارہ لکھیں', 'PIN dobara likhein', 'Enter PIN again');
  String get wrongPin => _pick('پن غلط ہے', 'PIN ghalat hai', 'Wrong PIN');
  String get pinsDoNotMatch => _pick(
        'دونوں پن ایک جیسے نہیں',
        'Dono PIN ek jaise nahi',
        'The two PINs do not match',
      );
  String get pinRemoved => _pick('تالا ہٹا دیا', 'Taala hata diya', 'Lock removed');
  String get pinSaved => _pick('تالا لگ گیا', 'Taala lag gaya', 'Lock set');

  // ---- Settings ----
  String get settings => _pick('ترتیبات', 'Tarteebat', 'Settings');
  String get language => _pick('زبان', 'Zabaan', 'Language');
  String get lock => _pick('تالا', 'Taala', 'Lock');
  String get lockOn => _pick(
        'ایپ کھولنے پر پن مانگے',
        'App kholne par PIN mange',
        'Ask for a PIN to open the app',
      );
  String get changePin => _pick('پن بدلیں', 'PIN badlein', 'Change PIN');
  String get removeLock => _pick('تالا ہٹائیں', 'Taala hatayein', 'Remove lock');
  /// Precise rather than sweeping.
  ///
  /// This used to promise that nothing was ever sent anywhere. With the
  /// activation check and the update check, that is no longer strictly true —
  /// and a privacy claim that is *nearly* true is worse than one that is
  /// exact, because the part it glosses over is the part a careful user would
  /// want to know. What matters is unchanged and is what this now says: the
  /// ledger never leaves the phone.
  String get privacyLine => _pick(
        'آپ کا سارا حساب صرف اسی فون میں رہتا ہے، کبھی کہیں نہیں بھیجا جاتا۔ '
            'انٹرنیٹ صرف دو کاموں کے لیے — شروع میں کوڈ چیک کرنے، اور نیا ورژن دیکھنے۔',
        'Aap ka saara hisaab sirf isi phone mein rehta hai, kabhi kahin nahi '
            'bheja jata. Internet sirf do kaamon ke liye — shuru mein code '
            'check karne, aur naya version dekhne.',
        'Your ledger stays on this phone and is never sent anywhere. The '
            'internet is used for two things only: checking your code once at '
            'the start, and looking for a new version.',
      );
  String get engineCheck =>
      _pick('انجن جانچ', 'Engine check', 'Engine check');

  // ---- Forecast ----
  String daysUntilEmpty(int days) => _pick(
        'اس رفتار سے پیسے $days دن میں ختم ہو جائیں گے',
        'Is raftaar se paise $days din mein khatam ho jayenge',
        'At this rate, money runs out in $days days',
      );
  String get lastsThroughMonth => _pick(
        'مہینے کے آخر تک چل جائیں گے',
        'Maheene ke aakhir tak chal jayenge',
        'This should last through the month',
      );
  String get justAboutLasts => _pick(
        'بس مہینے کے آخر تک پہنچیں گے',
        'Bas maheene ke aakhir tak pahunchenge',
        'Only just enough to reach month end',
      );
  String get nothingLeft => _pick(
        'ہاتھ میں پیسے نہیں',
        'Haath mein paise nahi',
        'No money left in hand',
      );
  String dailyAverage(String amount) => _pick(
        'روزانہ اوسط $amount',
        'Rozana ausat $amount',
        '$amount a day on average',
      );

  // ---- Recurring ----
  String get monthlyBills => _pick(
        'ہر مہینے کے خرچ',
        'Har maheene ke kharch',
        'Monthly bills',
      );
  String get monthlyBillsHelp => _pick(
        'کرایہ، بجلی، ملازمین کی تنخواہ — ایک بار لکھیں، ہر مہینے یاد دلائیں گے',
        'Kiraya, bijli, mulazimeen ki tankhwah — ek baar likhein, har maheene yaad dilayenge',
        'Rent, bills, staff salary — set once, reminded every month',
      );
  String get addMonthly => _pick('نیا شامل کریں', 'Naya shamil karein', 'Add one');
  String get noMonthlyYet => _pick(
        'ابھی کوئی مہینے والا خرچ نہیں',
        'Abhi koi maheene wala kharch nahi',
        'Nothing set up yet',
      );
  String get dueNow => _pick('واجب ہے', 'Wajib hai', 'Due');
  String get dueToday => _pick('آج واجب', 'Aaj wajib', 'Due today');
  String overdueBy(int days) => _pick(
        '$days دن پہلے واجب تھا',
        '$days din pehle wajib tha',
        '$days days overdue',
      );
  String get confirm => _pick('تصدیق کریں', 'Tasdeeq karein', 'Confirm');
  String get whichDay => _pick(
        'مہینے کی کون سی تاریخ؟',
        'Maheene ki kaunsi tareekh?',
        'Which day of the month?',
      );
  String dayOfMonth(int day) => _pick('$day تاریخ', '$day tareekh', 'Day $day');
  String get amountEveryMonth => _pick(
        'ہر مہینے کتنا؟',
        'Har maheene kitna?',
        'How much each month?',
      );
  String get amountVaries => _pick(
        'ہر بار مختلف ہوتا ہے',
        'Har baar mukhtalif hota hai',
        'It changes every time',
      );
  String get amountVariesHelp => _pick(
        'بجلی کے بل کی طرح — ہر بار پوچھیں گے',
        'Bijli ke bill ki tarah — har baar poochenge',
        'Like an electricity bill — we will ask each time',
      );
  String get nameIt => _pick('نام', 'Naam', 'Name');
  String get deleteMonthly => _pick('ہٹا دیں', 'Hata dein', 'Delete');

  // ---- Price memory ----
  String get lastTime => _pick('پچھلی بار', 'Pichli baar', 'Last time');

  // ---- Staff ----
  String get staff => _pick('ملازمین', 'Mulazimeen', 'Household staff');
  String get staffHelp => _pick(
        'تنخواہ، حاضری اور پیشگی کا حساب',
        'Tankhwah, hazri aur peshgi ka hisaab',
        'Salary, attendance and advances',
      );
  String get noStaffYet => _pick(
        'ابھی کوئی ملازم شامل نہیں',
        'Abhi koi mulazim shamil nahi',
        'Nobody added yet',
      );
  String get addStaff => _pick('نیا ملازم', 'Naya mulazim', 'Add someone');
  String get staffName => _pick('نام', 'Naam', 'Name');
  String get monthlySalary =>
      _pick('مہانہ تنخواہ', 'Mahana tankhwah', 'Monthly salary');
  String get phoneOptional => _pick(
        'فون نمبر (اختیاری)',
        'Phone number (ikhtiyari)',
        'Phone number (optional)',
      );

  // Attendance
  String get attendance => _pick('حاضری', 'Hazri', 'Attendance');
  String get present => _pick('حاضر', 'Haazir', 'Present');
  String get absent => _pick('غیر حاضر', 'Gair haazir', 'Absent');
  String get halfDay => _pick('آدھا دن', 'Aadha din', 'Half day');
  String get paidLeave => _pick('چھٹی', 'Chutti', 'Paid leave');
  String get notMarked => _pick('نشان نہیں', 'Nishaan nahi', 'Not marked');
  String get markedDays => _pick('لگائے گئے دن', 'Lagaye gaye din', 'Marked');
  String get allPresent => _pick(
        'سب دن حاضر',
        'Sab din haazir',
        'Mark all present',
      );
  String get allPresentDone => _pick(
        'آج تک سب حاضر لگا دیا',
        'Aaj tak sab haazir laga diya',
        'Marked present up to today',
      );
  String get attendanceHint => _pick(
        'دبائیں = حاضر۔ دیر تک دبائیں = اور آپشن۔',
        'Dabayein = haazir. Der tak dabayein = aur option.',
        'Tap for present. Hold for other options.',
      );
  String get clearDay => _pick('نشان ہٹائیں', 'Nishaan hatayein', 'Clear');

  // ---- Balance card ----
  String get whereItIs => _pick('کہاں ہیں', 'Kahan hain', 'Where it is');
  String spentFrom(String account) =>
      _pick('$account سے', '$account se', 'from $account');

  // Peshgi
  String get peshgi => _pick('پیشگی', 'Peshgi', 'Advance');
  String get givePeshgi =>
      _pick('پیشگی دیں', 'Peshgi dein', 'Give an advance');
  String get outstandingPeshgi => _pick(
        'باقی پیشگی',
        'Baqaya peshgi',
        'Advance outstanding',
      );
  String get peshgiHelp => _pick(
        'تنخواہ دیتے وقت خود کٹ جائے گی',
        'Tankhwah dete waqt khud kat jayegi',
        'It will be deducted automatically at salary time',
      );

  // Salary payment
  String get paySalary =>
      _pick('تنخواہ دیں', 'Tankhwah dein', 'Pay salary');
  String get salaryFor => _pick('تنخواہ', 'Tankhwah', 'Salary');
  String get earnedThisMonthLabel =>
      _pick('بنی تنخواہ', 'Bani tankhwah', 'Earned');
  String get deduction => _pick('کٹوتی', 'Katauti', 'Deduction');
  String get netPayable => _pick('ادا کرنی ہے', 'Ada karni hai', 'To pay');
  String get stillOwed => _pick(
        'اب بھی باقی پیشگی',
        'Ab bhi baqaya peshgi',
        'Advance still owed',
      );
  String get sendReceipt =>
      _pick('رسید بھیجیں', 'Raseed bhejein', 'Send receipt');
  String get receiptSent => _pick('رسید تیار', 'Raseed tayyar', 'Receipt ready');
  String get salaryPaid =>
      _pick('تنخواہ ادا ہو گئی', 'Tankhwah ada ho gayi', 'Salary paid');
  String get removeStaff =>
      _pick('کام چھوڑ دیا', 'Kaam chhor diya', 'No longer works here');

  // ---- Bill calculator ----
  String get billCalculator =>
      _pick('بجلی کا بل', 'Bijli ka bill', 'Electricity bill');
  String get billCalculatorHelp => _pick(
        'یونٹ لکھیں، اندازہ لگائیں',
        'Unit likhein, andaza lagayein',
        'Enter units, get an estimate',
      );
  String get company => _pick('کمپنی', 'Company', 'Company');
  String get unitsUsed =>
      _pick('استعمال شدہ یونٹ', 'Istemaal shuda unit', 'Units used');
  String get protectedCustomer =>
      _pick('پروٹیکٹڈ صارف', 'Protected sarif', 'Protected customer');
  String get protectedHelp => _pick(
        'اگر چھ مہینے سے 200 یونٹ سے کم استعمال ہو',
        'Agar chhe maheene se 200 unit se kam istemaal ho',
        'If under 200 units for the last six months',
      );
  String get energyCharge =>
      _pick('بجلی کا چارج', 'Bijli ka charge', 'Energy charge');
  String get fuelAdjustment => _pick('ایف پی اے', 'FPA', 'Fuel adjustment');
  String get quarterlyAdjustment => _pick('کیو ٹی آر', 'QTR', 'Quarterly adj.');
  String get meterRent => _pick('میٹر کرایہ', 'Meter kiraya', 'Meter rent');
  String get salesTax => _pick('جی ایس ٹی', 'GST', 'GST');
  String get estimatedTotal =>
      _pick('اندازاً کل', 'Andazan kul', 'Estimated total');
  String get estimateWarning => _pick(
        'یہ صرف اندازہ ہے۔ اصل بل سے ملا کر دیکھیں — سرکاری ریٹ بدلتے رہتے ہیں۔',
        'Yeh sirf andaza hai. Asal bill se mila kar dekhein — sarkari rate badalte rehte hain.',
        'An estimate only. Check against your real bill — official rates change.',
      );
  String get extrasFromBill => _pick(
        'یہ اپنے پچھلے بل سے دیکھ کر لکھیں',
        'Yeh apne pichhle bill se dekh kar likhein',
        'Copy these from your last bill',
      );
  String get recordAsExpense =>
      _pick('خرچ میں لکھیں', 'Kharch mein likhein', 'Record as expense');

  // ---- Privacy ----
  String get privacy => _pick('پردہ داری', 'Parda daari', 'Privacy');
  String get hideAmounts =>
      _pick('رقمیں چھپائیں', 'Raqmein chhupayein', 'Hide amounts');
  String get hideAmountsHelp => _pick(
        'سکرین پر پیسے نقطوں میں دکھیں گے',
        'Screen par paise nuqton mein dikhenge',
        'Amounts show as dots on screen',
      );

  // ---- Backup ----
  String get backup => _pick('بیک اپ', 'Backup', 'Backup');
  String get backupHelp => _pick(
        'سارا حساب ایک محفوظ فائل میں',
        'Saara hisaab ek mehfooz file mein',
        'Your whole ledger in one protected file',
      );
  String get makeBackup =>
      _pick('بیک اپ بنائیں', 'Backup banayein', 'Create a backup');
  String get restoreBackup =>
      _pick('بیک اپ واپس لائیں', 'Backup wapas layein', 'Restore a backup');
  String get backupPassword => _pick('پاس ورڈ', 'Password', 'Password');
  String get backupPasswordHelp => _pick(
        'یہی پاس ورڈ واپس لاتے وقت بھی چاہیے ہوگا۔ بھول گئیں تو فائل کھل نہیں سکے گی۔',
        'Yehi password wapas late waqt bhi chahiye hoga. Bhool gayin to file khul nahi sakegi.',
        'You will need this same password to restore. If it is lost, the file cannot be opened.',
      );
  String get backupReady =>
      _pick('بیک اپ تیار', 'Backup tayyar', 'Backup ready');
  String get chooseFile =>
      _pick('فائل چنیں', 'File chunein', 'Choose a file');
  String restoredCount(int added, int already) => _pick(
        '$added نئی چیزیں شامل ہوئیں، $already پہلے سے موجود تھیں',
        '$added nayi cheezein shamil hueen, $already pehle se mojood theen',
        '$added new entries added, $already were already here',
      );
  String get backupSaveHelp => _pick(
        'فائل فون میں محفوظ ہو جائے گی۔ اسے کھولنے کے لیے یہی پاس ورڈ چاہیے ہوگا۔',
        'File phone mein mehfooz ho jayegi. Ise kholne ke liye yehi password chahiye hoga.',
        'The file is saved on your phone. Only this password can open it.',
      );

  // ---- Accounts ----
  String get myMoney => _pick('میرے پیسے', 'Mere paise', 'My money');
  String get myMoneyHelp => _pick(
        'کہاں کتنے پیسے ہیں۔ ہر خرچ کے ساتھ خود بدلتا رہتا ہے۔',
        'Kahan kitne paise hain. Har kharch ke saath khud badalta rehta hai.',
        'Where your money sits. Updates itself with every entry.',
      );
  String get total => _pick('کل', 'Kul', 'Total');
  String get tapToCorrect => _pick(
        'درست کرنے کے لیے دبائیں',
        'Durust karne ke liye dabayein',
        'Tap to correct',
      );
  String get howMuchInAccount => _pick(
        'ابھی اصل میں کتنے ہیں؟',
        'Abhi asal mein kitne hain?',
        'How much is actually there right now?',
      );
  String get correctionNote => _pick(
        'پرانا حساب مٹے گا نہیں — فرق آج کی تاریخ میں لکھ دیا جائے گا۔',
        'Purana hisaab mitega nahi — farq aaj ki tareekh mein likh diya jayega.',
        'Nothing is erased. The difference is recorded as a correction today.',
      );

  // ---- Statement ----
  String get statement => _pick('حساب کی رپورٹ', 'Hisaab ki report', 'Statement');
  String get saveStatement => _pick(
        'رپورٹ محفوظ کریں',
        'Report mehfooz karein',
        'Save statement',
      );
  String get statementHelp => _pick(
        'پچھلے ایک مہینے کے سارے خرچ ایک فائل میں — پڑھنے کے لیے',
        'Pichhle ek maheene ke saare kharch ek file mein — parhne ke liye',
        'The last month of entries in one readable file',
      );
  String get statementSaved =>
      _pick('رپورٹ محفوظ ہو گئی', 'Report mehfooz ho gayi', 'Statement saved');

  // ---- Updates ----
  String get appUpdate => _pick('ایپ اپ ڈیٹ', 'App update', 'App update');
  String get checkForUpdates => _pick(
        'نیا ورژن دیکھیں',
        'Naya version dekhein',
        'Check for updates',
      );
  String get checking => _pick('دیکھ رہے ہیں…', 'Dekh rahe hain…', 'Checking…');
  String get upToDate => _pick(
        'ایپ پہلے سے نئی ہے',
        'App pehle se nayi hai',
        'You have the latest version',
      );
  String get updateAvailable =>
      _pick('نیا ورژن آ گیا', 'Naya version aa gaya', 'A new version is ready');
  String currentVersion(String version) =>
      _pick('ابھی: $version', 'Abhi: $version', 'Current: $version');
  String newVersion(String version) =>
      _pick('نیا: $version', 'Naya: $version', 'New: $version');
  String get downloadUpdate =>
      _pick('ڈاؤن لوڈ کریں', 'Download karein', 'Download');
  String get downloading =>
      _pick('ڈاؤن لوڈ ہو رہا ہے…', 'Download ho raha hai…', 'Downloading…');
  String get installNow => _pick('انسٹال کریں', 'Install karein', 'Install now');
  String get updateOnWifi => _pick(
        'وائی فائی پر کریں تو ڈیٹا بچے گا',
        'WiFi par karein to data bachega',
        'Use WiFi to save mobile data',
      );

  // Install permission
  String get allowInstalls => _pick(
        'انسٹال کی اجازت دیں',
        'Install ki ijazat dein',
        'Allow installing',
      );
  String get allowInstallsWhy => _pick(
        'اپ ڈیٹ لگانے کے لیے فون کو ایک بار اجازت دینی ہوگی۔ یہ صرف ایک بار ہوتا ہے۔',
        'Update lagane ke liye phone ko ek baar ijazat deni hogi. Yeh sirf ek baar hota hai.',
        'Android needs your permission once before the app can install updates.',
      );
  String get openSettings =>
      _pick('سیٹنگز کھولیں', 'Settings kholein', 'Open settings');
  String get installWarningNote => _pick(
        'فون شاید ایک وارننگ دکھائے — یہ عام بات ہے کیونکہ ایپ پلے سٹور سے نہیں آئی۔',
        'Phone shayad ek warning dikhaye — yeh aam baat hai kyunki app Play Store se nahi aayi.',
        'Your phone may show a warning. That is normal for an app installed outside the Play Store.',
      );

  // ---- Activation ----
  String get activateTitle =>
      _pick('ایپ چالو کریں', 'App chaalu karein', 'Activate the app');
  String get activateHelp => _pick(
        'جو کوڈ آپ کو بھیجا گیا تھا وہ یہاں لکھیں۔ یہ صرف ایک بار پوچھا جائے گا۔',
        'Jo code aap ko bheja gaya tha woh yahan likhein. Yeh sirf ek baar poocha jayega.',
        'Enter the code you were sent. You will only be asked once.',
      );
  String get activateCodeLabel => _pick('کوڈ', 'Code', 'Code');
  String get activateButton => _pick('چالو کریں', 'Chaalu karein', 'Activate');
  String get activateChecking =>
      _pick('دیکھ رہے ہیں…', 'Dekh rahe hain…', 'Checking…');
  String get activateRejected => _pick(
        'یہ کوڈ درست نہیں، یا پہلے ہی استعمال ہو چکا ہے۔',
        'Yeh code durust nahi, ya pehle hi istemaal ho chuka hai.',
        'That code is not valid, or it has already been used up.',
      );
  String get activateOffline => _pick(
        'انٹرنیٹ نہیں مل رہا۔ ایک بار کوڈ چیک کرنے کے لیے انٹرنیٹ چاہیے — اس کے بعد کبھی نہیں۔',
        'Internet nahi mil raha. Ek baar code check karne ke liye internet chahiye — is ke baad kabhi nahi.',
        'No internet. The code needs checking online just once — never again after that.',
      );
  String get activateServerError => _pick(
        'ابھی سرور سے بات نہیں ہو پا رہی۔ تھوڑی دیر بعد کوشش کریں۔',
        'Abhi server se baat nahi ho pa rahi. Thori der baad koshish karein.',
        'Could not reach the server just now. Please try again shortly.',
      );
  String get activateOnceOnly => _pick(
        'کوڈ سنبھال کر رکھیں۔ فون بدلنے یا ایپ دوبارہ لگانے پر یہی کوڈ کام آئے گا۔',
        'Code sambhaal kar rakhein. Phone badalne ya app dobara lagane par yehi code kaam aayega.',
        'Keep your code. You will need it again if you reinstall or change phones.',
      );

  // ---- Errors ----
  String get enterAmount => _pick(
        'پہلے رقم لکھیں',
        'Pehle raqam likhein',
        'Enter an amount first',
      );

  // ---- Accounts ----
  /// The display name of a seeded or user-made account.
  ///
  /// Roman spellings live here rather than in the database so that adding a
  /// language never means migrating a user's ledger. User-made categories fall
  /// back to whatever the user typed, which is already in their own words.
  String accountName(AccountRow account) {
    switch (lang) {
      case AppLanguage.urdu:
        return account.nameUr;
      case AppLanguage.english:
        return account.name;
      case AppLanguage.roman:
        return _romanByCode[account.code] ?? account.name;
    }
  }

  static const Map<String, String> _romanByCode = <String, String>{
    'asset.cash': 'Naqad',
    'asset.bank': 'Bank',
    'asset.savings': 'Bachat',
    'income.salary': 'Tankhwah',
    'income.business': 'Karobar',
    'income.other': 'Doosri aamdani',
    'expense.groceries': 'Raashan',
    'expense.vegetables': 'Sabzi phal',
    'expense.milk': 'Doodh dahi',
    'expense.electricity': 'Bijli ka bill',
    'expense.gas': 'Gas ka bill',
    'expense.water': 'Paani ka bill',
    'expense.rent': 'Kiraya',
    'expense.education': 'Bachon ki fees',
    'expense.medical': 'Ilaaj',
    'expense.transport': 'Aamad o raft',
    'expense.mobile': 'Mobile internet',
    'expense.staff': 'Mulazimeen',
    'expense.guests': 'Mehmaan nawazi',
    'expense.clothing': 'Kapre',
    'expense.charity': 'Sadqa khairaat',
    'expense.other': 'Mutafarriq',
    'liability.borrowed': 'Qarz liya hua',
    'liability.committee': 'Committee',
    'equity.opening': 'Ibtidai raqam',
    'equity.adjustment': 'Tarmeem',
  };
}
