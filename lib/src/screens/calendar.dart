import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:organizer/src/services/liturgical_calendar/calendar.dart';
import 'package:organizer/src/services/liturgical_calendar/liturgical_calendar.dart';
import 'package:organizer/src/widgets/util.dart';

import '../widgets/cards.dart';
import '../widgets/fastTable.dart';

const dataRowNames = <String>[
  "date",
  "englishName",
  "class",
  "commemorations",
];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  int month = DateTime.now().month;
  int year = DateTime.now().year;
  Calendar? calendar;
  // This considers the data as days which have options.
  List<List<Map<String, String>>>? data;

  // This is the data just considered as options.
  List<List<String>>? simpleData;

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
            option["date"] as String,
            option["englishName"] as String,
            option["class"] as String,
            option["commemorations"] as String,
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
          lines.add("Date,Feast,Class,Commemoration");
          for (var day in simpleData!) {
            List<String> line = [];
            line.addAll(day.map((e) => e.replaceAll(",", "&comma;")));
            lines.add(line.join(","));
          }
          final csv = lines.join("\r\n");
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
          FastDataTableWidget(
            textScaler: 5,
            rows: simpleData!,
            onTap: (x, y) async {
              final value = await showDialog(
                  context: context,
                  builder: (ctx) {
                    return ChangeStringModalWidget(
                        currentValue: simpleData![y][x]);
                  });

              if (value is String && context.mounted) {
                setState(() {
                  simpleData![y][x] = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

// class CalendarRowWidget extends StatelessWidget {
//   static const dataRowNames = <String>[
//     "date",
//     "englishName",
//     "class",
//     "commemorations",
//   ];
//   final Map<String, String> item;
//   final bool editable;
//   final int childIndex;
//   const CalendarRowWidget({
//     super.key,
//     required this.item,
//     this.editable = true,
//     this.childIndex = 0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Container(
//       height: 40,
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: const BoxDecoration(
//         border: Border.symmetric(
//             // horizontal: BorderSide(width: 0.5),
//             ),
//       ),
//       child: Row(children: [
//         for (var rowName in dataRowNames)
//           GestureDetector(
//             onTap: () async {
//               if (editable) {
//                 final value = await showDialog(
//                     context: context,
//                     builder: (ctx) {
//                       return ChangeStringModalWidget(
//                           currentValue: item[rowName] ?? "ERROR");
//                     });

//                 if (value is String && context.mounted) {
//                   CalendarScreenState.of(context)
//                       ?.editData(childIndex, item, rowName, value);
//                 }
//               }
//             },
//             child: Container(
//               width: (size.width - 22) / dataRowNames.length,
//               height: double.infinity,
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: !editable
//                     ? themePrimary
//                     : (childIndex % 2 == 0)
//                         ? Colors.white
//                         : const Color.fromARGB(255, 213, 236, 255),
//                 border: const Border.symmetric(
//                   vertical: BorderSide(width: 1),
//                 ),
//               ),
//               child: Text(
//                 item[rowName] ?? "ERROR",
//                 style: TextStyle(color: editable ? Colors.black : Colors.white),
//               ),
//             ),
//           )
//       ]),
//     );
//   }
// }

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
