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
    if (originalDay.containsFeast("Nativitat")) {
      return; //if vigil of Christmas or Christmas don't translate feast because it is Sunday of Advent
    }
    Day day = getDayIfFeastTransfered(originalDay, feast);
    day.addFeast(feast);
    if (feast.latinName.contains("Quattuor Temporum Quadr")) {
      day.removeFeastWithName("Feria Quadr");
    }
  }

  Day getDayIfFeastTransfered(Day originalDay, Feast feast) {
    //Trasfer of the Feast in case two First Class Feast occur on the same day
    if (originalDay.date.weekday == DateTime.sunday &&
        feast.latinName.contains("Dominica")) {
      return originalDay;
    }
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

  FeastDayData formatDataJSON(
      DateTime date, FeastWithCommemorationsData jsonData,
      {bool alternative = false}) {
    return (
      date: alternative
          ? ""
          : '${Calendar.weekdays[date.weekday]}, ${getOrdinalSuffix(date.day)}',
      latinName: jsonData.latinName,
      englishName: jsonData.englishName,
      color: jsonData.color,
      feastClass: jsonData.feastClass.replaceAll(". Class", ""),
      commemorations:
          jsonData.commemorations.map((e) => e.englishName).join("<br>"),
      readingID: jsonData.readingID
    );
  }

  FeastWithCommemorationsData swapMainFeastWithAlternative(
      FeastWithCommemorationsData feastData, int altInd) {
    FeastData feast = feastData.alternatives[altInd];
    FeastData mainFeast = (
      latinName: feastData.latinName,
      englishName: feastData.englishName,
      feastClass: feastData.feastClass,
      color: feastData.color,
      readingID: feastData.readingID
    );
    var comms = feastData.commemorations;
    var alts = feastData.alternatives;
    alts[altInd] = mainFeast;
    return makeFeastWithCommemorations(feast, comms, alts);
  }

  Iterable<List<FeastDayData>> getMonthIterable(int month) sync* {
    for (var element in days.where((day) => day.date.month == month)) {
      FeastWithCommemorationsData jsonData =
          element.formatFeasts().values.first;
      if (jsonData.alternatives.isEmpty) {
        List<FeastDayData> a = [formatDataJSON(element.date, jsonData)];
        yield a;
      } else {
        List<FeastData> comms = jsonData.commemorations;
        List<FeastData> alts = jsonData.alternatives;
        comms.addAll(alts.where((i) =>
            !isFeriaVotiveMassOrUSProper(i.latinName) &&
            !isProAliquibusLocis(i.latinName)));
        comms.removeWhere((element) => element.latinName == jsonData.latinName);
        List<FeastDayData> a = [
          formatDataJSON(
              element.date,
              makeFeastWithCommemorations((
                latinName: jsonData.latinName,
                englishName: jsonData.englishName,
                color: jsonData.color,
                feastClass: jsonData.feastClass,
                readingID: jsonData.readingID
              ), comms, alts))
        ];
        for (int i = 0; i < (jsonData.alternatives).length; i++) {
          FeastWithCommemorationsData fData =
              swapMainFeastWithAlternative(jsonData, i);
          Set<FeastData> comms = fData.commemorations.toSet();
          Set<FeastData> alts = fData.alternatives.toSet();
          comms.addAll(alts.where((i) =>
              !isFeriaVotiveMassOrUSProper(i.latinName) &&
              !isProAliquibusLocis(i.latinName)));
          comms.removeWhere((element) => element.latinName == fData.latinName);
          a.add(formatDataJSON(
              element.date,
              makeFeastWithCommemorations((
                latinName: fData.latinName,
                englishName: fData.englishName,
                color: fData.color,
                feastClass: fData.feastClass,
                readingID: fData.readingID
              ), comms.toList(), alts.toList()),
              alternative: true));
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

    DateTime date = DateTime(year, 6, 29);
    int dayOfTheWeek = date.weekday;
    if (dayOfTheWeek != DateTime.sunday) {
      date = date.add(Duration(days: 7 - dayOfTheWeek));
      addFeast(
          date,
          Feast(
              "(USA)Externa Sollemnitas Ss. Petri et Pauli",
              "(USA)External Solemnity of Ss. Peter and Paul",
              FeastClass.secondClass,
              FeastColor.red,
              "Feast_of_Ss_Peter_and_Paul"));
    }

    date = DateTime(year, 10, 1);
    dayOfTheWeek = date.weekday;
    date = date.add(Duration(days: 7 - dayOfTheWeek));
    addFeast(
        date,
        Feast(
            "(USA)Externa Sollemnitas Dominae Nostrae de Rosario",
            "(USA)External Solemnity of Our Lady of the Rosary",
            FeastClass.secondClass,
            FeastColor.white,
            "Our_Lady_of_the_Rosary"));
  }

  void saveCalendar() async {
    final File file = File('calendar.json');
    await file.writeAsString(json.encode(formatOutput()));
  }

  Map<String, dynamic> formatOutput() {
    Map<String, dynamic> ret = <String, dynamic>{};
    for (var element in days) {
      ret.addEntries(element.formatFeasts().entries);
    }
    return ret;
  }

  void addMovableFeasts() {
    Feast SSNJ = Feast("Sanctissimi Nominis Jesu", "The Holy Name of Jesus",
        FeastClass.secondClass, FeastColor.white, ""); //TODO: add readings

    Feast SGVPC = Feast(
        "S. Gabrielis a Virgine Pardolente Confessoris",
        "St. Gabriel of Our Lady of Sorrows, Confessor",
        FeastClass.thirdClass,
        FeastColor.white,
        ""); //TODO: add readings

    Feast SMA = Feast("S. Mathiae Apostoli", "St. Matthias, Apostle",
        FeastClass.secondClass, FeastColor.red, ""); //TODO: add readings

    var d = DateTime(year, 1, 1).weekday;
    if (d == 1 || d == 2 || d == 7) {
      addFeast(DateTime(year, 1, 2, 12), SSNJ);
    } else {
      addFeast(DateTime(year, 1, 7 - d + 1, 12), SSNJ);
    }
    if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
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
        FeastColor.white,
        "Sunday_After_Christmas");

    var dd = DateTime(year, 12, 25);
    d = dd.weekday % 7;
    if (d != 0) {
      dd = dd.add(Duration(days: 7 - d));
      getDayAtDate(dd)
          .feasts
          .removeWhere((element) => element.englishName.contains("Christmas"));
      addFeast(dd, DION);
    }

    Feast DNJCR = Feast("Domini Nostri Jesu Christi Regi", "Christ the King",
        FeastClass.firstClass, FeastColor.white, "Christ_the_King");

    d = DateTime(year, 10, 31).weekday % 7;
    DateTime date = DateTime(year, 10, 31 - d, 12);
    addFeast(date, DNJCR);

    var diff = const Duration(days: 9);
    DateTime xx =
        DateTime.parse("$year-${easterDate(year)} 12:00:00").subtract(diff);

    addFeast(
        xx,
        Feast("Septem Dolorum BMV", "Seven Dolours of Our Lady",
            FeastClass.thirdClass, FeastColor.purple, "")); //TODO: add readings

    d = DateTime(year, 12, 25).weekday;

    diff = const Duration(days: 7);
    xx = DateTime(year, 12, 25 - d, 12);

    for (var i = 0; i < 7; i++) {
      var numDays = Duration(days: i);
      DateTime date = DateTime(year, 12, 17, 12).add(numDays);
      Feast FMA = Feast("Feria Maior Adventus", "Major Feria of Advent",
          FeastClass.secondClass, FeastColor.purple, "");

      if (!getDayAtDate(date)
          .feasts
          .any((element) => element.latinName.contains("Quattuor Temp"))) {
        addFeast(date, FMA);
      }
    }

    d = DateTime(year, 1, 6).weekday % 7;
    date = DateTime(year, 1, 13 - d, 12);

    addFeast(
        date,
        Feast(
            "Sanctae Familiae Jesu Mariae Joseph",
            "Holy Family Jesus, Mary, and Joseph",
            FeastClass.firstClass,
            FeastColor.white,
            "Holy_Family"));
  }

  DateTime getDateOfFeast(String name) {
    return days.firstWhere((element) => element.containsFeast(name)).date;
  }

  void addMissingSundays() {
    Map<String, dynamic> sundays = {
      "Dominica IV Adventus": {
        "eng": "Fourth Sunday of Advent",
        "color": FeastColor.purple,
        "class": FeastClass.firstClass,
        "readingID": "4th_Sunday_of_Advent"
      },
      "Dominica III Adventus": {
        "eng": "Third Sunday of Advent",
        "color": FeastColor.purple,
        "class": FeastClass.firstClass,
        "readingID": "3rd_Sunday_of_Advent"
      },
      "Dominica II Adventus": {
        "eng": "Second Sunday of Advent",
        "color": FeastColor.purple,
        "class": FeastClass.firstClass,
        "readingID": "2nd_Sunday_of_Advent"
      },
      "Dominica I Adventus": {
        "eng": "First Sunday of Advent",
        "color": FeastColor.purple,
        "class": FeastClass.firstClass,
        "readingID": "1st_Sunday_of_Advent"
      },
      "Dominica XXIV et Ultima post Pentecosten": {
        "eng": "Twenty fourth and last Sunday after the Pentecost",
        "color": FeastColor.green,
        "class": FeastClass.secondClass,
        "readingID": "24th_and_Last_Sunday_after_Pentecost"
      },
      "Dominica VI Post Epiphaniam": {
        "eng": "Resumed Sixth Sunday after the Epiphany",
        "color": FeastColor.green,
        "class": FeastClass.secondClass,
        "readingID": "Resumed_6th_Sunday_After_Epiphany"
      },
      "Dominica V Post Epiphaniam": {
        "eng": "Resumed Fifth Sunday after the Epiphany",
        "color": FeastColor.green,
        "class": FeastClass.secondClass,
        "readingID": "Resumed_5th_Sunday_After_Epiphany"
      },
      "Dominica IV Post Epiphaniam": {
        "eng": "Resumed Fourth Sunday after the Epiphany",
        "color": FeastColor.green,
        "class": FeastClass.secondClass,
        "readingID": "Resumed_4th_Sunday_After_Epiphany"
      },
      "Dominica III Post Epiphaniam": {
        "eng": "Resumed Third Sunday after the Epiphany",
        "color": FeastColor.green,
        "class": FeastClass.secondClass,
        "readingID": "Resumed_3rd_Sunday_After_Epiphany"
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
          date,
          Feast(element, value['eng'], value['class'], value['color'],
              value['readingID']));

      if (element.startsWith("Dominica III Adventus")) {
        var d = date.add(const Duration(days: 3));

        Feast FQT = Feast(
            "Feria IV Quattuor Temporum Adventus",
            "Ember Wednesday of Advent",
            FeastClass.secondClass,
            FeastColor.purple,
            ""); //TODO: add readings

        addFeast(d, FQT);
        d = d.add(const Duration(days: 2));

        FQT = Feast(
            "Feria VI Quattuor Temporum Adventus",
            "Ember Friday of Advent",
            FeastClass.secondClass,
            FeastColor.purple,
            ""); //TODO: add readings
        addFeast(d, FQT);
        d = d.add(const Duration(days: 1));
        FQT = Feast(
            "Sabbato Quattuor Temporum Adventus",
            "Ember Saturday of Advent",
            FeastClass.secondClass,
            FeastColor.purple,
            ""); //TODO: add readings
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
              FeastColor.purple,
              "")); //TODO: add readings
    }
    date = date.add(const Duration(days: 2));
    if (date.day != 21) {
      addFeast(
          date,
          Feast(
              "Feria VI Quattuor Temporum Septembris",
              "Ember Friday in September",
              FeastClass.secondClass,
              FeastColor.purple,
              "")); //TODO: add readings
    }
    date = date.add(const Duration(days: 1));
    if (date.day != 21) {
      addFeast(
          date,
          Feast(
              "Sabbato Quattuor Temporum Septembris",
              "Ember Saturday in September",
              FeastClass.secondClass,
              FeastColor.purple,
              "")); //TODO: add readings
    }

    Map<String, (String, String)> sundaysPostEpiphaniam = {
      "Dominica I Post Epiphaniam": (
        "First Sunday after the Epiphany",
        "1st_Sunday_after_Epiphany"
      ),
      "Dominica II Post Epiphaniam": (
        "Second Sunday after the Epiphany",
        "2nd_Sunday_after_Epiphany"
      ),
      "Dominica III Post Epiphaniam": (
        "Third Sunday after the Epiphany",
        "3rd_Sunday_after_Epiphany"
      ),
      "Dominica IV Post Epiphaniam": (
        "Fourth Sunday after the Epiphany",
        "4th_Sunday_after_Epiphany"
      ),
      "Dominica V Post Epiphaniam": (
        "Fifth Sunday after the Epiphany",
        "5th_Sunday_after_Epiphany"
      ),
      "Dominica VI Post Epiphaniam": (
        "Sixth Sunday after the Epiphany",
        "6th_Sunday_after_Epiphany"
      )
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
          date,
          Feast(element, value.$1, FeastClass.secondClass, FeastColor.green,
              value.$2));
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
    Feast fSCJC = Feast("Sacratissimi Cordis Jesu Christi",
        "Sacred Heart of Jesus", FeastClass.thirdClass, FeastColor.white, "");
    addCyclicFeast(fSCJC, DateTime.friday);
  }

  void addFirstThursdays() {
    Feast fJCSAC = Feast(
        "Jesu Christi Summi et Aeterni Sacerdoti",
        "Jesus Christ the High Priest",
        FeastClass.thirdClass,
        FeastColor.white,
        "Jesus_Christ_Supreme_and_Eternal_Priest");
    addCyclicFeast(fJCSAC, DateTime.thursday);
  }

  void addFirstSaturdays() {
    Feast fICBMV = Feast(
        "Immaculati Cordis Beatae Mariae Virginis",
        "Immaculate Heart of Mary",
        FeastClass.thirdClass,
        FeastColor.white,
        "");
    addCyclicFeast(fICBMV, DateTime.saturday);
  }

  void addCyclicFeast(Feast data, int dayOfTheWeek) {
    for (int i = 1; i < 13; i++) {
      DateTime date = DateTime(year, i, 1, 12, 0, 0);
      var nearestDesiredDayOfTheWeek =
          dayOfTheWeek - (date.weekday % DateTime.sunday);
      if (nearestDesiredDayOfTheWeek < 0) nearestDesiredDayOfTheWeek += 7;
      date = date.add(Duration(days: nearestDesiredDayOfTheWeek));
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
        FeastClass.fourthClass, FeastColor.white, ""); //TODO: add readings
    while (date.compareTo(end) <= 0) {
      Day day = getDayAtDate(date);
      if (!day.containsFeastOfClass(FeastClass.firstClass) &&
          !day.containsFeastOfClass(FeastClass.secondClass) &&
          (!day.containsFeastOfClass(FeastClass.thirdClass) ||
              day.getFeastsOfClass(FeastClass.thirdClass).every((element) =>
                  isFeriaVotiveMassOrUSProper(element.latinName)))) {
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
              FeastColor.purple, "")); //TODO: add readings
    }
  }
}
