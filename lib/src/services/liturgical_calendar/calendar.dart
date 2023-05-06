import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';

import 'day.dart';
import 'utils.dart';

class Calendar {
  Calendar(this.year)
      : days = <Day>[],
        easter = parseTime(year, easterDate(year)) {
    DateTime start = DateTime(year, 1, 1, 12, 0, 0);
    DateTime end = DateTime(year + 1, 1, 1, 10, 0, 0);
    Duration diff = const Duration(days: 1);
    while (start.isBefore(end)) {
      addNewDay(Day(start, easter));
      start = start.add(diff);
    }
  }

  void addNewDay(Day day) {
    days.add(day);
  }

  void addFeast(DateTime date, Feast feast) {
    Day originalDay = getDayAtDate(date);
    Day day = getDayIfFeastTransfered(originalDay, feast);
    day.addFeast(feast);
    if (feast.latinName.contains("Quattuor Temporum Quadr")) {
      day.removeFeastWithName("Feria Quadr");
    }
  }

  Day getDayIfFeastTransfered(Day originalDay, Feast feast) {
    //Trasfer of the Feast in case two First Class Feast occur on the same day
    if (feast.feastClass != FeastClass.firstClass) {
      return originalDay;
    }
    if (!originalDay.containsFeastOfClass(FeastClass.firstClass)) {
      return originalDay;
    }
    if (originalDay.isHolyWeek) {
      return dayAfterTheOctaveOfEaster();
    }
    if (originalDay.isSunday() || originalDay.isQuadragesima) {
      return getDayIfFeastTransfered(nextDay(originalDay), feast);
    }
    if (originalDay.isSundayOfAdvent()) {
      return getDayIfFeastTransfered(nextDay(originalDay), feast);
    }

    //Should we compare feasts for more noble one? How?
    return getDayIfFeastTransfered(nextDay(originalDay), feast);
  }

  Day nextDay(Day orig) {
    return getDayAtDate(orig.date.add(const Duration(days: 1)));
  }

  Day dayAfterTheOctaveOfEaster() {
    return getDayAtDate(easter.add(const Duration(days: 8)));
  }

  Day getDayAtDate(DateTime date) {
    final DateFormat formatter = DateFormat('MM-dd');
    final datef = formatter.format(date);
    return getDayAtDateStr(datef);
  }

  Day getDayAtDateStr(String date) {
    return days.firstWhere((element) => element.getDateFormat() == date);
  }

  String getOrdinalSuffix(int i) {
    var j = i % 10, k = i % 100;
    if (j == 1 && k != 11) {
      return "${i}st";
    }
    if (j == 2 && k != 12) {
      return "${i}nd";
    }
    if (j == 3 && k != 13) {
      return "${i}rd";
    }
    return "${i}th";
  }

  static const weekdays = [
    "-",
    "Mon",
    "Tue",
    "Wed",
    "Thur",
    "Fri",
    "Sat",
    "Sun",
  ];

  Map<String, String> formatDataJSON(
      DateTime date, Map<String, dynamic> jsonData,
      {bool alternative = false}) {
    return {
      "date": alternative
          ? ""
          : '${Calendar.weekdays[date.weekday]}, ${getOrdinalSuffix(date.day)}',
      "latinName": jsonData["latinName"],
      "englishName": jsonData["englishName"],
      "color": jsonData["color"],
      "class": (jsonData["class"] as String).replaceAll(". Class", ""),
      "commemorations": ((jsonData["commemorations"] as List?) ?? [])
          .map((e) => e["englishName"])
          .join("<br>")
    };
  }

  void swapMainFeastWithAlternative(var jsonData, altInd) {
    var day = {
      "latinName": jsonData["latinName"],
      "englishName": jsonData["englishName"],
      "color": jsonData["color"],
      "class": (jsonData["class"] as String)
    };

    jsonData["latinName"] = jsonData["alternatives"][altInd]["latinName"];
    jsonData["englishName"] = jsonData["alternatives"][altInd]["englishName"];
    jsonData["color"] = jsonData["alternatives"][altInd]["color"];
    jsonData["class"] = jsonData["alternatives"][altInd]["class"];

    jsonData["alternatives"][altInd]["latinName"] = day["latinName"];
    jsonData["alternatives"][altInd]["englishName"] = day["englishName"];
    jsonData["alternatives"][altInd]["color"] = day["color"];
    jsonData["alternatives"][altInd]["class"] = day["class"];
  }

  Iterable<List<Map<String, String>>> getMonthIterable(int month) sync* {
    for (var element in days.where((day) => day.date.month == month)) {
      final jsonData = element.formatJSON().values.first;
      if (!jsonData.keys.contains("alternatives") ||
          (jsonData["alternatives"] as List).isEmpty) {
        List<Map<String, String>> a = [formatDataJSON(element.date, jsonData)];
        yield a;
      } else {
        var nJsonData = json.decode(json.encode(jsonData));
        nJsonData["commemorations"].addAll(nJsonData["alternatives"]
            .where((i) => !isFeriaOrVotiveMass(i["latinName"])));
        List<Map<String, String>> a = [formatDataJSON(element.date, nJsonData)];
        for (int i = 0; i < (jsonData["alternatives"] as List).length; i++) {
          var nJsonData = json.decode(json.encode(jsonData));
          swapMainFeastWithAlternative(nJsonData, i);
          nJsonData["commemorations"].addAll(nJsonData["alternatives"]
              .where((i) => !isFeriaOrVotiveMass(i["latinName"])));
          a.add(formatDataJSON(element.date, nJsonData, alternative: true));
        }
        yield a;
      }
    }
  }

  void addMissingStuff() {
    addMissingSundays();
    addMovableFeasts();
    polishCalendar();
    addFeriasOfAdvent();
  }

  void saveCalendar() async {
    final File file = File('calendar.json');
    await file.writeAsString(json.encode(formatOutput()));
  }

  Map<String, dynamic> formatOutput() {
    Map<String, dynamic> ret = <String, dynamic>{};
    for (var element in days) {
      ret.addEntries(element.formatJSON().entries);
    }
    return ret;
  }

  void addMovableFeasts() {
    Feast SSNJ = Feast("Sanctissimi Nominis Jesu", "The Holy Name of Jesus",
        FeastClass.secondClass, Color.white);

    Feast SGVPC = Feast(
        "S. Gabrielis a Virgine Pardolente Confessoris",
        "St. Gabriel of Our Lady of Sorrows, Confessor",
        FeastClass.secondClass,
        Color.white);

    Feast SMA = Feast("S. Mathiae Apostoli", "St. Matthias, Apostle",
        FeastClass.secondClass, Color.red);

    var d = DateTime(year, 1, 1).weekday;
    if (d == 1 || d == 2 || d == 7) {
      addFeast(DateTime(year, 1, 2, 12), SSNJ);
    } else {
      addFeast(DateTime(year, 1, 7 - d + 1, 12), SSNJ);
    }

    if (year % 4 == 0 && year % 100 == 0 && year % 400 == 0) {
      addFeast(DateTime(year, 2, 25, 12), SMA);
      addFeast(DateTime(year, 2, 28, 12), SGVPC);
    } else {
      addFeast(DateTime(year, 2, 24, 12), SMA);
      addFeast(DateTime(year, 2, 27, 12), SGVPC);
    }

    Feast DION = Feast(
        "Dominica Infra Octavam Nativitatis",
        "Sunday in the Octave of Christmas",
        FeastClass.secondClass,
        Color.white);

    var dd = DateTime(year, 12, 25);
    d = dd.weekday % 7;
    if (d != 0) {
      dd = dd.add(Duration(days: 7 - d));
      addFeast(dd, DION);
    }

    Feast DNJCR = Feast("Domini Nostri Jesu Christi Regi", "Christ the King",
        FeastClass.firstClass, Color.white);

    d = DateTime(year, 10, 31).weekday % 7;
    DateTime date = DateTime(year, 10, 31 - d, 12);
    addFeast(date, DNJCR);

    var diff = const Duration(days: 9);
    DateTime xx =
        DateTime.parse("$year-${easterDate(year)} 12:00:00").subtract(diff);

    addFeast(
        xx,
        Feast("Septem Dolorum BMV", "Seven Dolours of Our Lady",
            FeastClass.thirdClass, Color.purple));

    d = DateTime(year, 12, 25).weekday;

    diff = const Duration(days: 7);
    xx = DateTime(year, 12, 25 - d, 12);

    for (var i = 0; i < 7; i++) {
      var numDays = Duration(days: i);
      DateTime date = DateTime(year, 12, 17, 12).add(numDays);
      Feast FMA = Feast("Feria Maior Adventus", "Major Feria of Advent",
          FeastClass.secondClass, Color.purple);
      addFeast(date, FMA);
    }

    d = DateTime(year, 1, 6).weekday % 7;
    date = DateTime(year, 1, 13 - d, 12);

    addFeast(
        date,
        Feast(
            "Sanctae Familiae Jesu Mariae Joseph",
            "Holy Family Jesus, Mary, and Joseph",
            FeastClass.firstClass,
            Color.white));
  }

  DateTime getDateOfFeast(String name) {
    return days.firstWhere((element) => element.containsFeast(name)).date;
  }

  void addMissingSundays() {
    Map<String, dynamic> sundays = {
      "Dominica IV Adventus": {
        "eng": "Fourth Sunday of Advent",
        "color": Color.purple,
        "class": FeastClass.firstClass
      },
      "Dominica III Adventus": {
        "eng": "Third Sunday of Advent",
        "color": Color.purple,
        "class": FeastClass.firstClass
      },
      "Dominica II Adventus": {
        "eng": "Second Sunday of Advent",
        "color": Color.purple,
        "class": FeastClass.firstClass
      },
      "Dominica I Adventus": {
        "eng": "First Sunday of Advent",
        "color": Color.purple,
        "class": FeastClass.firstClass
      },
      "Dominica XXIV et Ultima post Pentecosten": {
        "eng": "Twenty second and last Sunday after the Pentecost",
        "color": Color.green,
        "class": FeastClass.secondClass
      },
      "Dominica VI Post Epiphaniam": {
        "eng": "Rsumed Sixth Sunday after the Epiphany",
        "color": Color.green,
        "class": FeastClass.secondClass
      },
      "Dominica V Post Epiphaniam": {
        "eng": "Rsumed Fifth Sunday after the Epiphany",
        "color": Color.green,
        "class": FeastClass.secondClass
      },
      "Dominica IV Post Epiphaniam": {
        "eng": "Rsumed Fourth Sunday after the Epiphany",
        "color": Color.green,
        "class": FeastClass.secondClass
      },
      "Dominica III Post Epiphaniam": {
        "eng": "Rsumed Third Sunday after the Epiphany",
        "color": Color.green,
        "class": FeastClass.secondClass
      },
    };

    DateTime date = getDateOfFeast("In Nativitate Domini");
    Duration previousSunday = Duration(days: date.weekday);
    date = date.subtract(previousSunday);
    sundays.forEach((element, value) {
      if (getDayAtDate(date).containsFeast("Dominica XXIII")) {
        return;
      }

      addFeast(
          date, Feast(element, value['eng'], value['class'], value['color']));

      if (element.startsWith("Dominica III Adventus")) {
        var d = date.add(const Duration(days: 3));

        Feast FQT = Feast("Feria IV Quattuor Temporum Adventus",
            "Ember Wednesday of Advent", FeastClass.secondClass, Color.purple);

        addFeast(d, FQT);
        d = d.add(const Duration(days: 2));
        FQT = Feast("Feria VI Quattuor Temporum Adventus",
            "Ember Friday of Advent", FeastClass.secondClass, Color.purple);
        addFeast(d, FQT);
        d = d.add(const Duration(days: 1));
        FQT = Feast("Sabbato Quattuor Temporum Adventus",
            "Ember Saturday of Advent", FeastClass.secondClass, Color.purple);
        addFeast(d, FQT);
      }
      date = date.subtract(const Duration(days: 7));
    });

    date = DateTime(year, 9, 14);
    var weekday = date.weekday % 7;
    var IVQTS = 7 - weekday + 3;
    date = date.add(Duration(days: IVQTS));

    //if not St. Matthias Appostle
    if (date.day != 21) {
      addFeast(
          date,
          Feast(
              "Feria IV Quattuor Temporum Septembris",
              "Ember Wednesday in September",
              FeastClass.secondClass,
              Color.purple));
    }
    date = date.add(const Duration(days: 2));
    if (date.day != 21) {
      addFeast(
          date,
          Feast(
              "Feria VI Quattuor Temporum Septembris",
              "Ember Friday in September",
              FeastClass.secondClass,
              Color.purple));
    }
    date = date.add(const Duration(days: 1));
    if (date.day != 21) {
      addFeast(
          date,
          Feast(
              "Sabbato Quattuor Temporum Septembris",
              "Ember Saturday in September",
              FeastClass.secondClass,
              Color.purple));
    }

    Map<String, String> sundaysPostEpiphaniam = {
      "Dominica II Post Epiphaniam": "Second Sunday after the Epiphany",
      "Dominica III Post Epiphaniam": "Second Sunday after the Epiphany",
      "Dominica IV Post Epiphaniam": "Second Sunday after the Epiphany",
      "Dominica V Post Epiphaniam": "Second Sunday after the Epiphany",
      "Dominica VI Post Epiphaniam": "Second Sunday after the Epiphany"
    };
    date = DateTime(year, 1, 6, 12);

    Duration nextSunday =
        Duration(days: ((7 - date.weekday % DateTime.sunday)));
    date = date.add(nextSunday);
    sundaysPostEpiphaniam.forEach((element, value) {
      if (getDayAtDate(date).containsFeast("Dominica in Septuagesima")) {
        return;
      }
      addFeast(
          date, Feast(element, value, FeastClass.secondClass, Color.green));
      date = date.add(const Duration(days: 7));
    });
  }

  void polishCalendar() {
    addFirstThursdays();
    addFirstFridays();
    addFirstSaturdays();
    addSaturdaysOfOurLady();
  }

  void addFirstFridays() {
    Feast SCJC = Feast("Sacratissimi Cordis Jesu Christi",
        "Most Holy Name of Jesus", FeastClass.thirdClass, Color.white);
    addCyclicFeast(SCJC, DateTime.friday);
  }

  void addFirstThursdays() {
    Feast JCSAC = Feast("Jesu Christi Summi et Aeterni Sacerdoti",
        "Jesus Christ the High Priest", FeastClass.thirdClass, Color.white);
    addCyclicFeast(JCSAC, DateTime.thursday);
  }

  void addFirstSaturdays() {
    Feast ICBMV = Feast("Immaculati Cordis Beatae Mariae Virginis",
        "Immaculate Heart of Mary", FeastClass.thirdClass, Color.white);
    addCyclicFeast(ICBMV, DateTime.saturday);
  }

  void addCyclicFeast(Feast data, int dayOfTheWeek) {
    for (int i = 1; i < 13; i++) {
      DateTime date = DateTime(year, i, 1, 12, 0, 0);
      var nearestSaturday =
          Duration(days: (dayOfTheWeek - (date.weekday % DateTime.sunday)));
      date = date.add(nearestSaturday);
      Day day = getDayAtDate(date);
      if (!day.containsFeastOfClass(FeastClass.firstClass) &&
          !day.containsFeastOfClass(FeastClass.secondClass) &&
          !day.containsFeast("Quadragesim") &&
          !day.containsFeast("Adventus")) {
        addFeast(date, data);
      }
    }
  }

  void addSaturdaysOfOurLady() {
    var diff = const Duration(days: 7);
    DateTime date = DateTime(year, 1, 1, 12, 0, 0);
    var nearestSaturday =
        Duration(days: (DateTime.saturday - (date.weekday % DateTime.sunday)));
    date = date.add(nearestSaturday);
    DateTime end = DateTime(year, 12, 31, 0, 0);

    Feast SMS = Feast("Sancta Maria Sabbato", "Our Lady on Saturday",
        FeastClass.fourthClass, Color.white);
    while (date.compareTo(end) <= 0) {
      Day day = getDayAtDate(date);
      if (!day.containsFeastOfClass(FeastClass.firstClass) &&
          !day.containsFeastOfClass(FeastClass.secondClass) &&
          !day.containsFeastOfClass(FeastClass.thirdClass)) {
        addFeast(date, SMS);
      }
      date = date.add(diff);
    }
  }

  DateTime easter;
  int year;
  List<Day> days;

  void addFeriasOfAdvent() {
    DateTime start = getDateOfFeast("Dominica I Adventus");
    DateTime end = DateTime(year, 12, 17, 12);
    while (start.compareTo(end) < 0) {
      start = start.add(const Duration(days: 1));
      addFeast(
          start,
          Feast("Feria Adventus", "Feria of Advent", FeastClass.thirdClass,
              Color.purple));
    }
  }
}
