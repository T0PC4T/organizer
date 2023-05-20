import 'package:intl/intl.dart';

import 'utils.dart';

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
        date.compareTo(easter.subtract(const Duration(days: 46))) > 0;
    isHolyWeek = date.compareTo(easter) < 0 &&
        date.compareTo(easter.subtract(const Duration(days: 7))) > 0;
    isPaschalTime = date.compareTo(easter) > 0 &&
        date.compareTo((easter.add(const Duration(days: 50)))) < 0;

    if (date.weekday != DateTime.sunday &&
        isSeptuagesima &&
        !isQuadragesima &&
        !isHolyWeek) {
      feasts.add(Feast("Feria Septuagesimae", "Feria", FeastClass.fourthClass,
          Color.purple));
    }
    if (date.weekday != DateTime.sunday && isQuadragesima && !isHolyWeek) {
      feasts.add(Feast("Feria Quadragesimae", "Feria of Lent",
          FeastClass.thirdClass, Color.purple));
    }

    if (date.weekday != DateTime.sunday && isPaschalTime) {
      feasts.add(Feast("Feria", "Feria", FeastClass.fourthClass, Color.white));
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

  Map<String, dynamic> formatJSON() {
    if (feasts.isEmpty) {
      return {
        getDateFormat(): {
          "latinName": "Feria",
          "englishName": "Feria",
          "class": "IV. Class",
          "color": "Green",
          "commemorations": []
        }
      };
    }
    return {getDateFormat(): finalFeastPolish(formatFeast())};
  }

  dynamic finalFeastPolish(dynamic feastData) {
    Feast mainFeast = getFeastFromDynamic(feastData);
    List<Feast> others = <Feast>[];
    for (var c in feastData['commemorations']) {
      others.add(getFeastFromDynamic(c));
    }
    if (mainFeast.englishName.contains("Feria of Lent") ||
        mainFeast.englishName.contains("Feira of Advent") ||
        (mainFeast.feastClass == FeastClass.secondClass &&
            isFeastOfTheLord(mainFeast))) {
      feastData["alternatives"] = [];
    } else {
      List<Map<String, dynamic>> alts = [];
      if (feastData["alternatives"] != null) {
        for (var c in feastData['alternatives']) {
          if (!alts.any((e) => e["latinName"] == c["latinName"])) {
            alts.add(c);
          }
        }
      }
      List<Map<String, dynamic>> comms = [];
      for (var c in feastData['commemorations']) {
        if (!alts.any((e) => e["latinName"] == c["latinName"])) {
          comms.add(c);
        }
      }
      feastData["alternatives"] = alts;
      feastData["commemorations"] = comms;
    }
    return feastData;
  }

  void removeFeastsFromCommemorations(dynamic feastData) {}

  Feast getFeastFromDynamic(dynamic data) {
    Map<String, FeastClass> feastClass = {
      "I. Class": FeastClass.firstClass,
      "II. Class": FeastClass.secondClass,
      "III. Class": FeastClass.thirdClass,
      "IV. Class": FeastClass.fourthClass
    };
    Map<String, Color> feastColor = {
      "White": Color.white,
      "Green": Color.green,
      "Purple": Color.purple,
      "Black": Color.black,
      "Red": Color.red,
    };
    return Feast(data['latinName'], data['englishName'],
        feastClass[data['class']]!, feastColor[data['color']]!);
  }

  bool isFeastOfTheLord(Feast feast) {
    final List<String> feastsOfTheLord = <String>[
      "Domini Nostri",
      "In Purificatione",
      "In Exaltatione ",
      "Basilicae Ss. Salvatoris"
    ];
    return feastsOfTheLord.any((name) => feast.latinName.contains(name));
  }

  bool containsFeastOfTheLord() {
    final List<String> feastsOfTheLord = <String>[
      "Domini Nostri",
      "In Purificatione",
      "In Exaltatione ",
      "Basilicae Ss. Salvatoris"
    ];
    return feasts
        .map((e) =>
            feastsOfTheLord.any((element) => e.latinName.contains(element)))
        .contains(true);
  }

  Map<String, dynamic> getFeastOfTheLord() {
    final List<String> feastsOfTheLord = <String>[
      "Domini Nostri",
      "In Purificatione",
      "In Exaltatione ",
      "Basilicae Ss. Salvatoris"
    ];
    Map<String, dynamic> feast = feasts
        .firstWhere((element) =>
            feastsOfTheLord.any((e) => element.latinName.contains(e)))
        .formatJSON();
    feast["feastOfTheLord"] = true;
    return feast;
  }

  Map<String, dynamic> getSunday() {
    return feasts
        .firstWhere((element) => element.latinName.contains("Dominica"))
        .formatJSON();
  }

  dynamic formatFeast() {
    if (feasts.length == 1 &&
        isFeastDay() &&
        !isFeriaVotiveMassOrUSProper(feasts.first.latinName)) {
      dynamic feast = feasts.first.formatJSON();
      feast["commemorations"] = [];
      feast["alternatives"] = [];
      return feast;
    }
    if (containsFeastOfClass(FeastClass.firstClass)) {
      dynamic feast = getIClassFeast().formatJSON();
      if (isSunday()) {
        Map<String, dynamic> f = getSunday();
        if (f["latinName"] != feast["latinName"]) {
          feast["commemorations"] = [f];
        } else {
          feast["commemorations"] = [];
        }
      } else {
        feast["commemorations"] = [];
      }
      return feast;
    }
    if (containsFeastOfTheLord()) {
      dynamic feast = getFeastOfTheLord();
      feast["commemorations"] =
          getFeastsOfClassExceptOne(FeastClass.secondClass, feast["latinName"]);
      return feast;
    }
    if (isSunday()) {
      dynamic feast = getSunday();
      feast["commemorations"] =
          getFeastsOfClassExceptOne(FeastClass.secondClass, "Dominica").where(
              (element) => !element["englishName"].startsWith("(USA)External"));
      if (containsFeast("(USA)Externa")) {
        feast["alternatives"] = [
          feasts
              .where(
                  (element) => element.englishName.startsWith("(USA)External"))
              .first
              .formatJSON()
        ];
      }
      return feast;
    }

    if (containsFeastOfClass(FeastClass.secondClass)) {
      dynamic feast = feasts
          .firstWhere((element) => element.feastClass == FeastClass.secondClass)
          .formatJSON();
      feast["alternatives"] =
          getFeastsOfClassExceptOne(FeastClass.secondClass, feast["latinName"]);

      feast["commemorations"] = getFeastsOfClass(FeastClass.thirdClass);
      return feast;
    }

    if (containsFeastOfClass(FeastClass.thirdClass)) {
      dynamic feast = feasts
          .firstWhere((element) => element.feastClass == FeastClass.thirdClass)
          .formatJSON();

      feast["alternatives"] =
          getFeastsOfClassExceptOne(FeastClass.thirdClass, feast["latinName"]);

      if (isFeriaVotiveMassOrUSProper(feast["latinName"]) &&
          (feast["alternatives"].length == 0 ||
              (feast["alternatives"] as List).every((element) =>
                  isFeriaVotiveMassOrUSProper(element["latinName"]) ||
                  element["class"] == FeastClass.fourthClass))) {
        var ff = getFeastsOfClass(FeastClass.fourthClass)
            .where((element) =>
                !isFeriaVotiveMassOrUSProper(element["latinName"]) ||
                element["latinName"].startsWith("Sancta Maria Sabbato"))
            .toList();
        ff.add(Feast("Feria", "Feria", FeastClass.fourthClass, Color.green)
            .formatJSON());
        feast["alternatives"].addAll(ff);
        feast["commemorations"] = [];
      } else {
        feast["commemorations"] = getFeastsOfClass(FeastClass.fourthClass)
            .where((element) =>
                !isFeriaVotiveMassOrUSProper(element["latinName"]) &&
                !isProAliquibusLocis(element["latinName"]));
      }
      return feast;
    }
    if (isFeria()) {
      Feast f = feasts.firstWhere(
          (element) => element.englishName.contains("Feria"),
          orElse: () =>
              Feast("Feria", "Feria", FeastClass.fourthClass, Color.green));
      dynamic ret = f.formatJSON();
      ret["commemorations"] = [];
      ret["alternatives"] =
          getFeastsOfClassExceptOne(FeastClass.fourthClass, f.latinName);
      return ret;
    }
  }

  List<Map<String, dynamic>> getFeastsOfClass(FeastClass feastClass) {
    if (containsFeastOfClass(feastClass)) {
      return feasts
          .where((element) => element.feastClass == feastClass)
          .map((e) => e.formatJSON())
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> getFeastsOfClassExceptOne(
      FeastClass feastClass, String latinName) {
    if (containsFeastOfClass(feastClass)) {
      return feasts
          .where((element) =>
              element.feastClass == feastClass &&
              !element.latinName.contains(latinName))
          .map((e) => e.formatJSON())
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

  Feast getIClassFeast() {
    return feasts
        .firstWhere((element) => element.feastClass == FeastClass.firstClass);
  }
}

class Feast {
  Feast(this.latinName, this.englishName, this.feastClass, this.color);

  Map<String, dynamic> formatJSON() {
    return {
      "latinName": latinName,
      "englishName": englishName,
      "class": feastClass.feastName,
      "color": color.colorName
    };
  }

  String latinName;
  String englishName;
  FeastClass feastClass;
  Color color;
}
