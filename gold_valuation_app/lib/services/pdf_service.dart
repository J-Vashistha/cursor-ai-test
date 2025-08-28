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
                  _header(profile),
                  pw.SizedBox(height: 12),
                  pw.Text('Gold Loan Valuation Certificate', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  _infoRow('Bank', bank.name),
                  _infoRow('Branch', branch.name),
                  _infoRow('Date', df.format(valuation.date)),
                  _infoRow('Loan Amount', '₹ ${valuation.loanAmountRupees.toString()}'),
                  _infoRow('Customer', valuation.customerName),
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
                      pw.Expanded(child: _declaration()),
                      pw.SizedBox(width: 16),
                      _qrPlaceholder(),
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

    // Attempt to set PDF as non-editable by restricting permissions (best-effort)
    // Note: Some viewers may ignore restrictions.
    // doc.encrypt(userPassword: '', ownerPassword: 'owner', permissions: const pw.PdfPermissions(allowPrinting: true));

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

  static pw.Widget _header(ValuerProfile profile) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(profile.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(profile.address),
          pw.Text('Phone: ${profile.phone}${profile.email != null && profile.email!.isNotEmpty ? ' | Email: ${profile.email}' : ''}'),
        ]),
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
          alignment: pw.Alignment.center,
          child: pw.Text('LOGO'),
        ),
      ],
    );
  }

  static pw.Widget _footer(ValuerProfile profile) {
    return pw.Center(
      child: pw.Text('This certificate is generated digitally by ${profile.name}. All rights reserved.'),
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
    final headers = ['Description', 'Pcs', 'Gross (g)', 'Net (g)', 'Carat'];
    final data = v.ornaments.map((o) => [
          o.description,
          o.numberOfPieces.toString(),
          o.grossWeightGrams.toStringAsFixed(3),
          o.netWeightGrams.toStringAsFixed(3),
          o.caratPurity.toStringAsFixed(2),
        ]);
    return pw.TableHelper.fromTextArray(headers: headers, data: data.toList());
  }

  static pw.Widget _declaration() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Declaration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text('I hereby declare that the above ornaments were checked and valued to the best of my knowledge.'),
        pw.SizedBox(height: 24),
        pw.Text('Customer Signature: _________________________'),
      ],
    );
  }

  static pw.Widget _qrPlaceholder() {
    return pw.Container(
      width: 100,
      height: 100,
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
      alignment: pw.Alignment.center,
      child: pw.Text('QR'),
    );
  }

  static pw.Widget _signatures(ValuerProfile profile) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Valuer Signature: _________________________'),
        pw.Text(profile.name),
      ],
    );
  }
}

