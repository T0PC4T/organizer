import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:organizer/src/services/liturgical_calendar/calendar.dart';
import 'package:organizer/src/services/liturgical_calendar/day.dart';
import 'package:organizer/src/services/liturgical_calendar/liturgical_calendar.dart';
import 'package:organizer/src/widgets/util.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  int month = DateTime.now().month;
  int year = DateTime.now().year;
  Calendar? calendar;
  List<List<FeastDayData>>? data;

  // This is the data just considered as options.
  List<List<String>>? simpleData;

  String colorToDiv(String color) {
    return "<div style='display:block;height:20px;width:20px;border:solid black 3px;background-color:$color;border-radius:10px'></div>";
  }

  @override
  void initState() {
    super.initState();
    calendar = getLiturgicalCalendar();
    setDataFromCalendar();
  }

  void download(filename, text) {
    var element = html.document.createElement('a');
    element.setAttribute(
        'href', 'data:text/plain;charset=utf-8,${Uri.encodeFull(text)}');
    element.setAttribute('download', filename);

    element.style.display = 'none';
    html.document.body?.append(element);

    element.click();
    element.remove();
  }

  setDataFromCalendar() {
    data = calendar?.getMonthIterable(month).toList();

    simpleData = [
      for (var i = 0; i < data!.length; i++)
        for (var option in data![i])
          [
            option.date,
            option.englishName,
            option.feastClass,
            option.commemorations,
            colorToDiv(option.color),
          ]
    ];
  }

  static const monthNames = [
    "-",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  changeMonth(int diff) {
    setState(() {
      month += diff;
      if (month == 0) {
        year--;
        month = 12;
        calendar = getLiturgicalCalendar(year);
      } else if (month == 13) {
        year++;
        month = 1;
        calendar = getLiturgicalCalendar(year);
      }
      setDataFromCalendar();
    });
  }

  static CalendarScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<CalendarScreenState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liturgical Calendar'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<String> lines = [];
          lines.add("Date,Feast,Class,Commemoration,Color");
          for (var day in simpleData!) {
            List<String> line = [];
            line.addAll(day.map<String>((e) => e.replaceAll(",", "&comma;")));
            lines.add(line.join(","));
          }
          final csv = lines.join("\r\n");
          download("LiturgicalCalendar${monthNames[month]}$year.csv", csv);
        },
        child: const Icon(Icons.download),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SmoothListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      changeMonth(-1);
                    },
                    icon: const Icon(Icons.arrow_back)),
                Text(
                  "${monthNames[month]} $year",
                  style: const TextStyle(fontSize: 42),
                ),
                IconButton(
                    onPressed: () {
                      changeMonth(1);
                    },
                    icon: const Icon(Icons.arrow_forward)),
              ],
            ),
            Row(
              children: [
                for (var value in [
                  "Date",
                  "Feast",
                  "Class",
                  "Commemoration",
                  "Color"
                ])
                  Container(
                    width: constraints.maxWidth / 5,
                    height: 120,
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      softWrap: true,
                    ),
                  ),
              ],
            ),
            for (var row in simpleData!)
              Row(
                children: [
                  for (var cell in row)
                    Container(
                      width: constraints.maxWidth / row.length,
                      height: 120,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.centerLeft,
                      color: simpleData!.indexOf(row).isEven
                          ? const Color.fromARGB(255, 220, 244, 255)
                          : Colors.white,
                      child: Text(
                        cell,
                        softWrap: true,
                      ),
                    ),
                ],
              ),
          ],
        );
      }),
    );
  }
}
