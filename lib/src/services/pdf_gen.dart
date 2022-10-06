import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Iterable<List<String>> getDataFromTable(Map table) sync* {
  for (var seat = 1; seat < 7; seat++) {
    if (table.containsKey(seat.toString()) && table[seat.toString()] != null) {
      for (var personName in table[seat.toString()].split(";")) {
        yield [
          personName,
          table["name"].toString().toUpperCase(),
          seat.toString(),
        ];
      }
    }
  }
}

Future<Uint8List> generateSeetingPdf(String title, List<Map> tables) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final font = await PdfGoogleFonts.nunitoExtraLight();
  final people = tables.expand((element) => getDataFromTable(element)).toList()
    ..sort((a, b) => (a[0]).compareTo(b[0]));

  // makes it into three columns
  final third = people.length ~/ 3;
  List<List<List<String>>> sections = [
    people.sublist(0, third),
    people.sublist(third, third * 2),
    people.sublist(third * 2),
  ];
  List<String> sectionsLetters = [
    "A-${people[third - 1][0][0]}",
    "${people[third][0][0]}-${people[(third * 2) - 2][0][0]}",
    "${people[third * 2][0][0]}-Z",
  ];

  for (var i = 0; i < sections.length; i++) {
    sections[i].insert(0, ["Name (${sectionsLetters[i]})", "Table", "Seat"]);
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          children: [
            pw.SizedBox(
              width: double.infinity,
              child: pw.Center(
                  child: pw.Text(title,
                      style: pw.TextStyle(font: font, fontSize: 24))),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (var personSection in sections)
                  pw.Table(
                      tableWidth: pw.TableWidth.min,
                      border: pw.TableBorder.all(),
                      children: [
                        for (var person in personSection)
                          pw.TableRow(children: [
                            TableEntry(person[0]),
                            pw.Center(child: TableEntry(person[1])),
                            pw.Center(child: TableEntry(person[2])),
                          ])
                      ]),
              ],
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

class TableEntry extends pw.StatelessWidget {
  final String data;
  TableEntry(this.data);

  @override
  pw.Widget build(context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(3, 5, 3, 5),
      child: pw.Text(
        data,
        style: const pw.TextStyle(
          // font: font,
          fontSize: 9,
        ),
      ),
    );
  }
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