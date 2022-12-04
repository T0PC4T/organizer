import 'dart:math';

import 'package:flutter/material.dart';

const OffWhite = Color.fromARGB(255, 245, 245, 245);

@immutable
class PrayersScreen extends StatelessWidget {
  const PrayersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar (Preview)'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          DateTime now = DateTime.now();
          DateTime newDate = DateTime(now.year, now.month, now.day + index);
          return PrayerCalendarDay(
            date: newDate,
          );
        },
      ),
    );
  }
}

class PrayerCalendarDay extends StatelessWidget {
  final DateTime date;
  const PrayerCalendarDay({
    Key? key,
    required this.date,
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
                const Flexible(
                  flex: 8,
                  child: FeastPieceWidget(),
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
  const FeastPieceWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final r = Random();
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Card(
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
              Container(
                padding: const EdgeInsets.all(12),
                color: [
                  Colors.red,
                  Colors.green,
                  Colors.grey,
                  Colors.purple
                ][r.nextInt(4)],
                child: Row(children: const [
                  Text("The Feast of Feast"),
                  Text("II Class"),
                ]),
              )
            ],
          ),
        ),
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
    return Container(
      height: 100,
      width: double.infinity,
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
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            months[date.month],
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class CalendarHeading extends StatelessWidget {
  const CalendarHeading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      width: double.infinity,
      height: 200,
      child: const SizedBox.expand(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Preview:\nThis is a preview of what the liturgical calendar would generate.",
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
