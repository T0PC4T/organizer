import 'dart:math';

import 'package:flutter/material.dart';

const OffWhite = Color.fromARGB(255, 245, 245, 245);

@immutable
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  String generateRandomName() {
    String name = "";
    String alphabet = "abcdefghijklmnopqrstuvwxyz";
    final r = Random();
    for (var i = 0; i < r.nextInt(6) + 4; i++) {
      name = "$name${alphabet[r.nextInt(24)]}";
    }

    return name;
  }

  Map<String, dynamic> generateData(DateTime date) {
    final r = Random();
    Map<String, dynamic> genData = {};
    for (var i = 1; i < 30; i++) {
      genData["$i-${date.month}"] = {
        "name": generateRandomName(),
        "color": ["red", "green", "white", "violet"][r.nextInt(4)],
        "class": "3rd Class",
        "commemoration": [
          for (var j = 0; j < r.nextInt(3); j++)
            {
              "name": generateRandomName(),
              "color": ["red", "green", "white", "violet"][r.nextInt(4)],
              "class": "3rd Class",
            }
        ],
      };
    }
    return genData;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime generateDate = DateTime(now.year, now.month, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar (Preview)'),
      ),
      body: ListView.builder(
        itemCount: 28,
        itemBuilder: (context, index) {
          DateTime newDate = DateTime(
              generateDate.year, generateDate.month, generateDate.day + index);
          return LiturgicalDay(
            date: newDate,
            data: generateData(generateDate),
          );
        },
      ),
    );
  }
}

class LiturgicalDay extends StatelessWidget {
  final DateTime date;
  final Map<String, dynamic> data;
  const LiturgicalDay({
    Key? key,
    required this.date,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  child: DatePieceWidget(
                    date: date,
                    feasts: const [],
                  ),
                ),
                Flexible(
                  flex: 8,
                  child: FeastPieceWidget(
                    data: data["${date.day}-${date.month}"],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeastPieceWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const FeastPieceWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final r = Random();
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Card(
      elevation: 20,
      child: DefaultTextStyle(
        style: TextStyle(
          color: onPrimary,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: onPrimary,
          constraints:
              const BoxConstraints(minHeight: 120, minWidth: double.infinity),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FeastRow(data: data),
              const Divider(),
              const Text(
                "Commemorations:",
                style: TextStyle(color: Colors.black),
              ),
              for (var comm in data["commemoration"]) FeastRow(data: comm)
            ],
          ),
        ),
      ),
    );
  }
}

class FeastRow extends StatelessWidget {
  static const Map stringToColor = {
    "red": Colors.red,
    "violet": Colors.purple,
    "white": Color.fromARGB(255, 255, 245, 224),
    "green": Colors.green,
  };

  const FeastRow({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: stringToColor[data["color"]],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(data["name"]),
          Text(data["class"]),
        ],
      ),
    );
  }
}

class DatePieceWidget extends StatelessWidget {
  static final List<String> months = [
    "",
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC"
  ];

  static final List<String> days = [
    "",
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT",
    "SUN",
  ];

  final List<Map<String, dynamic>> feasts;
  final DateTime date;
  const DatePieceWidget({
    super.key,
    required this.date,
    required this.feasts,
  });

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    bool isToday = today.day == date.day && today.month == date.month;
    bool isSunday = date.weekday == 7;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: PhysicalModel(
        elevation: 20,
        color: Colors.black,
        shape: BoxShape.circle,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: isToday
                ? Colors.green[200]
                : isSunday
                    ? Colors.amber[300]
                    : OffWhite,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                days[date.weekday],
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                date.day < 10 ? "0${date.day}" : date.day.toString(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                months[date.month],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
