import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:organizer/src/services/liturgical_calendar/calendar.dart';
import 'package:organizer/src/services/liturgical_calendar/liturgical_calendar.dart';
import 'package:organizer/src/widgets/cards.dart';
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
  List<List<String>>? data;

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
    final keys = [
      "date",
      "englishName",
      "class",
      "commemorations",
    ];
    data = calendar
        ?.getMonthIterable(month)
        .map((e) => <String>[
              for (var key in keys) e[0][key]!
            ]) // TODO: iterate over the feast days, not get just the first one.
        .toList();
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

  void editData(List<String> row, itemIndex, newValue) {
    setState(() {
      data![data!.indexOf(row)][itemIndex] = newValue;
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
          String csv =
              "Date,Feast,Class,Commemoration\r\n${data?.map((e) => e.map((e) => e.replaceAll(",", "&comma;")).join(",")).join("\r\n")}";

          download("LiturgicalCalendar${monthNames[month]}$year.csv", csv);
        },
        child: const Icon(Icons.download),
      ),
      body: SmoothListView(
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
          const RowWidget(
            items: ["Date", "English", "Class", "Commemorations"],
            editable: false,
          ),
          for (var datum in data!)
            RowWidget(
              items: datum,
            ),
        ],
      ),
    );
  }
}

class RowWidget extends StatelessWidget {
  final List<String> items;
  final bool editable;
  const RowWidget({super.key, required this.items, this.editable = true});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 60,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(width: 1),
        ),
      ),
      child: Row(children: [
        for (var item in items)
          GestureDetector(
            onTap: () async {
              if (editable) {
                final value = await showDialog(
                    context: context,
                    builder: (ctx) {
                      return ChangeStringModalWidget(currentValue: item);
                    });

                if (value is String && context.mounted) {
                  CalendarScreenState.of(context)
                      ?.editData(items, items.indexOf(item), value);
                }
              }
            },
            child: Container(
              width: (size.width - 22) / items.length,
              height: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: editable ? Colors.white : Theme.of(context).primaryColor,
                border: const Border.symmetric(
                  vertical: BorderSide(width: 1),
                ),
              ),
              child: Text(
                item,
                style: TextStyle(color: editable ? Colors.black : Colors.white),
              ),
            ),
          )
      ]),
    );
  }
}

class ChangeStringModalWidget extends StatefulWidget {
  final String currentValue;

  const ChangeStringModalWidget({
    super.key,
    required this.currentValue,
  });

  static GlobalKey textKey = GlobalKey();

  @override
  State<ChangeStringModalWidget> createState() =>
      _ChangeStringModalWidgetState();
}

class _ChangeStringModalWidgetState extends State<ChangeStringModalWidget> {
  TextEditingController? controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.currentValue);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalCard(
        title: const Text("Edit Liturgical Calendar"),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: TextField(
                controller: controller,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, controller?.value.text);
                },
                child: const Text("Submit"))
          ],
        ));
  }
}
