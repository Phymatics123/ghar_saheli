import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/money.dart';
import '../domain/account_type.dart';
import '../domain/models.dart';

/// A readable statement of the last month's spending.
///
/// The encrypted backup is for restoring; it is a wall of bytes and no human
/// will ever open it. This is the other half of the job — something you can
/// look at, hand to your husband, or keep for the month.
///
/// Written in Roman Urdu and Latin numerals for the same reason as the salary
/// receipt: a PDF has to carry its own font, and Urdu script needs an embedded
/// Nastaliq face plus right-to-left shaping — around a megabyte for a document
/// that gets read once.
class StatementService {
  StatementService._();

  /// Builds a statement covering [from] to [to] inclusive.
  static Future<Uint8List> build({
    required List<EntryWithPostings> entries,
    required DateTime from,
    required DateTime to,
  }) async {
    final pw.Document doc = pw.Document();

    // Oldest first: a statement reads forward through the month, unlike the
    // home screen which shows the newest thing you did.
    final List<EntryWithPostings> ordered =
        List<EntryWithPostings>.of(entries)
          ..sort((EntryWithPostings a, EntryWithPostings b) =>
              a.occurredOn.compareTo(b.occurredOn));

    int spentMinor = 0;
    int earnedMinor = 0;
    final Map<String, int> byCategory = <String, int>{};

    for (final EntryWithPostings entry in ordered) {
      for (final PostingWithAccount line in entry.lines) {
        if (line.account.type == AccountType.expense &&
            line.amount.isPositive) {
          spentMinor += line.amount.paisa;
          byCategory[line.account.name] =
              (byCategory[line.account.name] ?? 0) + line.amount.paisa;
        } else if (line.account.type == AccountType.income &&
            line.amount.isNegative) {
          earnedMinor += -line.amount.paisa;
        }
      }
    }

    final List<MapEntry<String, int>> categories =
        byCategory.entries.toList()
          ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
              b.value.compareTo(a.value));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => _header(from, to),
        build: (pw.Context context) => <pw.Widget>[
          _summary(
            spent: Money(spentMinor),
            earned: Money(earnedMinor),
            count: ordered.length,
          ),
          pw.SizedBox(height: 18),

          if (categories.isNotEmpty) ...<pw.Widget>[
            _sectionTitle('Kis cheez par kitna / By category'),
            pw.SizedBox(height: 6),
            _categoryTable(categories, spentMinor),
            pw.SizedBox(height: 20),
          ],

          _sectionTitle('Poori tafseel / All entries'),
          pw.SizedBox(height: 6),
          if (ordered.isEmpty)
            pw.Text(
              'Is arse mein koi kharch nahi likha gaya.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            )
          else
            _entryTable(ordered),
        ],
        footer: (pw.Context context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Ghar Saheli  ·  ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
      ),
    );

    return doc.save();
  }

  static String suggestedFileName(DateTime to) {
    final String stamp = '${to.year}'
        '-${to.month.toString().padLeft(2, '0')}'
        '-${to.day.toString().padLeft(2, '0')}';
    return 'ghar-saheli-hisaab-$stamp.pdf';
  }

  // ---- Pieces ----

  static pw.Widget _header(DateTime from, DateTime to) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            'Ghar ka Hisaab',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Household statement  ·  ${_date(from)} — ${_date(to)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Divider(height: 10),
        ],
      ),
    );
  }

  static pw.Widget _summary({
    required Money spent,
    required Money earned,
    required int count,
  }) {
    pw.Widget box(String label, String value, PdfColor colour) {
      return pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          margin: const pw.EdgeInsets.only(right: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(label,
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700)),
              pw.SizedBox(height: 2),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: colour,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return pw.Row(
      children: <pw.Widget>[
        box('Kul kharch / Spent', spent.format(), PdfColors.red800),
        box('Kul aamdani / Earned', earned.format(), PdfColors.green800),
        box('Entries', '$count', PdfColors.blueGrey800),
      ],
    );
  }

  static pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    );
  }

  static pw.Widget _categoryTable(
    List<MapEntry<String, int>> categories,
    int totalMinor,
  ) {
    return pw.TableHelper.fromTextArray(
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignments: <int, pw.Alignment>{
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
      },
      headers: <String>['Category', 'Amount', 'Share'],
      data: <List<String>>[
        for (final MapEntry<String, int> category in categories)
          <String>[
            category.key,
            Money(category.value).format(),
            totalMinor == 0
                ? '—'
                : '${(category.value * 100 / totalMinor).round()}%',
          ],
      ],
    );
  }

  static pw.Widget _entryTable(List<EntryWithPostings> entries) {
    return pw.TableHelper.fromTextArray(
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      columnWidths: <int, pw.TableColumnWidth>{
        0: const pw.FlexColumnWidth(1.6),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2.4),
        3: const pw.FlexColumnWidth(1.8),
      },
      cellAlignments: <int, pw.Alignment>{
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
      headers: <String>['Date', 'Tafseel / Detail', 'Category', 'Amount'],
      data: <List<String>>[
        for (final EntryWithPostings entry in entries)
          <String>[
            _date(entry.occurredOn),
            entry.entry.description,
            entry.primaryLine?.account.name ?? '',
            // A leading minus for money leaving, so the column can be scanned
            // without reading the category to work out which way it went.
            _isIncome(entry)
                ? '+ ${entry.magnitude.format(symbol: false)}'
                : '- ${entry.magnitude.format(symbol: false)}',
          ],
      ],
    );
  }

  static bool _isIncome(EntryWithPostings entry) =>
      entry.primaryLine?.account.type == AccountType.income;

  static String _date(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}
