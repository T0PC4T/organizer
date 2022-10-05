import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Iterable<Map<String, String>> getDataFromTable(Map table) sync* {
  for (var seat = 1; seat < 7; seat++) {
    if (table.containsKey(seat.toString()) && table[seat.toString()] != null) {
      yield {
        "name": table[seat.toString()],
        "table": table["name"],
        "seat": seat.toString(),
      };
    }
  }
}

Future<Uint8List> generateSeetingPdf(String title, List<Map> tables) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final font = await PdfGoogleFonts.nunitoExtraLight();
  final people = tables.expand((element) => getDataFromTable(element)).toList()
    ..sort((a, b) => (a["name"] as String).compareTo((b["name"] as String)));
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          children: [
            // pw.SizedBox(
            //   width: double.infinity,
            //   child: pw.Center(
            //       child: pw.Text(title,
            //           style: pw.TextStyle(font: font, fontSize: 24))),
            // ),
            pw.SizedBox(
                width: double.infinity,
                child: pw.Table(
                  tableWidth: pw.TableWidth.min,
                  border: pw.TableBorder.all(),
                  children: [
                    for (var person in people)
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            person["name"]!,
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 7,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            person["table"]!.toUpperCase(),
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 7,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            person["seat"]!.toUpperCase(),
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 7,
                            ),
                          ),
                        )
                      ])
                  ],
                )),
          ],
        );
      },
    ),
  );

  return pdf.save();
}


//  pw.Table.fromTextArray(context: context, data: const <List<String>>[
//               <String>['Date', 'PDF Version', 'Acrobat Version'],
//               <String>['1993', 'PDF 1.0', 'Acrobat 1'],
//               <String>['1994', 'PDF 1.1', 'Acrobat 2'],
//               <String>['1996', 'PDF 1.2', 'Acrobat 3'],
//               <String>['1999', 'PDF 1.3', 'Acrobat 4'],
//               <String>['2001', 'PDF 1.4', 'Acrobat 5'],
//               <String>['2003', 'PDF 1.5', 'Acrobat 6'],
//               <String>['2005', 'PDF 1.6', 'Acrobat 7'],
//               <String>['2006', 'PDF 1.7', 'Acrobat 8'],
//               <String>['2008', 'PDF 1.7', 'Acrobat 9'],
//               <String>['2009', 'PDF 1.7', 'Acrobat 9.1'],
//               <String>['2010', 'PDF 1.7', 'Acrobat X'],
//               <String>['2012', 'PDF 1.7', 'Acrobat XI'],
//               <String>['2017', 'PDF 2.0', 'Acrobat DC'],
//             ]),