import 'package:intl/intl.dart';

import 'utils.dart';

typedef FeastData = ({
  String latinName,
  String englishName,
  String feastClass,
  String color,
  String readingID
});

typedef FeastWithCommemorationsData = ({
  String latinName,
  String englishName,
  String feastClass,
  String color,
  String readingID,
  List<FeastData> commemorations,
  List<FeastData> alternatives
});

typedef FeastDayData = ({
  String date,
  String latinName,
  String englishName,
  String feastClass,
  String color,
  String readingID,
  String commemorations
});

class Day {
  Day(this.date, this.easter)
      : isSeptuagesima = false,
        isQuadragesima = false,
        isHolyWeek = false,
        isPaschalTime = false,
        feasts = <Feast>[] {
    isSeptuagesima = date.compareTo(easter) < 0 &&
        date.compareTo(easter.subtract(const Duration(days: 63))) > 0;
    isQuadragesima = date.compareTo(easter) < 0 &&
        date.compareTo(easter.subtract(const Duration(days: 42))) > 0;
    isHolyWeek = date.compareTo(easter) < 0 &&
        date.compareTo(easter.subtract(const Duration(days: 7))) > 0;
    isPaschalTime = date.compareTo(easter) > 0 &&
        date.compareTo((easter.add(const Duration(days: 50)))) < 0;

    if (date.weekday != DateTime.sunday &&
        isSeptuagesima &&
        !isQuadragesima &&
        !isHolyWeek) {
      feasts.add(Feast("Feria Septuagesimae", "Feria", FeastClass.fourthClass,
          FeastColor.purple, ""));
    }
    if (date.weekday != DateTime.sunday && isQuadragesima && !isHolyWeek) {
      feasts.add(Feast("Feria Quadragesimae", "Feria of Lent",
          FeastClass.thirdClass, FeastColor.purple, ""));
    }

    if (date.weekday != DateTime.sunday && isPaschalTime) {
      feasts.add(Feast(
          "Feria", "Feria", FeastClass.fourthClass, FeastColor.white, ""));
    }
  }

  void removeFeastWithName(String latinName) {
    feasts.removeWhere((element) => element.latinName.contains(latinName));
  }

  bool isFeastDay() {
    return feasts
        .map((e) => e.feastClass != FeastClass.fourthClass)
        .contains(true);
  }

  bool containsFeast(String name) {
    return feasts.map((e) => e.latinName.contains(name)).contains(true);
  }

  bool isFeria() {
    return !isFeastDay();
  }

  void addFeast(Feast feast) {
    feasts.add(feast);
  }

  bool isSunday() {
    return date.weekday == DateTime.sunday;
  }

  String getDateFormat() {
    final DateFormat formatter = DateFormat('MM-dd');
    return formatter.format(date);
  }

  Map<String, FeastWithCommemorationsData> formatFeasts() {
    if (feasts.isEmpty) {
      return {
        getDateFormat(): (
          latinName: "Feria",
          englishName: "Feria",
          feastClass: FeastClass.fourthClass.feastName,
          color: FeastColor.green.colorName,
          commemorations: [],
          alternatives: [],
          readingID: ""
        )
      };
    }
    return {getDateFormat(): finalFormat()};
  }

  FeastWithCommemorationsData finalFormat() {
    if (feasts.isEmpty) {
      throw "Empty feast ${date.day}";
    }
    if (feasts.length == 1 &&
        isFeastDay() &&
        !isFeriaVotiveMassOrUSProper(feasts.first.latinName)) {
      FeastData feast = feasts.first.formatFeast();
      return makeFeastWithCommemorations(feast, [], []);
    }

    if (containsFeastOfClass(FeastClass.firstClass)) {
      return getIClassFeastDataWithCommemorations();
    }

    if (containsFeastOfTheLord()) {
      return makeFeastWithCommemorations(
          getFeastOfTheLord(), getFeastsOfClass(FeastClass.secondClass), []);
    }
    if (isSunday()) {
      return getSundayFeastDataWithCommemorations();
    }

    if (containsFeastOfClass(FeastClass.secondClass) &&
        (getFeastsOfClass(FeastClass.secondClass).length > 1 ||
            !containsFeast("Rogationibus"))) {
      print(date);
      for (var element in feasts) {
        print(element.englishName);
      }
      return getIIClassFeastDataWithCommemorations();
    }

    if (containsFeastOfClass(FeastClass.thirdClass)) {
      return getIIIClassFeastDataWithCommemorations();
    }

    if (containsFeastOfClass(FeastClass.fourthClass)) {
      return getIVClassFeastDataWithCommemorations();
    }

    return makeFeastWithCommemorations(
        Feast("Feria", "Feria", FeastClass.fourthClass, FeastColor.green, "")
            .formatFeast(),
        [],
        []);
  }

  Feast feastFromFeastData(FeastData feast) {
    return Feast(
        feast.latinName,
        feast.englishName,
        strToFeastClass(feast.feastClass),
        strToFeastColor(feast.color),
        feast.readingID);
  }

  FeastWithCommemorationsData getIVClassFeastDataWithCommemorations() {
    Feast f = feasts.firstWhere(
        (element) => element.englishName.contains("Feria"),
        orElse: () => Feast(
            "Feria", "Feria", FeastClass.fourthClass, FeastColor.green, ""));

    FeastData feast = f.formatFeast();

    List<FeastData> alts =
        getFeastsOfClassExceptOne(FeastClass.fourthClass, f.latinName);
    if (containsFeast("Rogationibus")) {
      alts.addAll([
        feasts
            .firstWhere((element) => element.englishName.contains("Rogation"))
            .formatFeast()
      ]);
    }
    return makeFeastWithCommemorations(feast, [], alts);
  }

  FeastWithCommemorationsData getIIIClassFeastDataWithCommemorations() {
    List<FeastData> comms = [];
    List<FeastData> alts = [];
    FeastData feast;
    var feria = feasts
        .where((element) => element.latinName.contains("Feria Quadragesimae"));
    if (feria.isNotEmpty) {
      feast = feria.first.formatFeast();
      alts = [];
      comms = getFeastsOfClassExceptOne(FeastClass.thirdClass, feast.latinName);
      comms.addAll(getFeastsOfClass(FeastClass.fourthClass));
      if (containsFeast("Rogationibus")) {
        alts.addAll([
          feasts
              .firstWhere((element) => element.englishName.contains("Rogation"))
              .formatFeast()
        ]);
      }
      return makeFeastWithCommemorations(feast, comms, alts);
    } else {
      feast = feasts
          .firstWhere((element) => element.feastClass == FeastClass.thirdClass)
          .formatFeast();
      alts = getFeastsOfClassExceptOne(FeastClass.thirdClass, feast.latinName);
    }
    if (isFeriaVotiveMassOrUSProper(feast.latinName) &&
        (alts.isEmpty ||
            alts.every((element) =>
                isFeriaVotiveMassOrUSProper(element.latinName) ||
                element.feastClass == FeastClass.fourthClass.feastName))) {
      var ff = getFeastsOfClass(FeastClass.fourthClass)
          .where((element) =>
              !isFeriaVotiveMassOrUSProper(element.latinName) ||
              element.latinName.startsWith("Sancta Maria Sabbato"))
          .toList();
      if (!ff.any((e) => e.englishName.contains("Christmastide"))) {
        ff.add(Feast(
                "Feria", "Feria", FeastClass.fourthClass, FeastColor.green, "")
            .formatFeast());
      }
      alts.addAll(ff);
      comms = [];
    } else {
      comms = getFeastsOfClass(FeastClass.fourthClass)
          .where((element) =>
              !isFeriaVotiveMassOrUSProper(element.latinName) &&
              !isProAliquibusLocis(element.latinName))
          .toList();
    }
    comms.removeWhere(
        (element) => element.englishName.contains("Christmastide"));

    if (containsFeast("Rogationibus")) {
      alts.addAll([
        feasts
            .firstWhere((element) => element.englishName.contains("Rogation"))
            .formatFeast()
      ]);
    }
    return makeFeastWithCommemorations(feast, comms, alts);
  }

  FeastWithCommemorationsData getIIClassFeastDataWithCommemorations() {
    List<FeastData> comms = [];
    List<FeastData> alts = [];
    FeastData feast;
    var emberDay =
        feasts.where((element) => element.latinName.contains("Quattuor Temp"));
    if (emberDay.isNotEmpty) {
      feast = emberDay.first.formatFeast();
      alts = [];
    } else {
      feast = feasts
          .firstWhere((element) => element.feastClass == FeastClass.secondClass)
          .formatFeast();
      alts = getFeastsOfClassExceptOne(FeastClass.secondClass, feast.latinName);
    }

    comms = getFeastsOfClass(FeastClass.thirdClass);
    comms.addAll(getFeastsOfClass(FeastClass.fourthClass));
    comms.removeWhere(
        (element) => element.englishName.contains("Christmastide"));
    return makeFeastWithCommemorations(feast, comms, alts);
  }

  FeastWithCommemorationsData getSundayFeastDataWithCommemorations() {
    List<FeastData> comms = [];
    List<FeastData> alts = [];
    FeastData feast = getSunday();
    comms = getFeastsOfClassExceptOne(FeastClass.secondClass, "Dominica")
        .where((element) => !element.englishName.startsWith("(USA)External"))
        .toList();
    comms.removeWhere(
        (element) => element.englishName.contains("Christmastide"));
    if (containsFeast("(USA)Externa")) {
      alts = [
        feasts
            .where((element) => element.englishName.startsWith("(USA)External"))
            .first
            .formatFeast()
      ];
    }
    return makeFeastWithCommemorations(feast, comms, alts);
  }

  FeastWithCommemorationsData getIClassFeastDataWithCommemorations() {
    List<FeastData> comms = [];
    var feast = getIClassFeast().formatFeast();
    if (isSunday() && !isFeastOfTheLord(feastFromFeastData(feast))) {
      FeastData f = getSunday();
      if (f.latinName != feast.latinName) {
        comms.add(f);
      }
    }
    if (containsFeast("Feria Adventus") && !isSundayOfAdvent()) {
      comms.add((
        color: FeastColor.purple.color,
        englishName: "Feria of Advent",
        latinName: "Feria Adventus",
        feastClass: FeastClass.thirdClass.name,
        readingID: ""
      ));
    }
    if (containsFeast("Feria Quadragesimae") &&
        !isSundayOfLent() &&
        !containsFeast("post Cineres")) {
      comms.add((
        color: FeastColor.purple.color,
        englishName: "Feria of Lent",
        latinName: "Feria Quadragesimae",
        feastClass: FeastClass.thirdClass.name,
        readingID: ""
      ));
    }
    comms.removeWhere(
        (element) => element.englishName.contains("Christmastide"));
    return makeFeastWithCommemorations(feast, comms, []);
  }

  bool isFeastOfTheLord(Feast feast) {
    final List<String> feastsOfTheLord = <String>[
      "Domini Nostri",
      "In Purificatione",
      "In Exaltatione "
    ];
    return feastsOfTheLord.any((name) => feast.latinName.contains(name));
  }

  bool containsFeastOfTheLord() {
    final List<String> feastsOfTheLord = <String>[
      "Domini Nostri",
      "In Purificatione",
      "In Exaltatione "
    ];
    return feasts
        .map((e) =>
            feastsOfTheLord.any((element) => e.latinName.contains(element)))
        .contains(true);
  }

  FeastData getFeastOfTheLord() {
    final List<String> feastsOfTheLord = <String>[
      "Domini Nostri",
      "In Purificatione",
      "In Exaltatione "
    ];
    FeastData feast = feasts
        .firstWhere((element) =>
            feastsOfTheLord.any((e) => element.latinName.contains(e)))
        .formatFeast();
    return feast;
  }

  FeastData getSunday() {
    return feasts
        .firstWhere((element) => element.latinName.contains("Dominica"))
        .formatFeast();
  }

  List<FeastData> getFeastsOfClass(FeastClass feastClass) {
    if (containsFeastOfClass(feastClass)) {
      return feasts
          .where((element) => element.feastClass == feastClass)
          .map((e) => e.formatFeast())
          .toList();
    }
    return [];
  }

  List<FeastData> getFeastsOfClassExceptOne(
      FeastClass feastClass, String latinName) {
    if (containsFeastOfClass(feastClass)) {
      return feasts
          .where((element) =>
              element.feastClass == feastClass &&
              !element.latinName.contains(latinName))
          .map((e) => e.formatFeast())
          .toList();
    }
    return [];
  }

  bool containsFeastOfClass(FeastClass feastClass) {
    return feasts.map((e) => e.feastClass == feastClass).contains(true);
  }

  List<Feast> feasts;
  DateTime date;
  DateTime easter;
  bool isQuadragesima;
  bool isSeptuagesima;
  bool isHolyWeek;
  bool isPaschalTime;

  bool isSundayOfAdvent() {
    return feasts
        .map((e) =>
            e.latinName.startsWith("Dominica") &&
            e.latinName.contains("Adventus"))
        .contains(true);
  }

  bool isSundayOfLent() {
    return feasts
        .map((e) =>
            e.latinName.startsWith("Dominica") &&
            e.latinName.contains("Quadragesimae"))
        .contains(true);
  }

  Feast getIClassFeast() {
    return feasts
        .firstWhere((element) => element.feastClass == FeastClass.firstClass);
  }
}

class Feast {
  Feast(this.latinName, this.englishName, this.feastClass, this.color,
      this.readingID);

  Feast.fromFeastData(FeastData data)
      : latinName = data.latinName,
        englishName = data.englishName,
        color = strToFeastColor(data.color),
        feastClass = strToFeastClass(data.feastClass),
        readingID = data.readingID;

  Feast.fromFeastDataWithCommemorations(FeastWithCommemorationsData data)
      : latinName = data.latinName,
        englishName = data.englishName,
        color = strToFeastColor(data.color),
        feastClass = strToFeastClass(data.feastClass),
        readingID = data.readingID;

  FeastData formatFeast() {
    return (
      latinName: latinName,
      englishName: englishName,
      feastClass: feastClass.feastName,
      color: color.color,
      readingID: readingID
    );
  }

  String latinName;
  String englishName;
  FeastClass feastClass;
  FeastColor color;
  String readingID;
}
