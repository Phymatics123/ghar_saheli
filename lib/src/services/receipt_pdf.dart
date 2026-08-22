import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../domain/staff.dart';

/// Builds a salary receipt and hands it to whatever the user wants to send it
/// with.
///
/// **Written in Roman Urdu, not Urdu script**, and that is a limitation rather
/// than a preference. A PDF has to carry its own font, and rendering Urdu
/// properly needs an embedded Nastaliq face plus right-to-left shaping — around
/// a megabyte for a document most people will glance at once. Roman Urdu reads
/// naturally to the same audience, prints on any device, and is what a
/// handwritten khata receipt usually looks like anyway.
///
/// The sharing itself goes through Android's own share sheet. The app never
/// asks for contacts, never talks to WhatsApp's servers, and has no idea where
/// the file ends up — the user picks, exactly as they would with a photo.
class ReceiptService {
  ReceiptService._();

  /// A month's salary receipt, showing how the figure was reached.
  ///
  /// The working is on the page on purpose. The whole point of tracking peshgi
  /// is that both sides can see why the amount is what it is, so a receipt that
  /// only showed a total would be solving half the problem.
  static Future<File> buildSalaryReceipt({
    required StaffWithAccounts member,
    required SalaryCalculation calculation,
    required String monthLabel,
    required DateTime paidOn,
  }) async {
    final pw.Document doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                'Tankhwah Receipt',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Salary receipt  |  $monthLabel',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
              pw.Divider(height: 20),

              _row('Naam / Name', member.name),
              _row('Mahina / Month', monthLabel),
              _row('Tareekh / Date', _formatDate(paidOn)),

              pw.SizedBox(height: 14),
              pw.Text(
                'Hazri / Attendance',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              _row('Kaam ke din / Days worked',
                  '${calculation.presentDays + calculation.unmarkedDays}'),
              if (calculation.halfDays > 0)
                _row('Aadha din / Half days', '${calculation.halfDays}'),
              if (calculation.leaveDays > 0)
                _row('Chutti / Paid leave', '${calculation.leaveDays}'),
              if (calculation.absentDays > 0)
                _row('Gair haazir / Absent', '${calculation.absentDays}'),

              pw.SizedBox(height: 14),
              pw.Text(
                'Hisaab / Calculation',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              _row('Mahana tankhwah / Monthly salary',
                  calculation.monthlySalary.format()),
              if (calculation.deduction.isPositive)
                _row('Kaati gayi raqam / Deduction',
                    '- ${calculation.deduction.format()}'),
              _row('Bani tankhwah / Earned', calculation.earned.format()),
              if (calculation.advanceSettled.isPositive)
                _row('Peshgi kaati / Advance settled',
                    '- ${calculation.advanceSettled.format()}'),

              pw.Divider(height: 18),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    'Adaa ki gayi / Paid',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    (calculation.earned - calculation.advanceSettled).format(),
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              if (calculation.carriesForward) ...<pw.Widget>[
                pw.SizedBox(height: 6),
                pw.Text(
                  'Baqaya peshgi / Advance still owed: '
                  '${calculation.carriedForward.format()}',
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColors.red800),
                ),
              ],

              pw.Spacer(),
              pw.Divider(),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  _signatureLine('Dene wala / Paid by'),
                  _signatureLine('Lene wala / Received by'),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Written to the app's cache rather than anywhere shared. Android's share
    // sheet is handed the file directly, so it never needs to sit somewhere
    // other apps can browse.
    final Directory dir = await getTemporaryDirectory();
    final String safeName =
        member.name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
    final File file = File(
      p.join(dir.path, 'salary-$safeName-${monthLabel.replaceAll(' ', '-')}.pdf'),
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  /// Opens the share sheet with the receipt attached.
  ///
  /// The `text` is deliberately short and duplicated inside the PDF, because
  /// WhatsApp drops the accompanying message when a file is shared and keeps
  /// only the attachment. Anything that matters has to be on the page itself.
  static Future<void> share(File file, {String? message}) async {
    await Share.shareXFiles(
      <XFile>[XFile(file.path)],
      text: message,
    );
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _signatureLine(String label) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Container(width: 120, height: 0.8, color: PdfColors.grey600),
        pw.SizedBox(height: 3),
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
      ],
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}
