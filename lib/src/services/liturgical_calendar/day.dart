import 'package:intl/intl.dart';

import 'utils.dart';

class Day {
  Day(DateTime date, DateTime easter)
      : date = date,
        easter = easter,
        isQuadragesima = false,
        isHolyWeek = false,
        feasts = <Feast>[] {
    isQuadragesima = date.compareTo(easter) < 0 &&
        date.compareTo(easter.subtract(const Duration(days: 46))) > 0;
    isHolyWeek = date.compareTo(easter) < 0 &&
        date.compareTo(easter.subtract(const Duration(days: 7))) > 0;

    if (date.weekday != DateTime.sunday && isQuadragesima && !isHolyWeek) {
      feasts.add(Feast("Feria Quadragesimae", "Feria of Lent",
          FeastClass.ThirdClass, Color.purple, PropriumType.Tempore));
    }
  }

  bool isFeastDay() {
    return feasts
        .map((e) => e.feastClass != FeastClass.FourthClass)
        .contains(true);
  }

  bool containsFeast(String name) {
    return feasts.map((e) => e.latinName.startsWith(name)).contains(true);
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
          "class": "FourthClass",
          "color": "default"
        }
      };
    }
    return {getDateFormat(): formatFeast()};
  }

  bool isFeastOfTheLord() {
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

  dynamic formatFeast() {
    if (feasts.length == 1) {
      return feasts.first.formatJSON();
    }
    if (containsFeastOfClass(FeastClass.FirstClass)) {
      return getIClassFeast().formatJSON();
    }
    if (isFeastOfTheLord()) {
      dynamic feast = getFeastOfTheLord();
      feast["commemorations"] =
          getFeastsOfClassExceptOne(FeastClass.SecondClass, feast["latinName"]);
      return feast;
    }
    if (isSunday()) {
      // check if is feast of the Lord
      dynamic feast = feasts
          .firstWhere((element) => element.latinName.contains("Dominica"))
          .formatJSON();
      feast["commemorations"] =
          getFeastsOfClassExceptOne(FeastClass.SecondClass, "Dominica");
      return feast;
    }

    if (containsFeastOfClass(FeastClass.SecondClass)) {
      Feast feast = feasts.firstWhere(
          (element) => element.feastClass == FeastClass.SecondClass);
      var comm =
          getFeastsOfClassExceptOne(FeastClass.SecondClass, feast.latinName);
      comm.addAll(getFeastsOfClass(FeastClass.ThirdClass));
      Map<String, dynamic> ret = feast.formatJSON();
      ret["commemorations"] = comm;
      return ret;
    }
    if (containsFeastOfClass(FeastClass.ThirdClass)) {
      Feast feast = feasts
          .firstWhere((element) => element.feastClass == FeastClass.ThirdClass);
      var comm =
          getFeastsOfClassExceptOne(FeastClass.SecondClass, feast.latinName);
      dynamic ret = feast.formatJSON();
      ret["commemorations"] = comm;
      return ret;
    }
    if (isFeria()) {
      var comm = getFeastsOfClass(FeastClass.FourthClass);
      Map<String, dynamic> ret = {
        "latinName": "Feria",
        "englishName": "Feria",
        "class": "FourthClass",
        "color": "default"
      };
      if (comm.isEmpty) return ret;
      ret["commemorations"] = comm;
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
  bool isHolyWeek;

  bool isSundayOfAdvent() {
    return feasts
        .map((e) =>
            e.latinName.startsWith("Dominica") &&
            e.latinName.contains("Adventus"))
        .contains(true);
  }

  Feast getIClassFeast() {
    return feasts
        .firstWhere((element) => element.feastClass == FeastClass.FirstClass);
  }
}

class Feast {
  Feast(String latinName, String englishName, FeastClass feastClass,
      Color color, PropriumType prop)
      : latinName = latinName,
        englishName = englishName,
        feastClass = feastClass,
        color = color,
        proprium = prop;

  bool isPropiumSanctorum() {
    return proprium == PropriumType.Sanctorum;
  }

  bool isPropriumDeTempore() {
    return proprium == PropriumType.Tempore;
  }

  Map<String, dynamic> formatJSON() {
    return {
      "latinName": latinName,
      "englishName": englishName,
      "class": feastClass.toString().split('.')[1],
      "color": color.toString().split('.')[1]
    };
  }

  String latinName;
  String englishName;
  FeastClass feastClass;
  Color color;
  PropriumType proprium;
}
