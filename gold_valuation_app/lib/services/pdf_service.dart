import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/bank.dart';
import '../models/branch.dart';
import '../models/valuation.dart';
import '../models/valuer_profile.dart';

class PdfService {
  static Future<File> generateValuationPdf({
    required Valuation valuation,
    required Bank bank,
    required Branch branch,
    required ValuerProfile profile,
  }) async {
    final doc = pw.Document();

    final DateFormat df = DateFormat('dd-MM-yyyy');

    // Try to load logo if provided
    pw.ImageProvider? logoImage;
    if (profile.logoFilePath != null && profile.logoFilePath!.isNotEmpty) {
      final f = File(profile.logoFilePath!);
      if (await f.exists()) {
        final bytes = await f.readAsBytes();
        logoImage = pw.MemoryImage(bytes);
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.robotoRegular(),
            bold: await PdfGoogleFonts.robotoBold(),
          ),
        ),
        build: (context) {
          return [
            pw.Stack(children: [
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.5,
                    child: pw.Opacity(
                      opacity: 0.06,
                      child: pw.Text(
                        'Nakoda Jewellers',
                        style: pw.TextStyle(fontSize: 80, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _header(profile, logoImage),
                  pw.SizedBox(height: 12),
                  pw.Center(
                    child: pw.Text('GOLD LOAN VALUATION CERTIFICATE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Divider(),
                  _infoRow('Bank Name & Branch', '${bank.name} • ${branch.name}'),
                  _infoRow('Date', df.format(valuation.date)),
                  _infoRow('Loan Amount', '₹ ${valuation.loanAmountRupees.toString()}'),
                  pw.SizedBox(height: 8),
                  _infoRow('Customer Name', valuation.customerName),
                  _infoRow('Address', valuation.customerAddress),
                  pw.SizedBox(height: 8),
                  _ornamentsTable(valuation),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Gross Weight: ${valuation.totalGrossWeightGrams.toStringAsFixed(3)} g'),
                      pw.Text('Total Net Weight: ${valuation.totalNetWeightGrams.toStringAsFixed(3)} g'),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: _declarationSection()),
                    ],
                  ),
                  pw.SizedBox(height: 24),
                  _signatures(profile),
                  pw.Divider(),
                  _footer(profile),
                ],
              ),
            ]),
          ];
        },
      ),
    );

    // Note: Library-level encryption is not supported in this version.

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/valuation_${valuation.id}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static Future<void> sharePdf(File file) async {
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.uri.pathSegments.last);
  }

  static Future<void> printPdf(File file) async {
    await Printing.layoutPdf(onLayout: (_) async => await file.readAsBytes());
  }

  static pw.Widget _header(ValuerProfile profile, pw.ImageProvider? logoImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
          alignment: pw.Alignment.center,
          child: logoImage != null ? pw.Image(logoImage) : pw.Text('LOGO'),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('NAKODA JEWELLERS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Near Community Hall, Sector 14, Hiran Magri,'),
              pw.Text('Udaipur (Raj.) – 313002'),
              if (profile.phone.isNotEmpty)
                pw.Text('Phone: ${profile.phone}${profile.email != null && profile.email!.isNotEmpty ? ' | Email: ${profile.email}' : ''}'),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _footer(ValuerProfile profile) {
    final String valuerName = (profile.name.isNotEmpty) ? profile.name : 'Rajesh Lodha';
    return pw.Column(
      children: [
        pw.Text('Valuer Name: $valuerName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('Prop. – Nakoda Jewellers'),
      ],
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 140, child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static pw.Widget _ornamentsTable(Valuation v) {
    final headers = ['S. No', 'Description (Ornament)', 'No. of Pcs', 'Gross Wt. (g)', 'Net Wt. (g)', 'Carat (K)'];
    final rows = <List<String>>[];
    for (int i = 0; i < v.ornaments.length; i++) {
      final o = v.ornaments[i];
      rows.add([
        (i + 1).toString(),
        o.description,
        o.numberOfPieces.toString(),
        o.grossWeightGrams.toStringAsFixed(3),
        o.netWeightGrams.toStringAsFixed(3),
        o.caratPurity.toStringAsFixed(2),
      ]);
    }
    rows.add(['', 'Totals', '', v.totalGrossWeightGrams.toStringAsFixed(3), v.totalNetWeightGrams.toStringAsFixed(3), '']);
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headers: headers,
      data: rows,
      cellAlignments: {
        0: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _declarationSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Declaration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text('“This is to certify that the above ornaments were valued at my shop without any interest direct or indirect, and valued to the best of my knowledge.”'),
        pw.SizedBox(height: 8),
        pw.Text('Customer Declaration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('“I hereby declare that I am the rightful owner of the above ornaments submitted for gold loan valuation.”'),
        pw.SizedBox(height: 24),
        pw.Text('Customer Signature: _________________________________'),
      ],
    );
  }

  // QR code intentionally skipped as per requirement.

  static pw.Widget _signatures(ValuerProfile profile) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Valuer Signature: _________________________________'),
        pw.Text('(Digital Signature Placeholder)'),
      ],
    );
  }
}

