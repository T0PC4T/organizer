import 'dart:async';
import 'dart:io';

import 'day.dart';

enum FeastColor {
  white("White", "LightYellow"),
  green("Green", "ForestGreen"),
  purple("Purple", "MediumOrchid"),
  black("Black", "black"),
  red("Red", "Crimson");

  final String colorName;
  final String color;
  const FeastColor(this.colorName, this.color);
}

enum FeastClass {
  firstClass("I. Class"),
  secondClass("II. Class"),
  thirdClass("III. Class"),
  fourthClass("IV. Class");

  final String feastName;
  const FeastClass(this.feastName);
}

bool isMassForDead(String name) {
  return name == "Missa Cotidiana pro Defunctis";
}

FeastWithCommemorationsData makeFeastWithCommemorations(
    FeastData feast, List<FeastData> comms, List<FeastData> alts) {
  List<FeastData> a = alts;
  if (alts.any((e) => e.latinName.contains("Feria Adventus")) &&
      !feast.latinName.contains("Guadalupe")) {
    a = alts
        .where((element) => !element.latinName.contains("Feria Adventus"))
        .toList();
    comms.add(alts.firstWhere((e) => e.latinName.contains("Feria Adventus")));
  }
  if (alts.any((e) => e.latinName.contains("Feria Maior Adventus"))) {
    a = alts
        .where((element) => !element.latinName.contains("Feria Maior Adventus"))
        .toList();
    comms.add(
        alts.firstWhere((e) => e.latinName.contains("Feria Maior Adventus")));
  }
  List<FeastData> c = comms
      .where((element) =>
          !isFeriaVotiveMassOrUSProper(element.latinName) &&
          !isProAliquibusLocis(element.latinName) &&
          !isMassForDead(element.latinName))
      .toList();
  if (isMassForDead(feast.latinName)) {
    c = [];
  }
  return (
    alternatives: a,
    commemorations: c,
    latinName: feast.latinName,
    englishName: feast.englishName,
    feastClass: feast.feastClass,
    color: feast.color,
    readingID: feast.readingID
  );
}

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

DateTime getDatePropriumDeTempore(
    int year,
    ({
      String englishName,
      String latinName,
      String daysToEaster,
      String daysFromEaster,
      FeastClass feastClass,
      FeastColor color,
      String readingID
    }) feast) {
  DateTime easter = parseTime(year, easterDate(year));
  if (feast.daysToEaster == '') {
    return easter.add(Duration(days: int.parse(feast.daysFromEaster)));
  }
  return easter.subtract(Duration(days: int.parse(feast.daysToEaster)));
}

DateTime parseTime(int year, String mmddFormatWithDashInBetween) {
  return DateTime.parse("$year-$mmddFormatWithDashInBetween 12:00:00");
}

Feast getFeastData(
    ({
      String date,
      String latinName,
      String englishName,
      FeastClass feastClass,
      FeastColor color,
      String readingID,
    }) feast) {
  return Feast(feast.latinName, feast.englishName, feast.feastClass,
      feast.color, feast.readingID);
}

bool isFeriaVotiveMassOrUSProper(String name) {
  return name == "Feria" ||
      name.startsWith("Immaculati Cordis") ||
      name.startsWith("Jesu Christi Summi") ||
      name.startsWith("Sacratissimi Cordis") ||
      name.startsWith("Sancta Maria Sabbato") ||
      name.startsWith("(USA)") ||
      name.endsWith("Januarii") ||
      name.contains("Septuagesimae") ||
      name.contains("Rogationibus") ||
      isMassForDead(name);
}

bool isProAliquibusLocis(String name) {
  return name.startsWith("In Inventione St. Sthephani") ||
      name.startsWith("S. Petri ad Vincula");
}

FeastClass strToFeastClass(String feastClass) {
  final Map<String, FeastClass> conv = {
    "I. Class": FeastClass.firstClass,
    "II. Class": FeastClass.secondClass,
    "III. Class": FeastClass.thirdClass,
    "IV. Class": FeastClass.fourthClass
  };
  return conv[feastClass]!;
}

FeastColor strToFeastColor(String color) {
  final Map<String, FeastColor> conv = {
    FeastColor.red.color: FeastColor.red,
    FeastColor.white.color: FeastColor.white,
    FeastColor.black.color: FeastColor.black,
    FeastColor.purple.color: FeastColor.purple,
    FeastColor.green.color: FeastColor.green
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
  var date = '${dt.month < 10 ? ("0${dt.month}") : dt.month.toString()}-';
  date += dt.day < 10 ? ("0${dt.day}") : dt.day.toString();
  return date;
}
