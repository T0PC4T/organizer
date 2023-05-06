import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:organizer/src/screens/seating.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Iterable<List<String>> getDataFromTable(TableData table) sync* {
  for (var seat in table.seats) {
    if (table.seminarianSeat(seat)) {
      for (var personName in table.seatPeople(seat)) {
        yield [
          personName,
          table.name,
          seat.toString(),
        ];
      }
    }
  }
}

Future generateSeetingPdf(String title, List<TableData> tables) async {
  var data = await rootBundle.load("assets/fonts/open-sans.ttf");
  final myFont = pw.Font.ttf(data);
  final myStlyeLarge = pw.TextStyle(font: myFont, fontSize: 24);
  final myStlyeSmall = pw.TextStyle(font: myFont, fontSize: 9);

  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  // final font = await PdfGoogleFonts.nunitoExtraLight();
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
    "${sections[0].first.first[0]}-${sections[0].last.first[0]}",
    "${sections[1].first.first[0]}-${sections[1].last.first[0]}",
    "${sections[2].first.first[0]}-${sections[2].last.first[0]}",
  ];

  for (var i = 0; i < sections.length; i++) {
    sections[i].insert(0, ["Name (${sectionsLetters[i]})", "Table", "Seat"]);
  }

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.symmetric(horizontal: 20),
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          children: [
            pw.SizedBox(
              width: double.infinity,
              child: pw.Center(child: pw.Text(title, style: myStlyeLarge)),
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
                            TableEntry(person[0], myStlyeSmall),
                            pw.Center(
                                child: TableEntry(person[1], myStlyeSmall)),
                            pw.Center(
                                child: TableEntry(person[2], myStlyeSmall)),
                          ])
                      ]),
              ],
            ),
          ],
        );
      },
    ),
  );

  // final file = html.File(await pdf.save(), "SeetingChart.pdf");
  final d = await pdf.save();
  saveByteArray(
    "SeatingChart.pdf",
    d,
  );
}

void saveByteArray(String reportName, Uint8List byte) {
  var blob = html.Blob([byte], "application/pdf");
  var link = html.AnchorElement(href: html.Url.createObjectUrl(blob));
  var fileName = reportName;
  link.download = fileName;
  link.click();
}

class TableEntry extends pw.StatelessWidget {
  final String data;
  final pw.TextStyle style;
  TableEntry(this.data, this.style);
  @override
  pw.Widget build(context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(3, 5, 3, 5),
      child: pw.Text(
        data,
        style: style,
      ),
    );
  }
}
