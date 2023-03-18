import 'dart:async';
import 'dart:io';

import 'day.dart';

enum Color { white, green, purple, black, red }

enum FeastClass { FourthClass, ThirdClass, SecondClass, FirstClass }

enum PropriumType { Sanctorum, Tempore }

Future<List<Map<String, String>>> readCSV(filename) async {
  final File file = File(filename);

  List<String> headers = <String>[];
  List<Map<String, String>> ret = <Map<String, String>>[];

  var lines = await file.readAsLines();
  lines.asMap().forEach((ind, line) {
    List<String> row = line.split(';');
    if (ind == 0) {
      headers = row;
    } else {
      ret.add(Map.fromIterables(headers, row));
    }
  });
  return ret;
}

DateTime getFeastDate(int year, Map<String, String> feast, PropriumType type) {
  if (type == PropriumType.Tempore) {
    return getDatePropriumDeTempore(year, feast);
  }
  return parseTime(year, feast['date']!);
}

DateTime getDatePropriumDeTempore(year, feast) {
  DateTime Easter = parseTime(year, easterDate(year));
  if (feast['daysToEaster'] == '') {
    return Easter.add(Duration(days: int.parse(feast['daysFromEaster'])));
  }
  return Easter.subtract(Duration(days: int.parse(feast['daysToEaster'])));
}

DateTime parseTime(int year, String mmddFormatWithDashInBetween) {
  return DateTime.parse(
      year.toString() + '-' + mmddFormatWithDashInBetween + " 12:00:00");
}

Feast getFeastData(Map<String, String> feast, PropriumType type) {
  return Feast(feast['latinName']!, feast['englishName']!,
      strToFeastClass(feast['class']!), strToFeastColor(feast['color']!), type);
}

FeastClass strToFeastClass(String feastClass) {
  final Map<String, FeastClass> conv = {
    "I. classis": FeastClass.FirstClass,
    "II. classis": FeastClass.SecondClass,
    "III. classis": FeastClass.ThirdClass,
    "IV. classis": FeastClass.FourthClass
  };
  return conv[feastClass]!;
}

Color strToFeastColor(String color) {
  final Map<String, Color> conv = {
    "red": Color.red,
    "white": Color.white,
    "black": Color.black,
    "purple": Color.purple,
    "green": Color.green
  };
  return conv[color]!;
}

String easterDate(y) {
  int a = y % 19;
  int b = y ~/ 100;
  int c = y % 100;
  int d = b ~/ 4;
  int e = b % 4;
  int f = (b + 8) ~/ 25;
  int g = (b - f + 1) ~/ 3;
  int h = (19 * a + b - d - g + 15) % 30;
  int i = c ~/ 4;
  int k = c % 4;
  int l = (32 + 2 * e + 2 * i - h - k) % 7;
  int m = (a + 11 * h + 22 * l) ~/ 451;
  var month = (h + l - 7 * m + 114) ~/ 31 == 3 ? "03" : "04";
  int p = (h + l - 7 * m + 114) % 31;
  var day = p + 1;
  var dayStr = day < 10 ? "0$day" : day.toString();
  return ('$month-$dayStr');
}

String getDate(DateTime dt) {
  var date =
      '${dt.month < 10 ? ("0" + dt.month.toString()) : dt.month.toString()}-';
  date += dt.day < 10 ? ("0${dt.day}") : dt.day.toString();
  return date;
}
