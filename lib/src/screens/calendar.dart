import 'package:flutter/material.dart';
import 'package:organizer/src/services/liturgical_calendar/calendar.dart';
import 'package:organizer/src/services/liturgical_calendar/liturgical_calendar.dart';
import 'package:organizer/src/widgets/cards.dart';
import 'package:organizer/src/widgets/util.dart';

@immutable
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liturgical Calendar'),
      ),
      body: const CalendarTable(),
    );
  }
}

class CalendarTable extends StatefulWidget {
  const CalendarTable({super.key});

  @override
  State<CalendarTable> createState() => CalendarTableState();
}

class CalendarTableState extends State<CalendarTable> {
  int month = DateTime.now().month;
  int year = DateTime.now().year;
  Calendar? calendar;
  List<Map<String, String>>? data;

  @override
  void initState() {
    super.initState();
    calendar = getLiturgicalCalendar();
    data = calendar?.getMonthIterable(month).toList();
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
      data = calendar?.getMonthIterable(month).toList();
    });
  }

  void editData() {}

  @override
  Widget build(BuildContext context) {
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
        const RowWidget(
          items: ["Date", "English", "Color", "Class", "Commemorations"],
          editable: false,
        ),
        for (var datum in data!)
          RowWidget(
            items: [
              datum["date"] as String,
              datum["englishName"] as String,
              datum["color"] as String,
              datum["class"] as String,
              datum["commemorations"] as String,
            ],
          ),
      ],
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
                  Navigator.pop(context, controller?.value);
                },
                child: const Text("Submit"))
          ],
        ));
  }
}
