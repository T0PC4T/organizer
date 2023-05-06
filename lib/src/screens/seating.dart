import 'dart:html' as html;
import 'dart:math';

import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/pdf_gen.dart';
import '../services/people_service.dart';
import '../services/seating_data.dart';
import '../widgets/cards.dart';
import '../widgets/people.dart';

class SeatingPage extends StatelessWidget {
  static GlobalKey<SeatingListingState> seatKey =
      GlobalKey<SeatingListingState>();
  const SeatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final peopleService =
        FirestoreService.serve(context, FServices.people) as PeopleService;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Seating'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'Download map',
              onPressed: () {
                html.window
                    .open("/assets/assets/files/seatingMap.pdf", 'SeatMap.pdf');
              },
            ),
          ],
        ),
        floatingActionButton: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250, maxWidth: 300),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton.extended(
                  key: const ValueKey(1),
                  heroTag: const ValueKey(1),
                  onPressed: () async {
                    final randomSeed = await showDialog<int>(
                        context: context,
                        builder: (context) => const RandomSeedModalWidget());
                    if (randomSeed != null) {
                      seatKey.currentState
                          ?.generate(randomSeed, peopleService.data!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text("Invalid random seed"),
                      ));
                    }
                  },
                  label: const Text('Generate'),
                  icon: const Icon(Icons.settings),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton.extended(
                  key: const ValueKey(2),
                  heroTag: const ValueKey(2),
                  onPressed: () {
                    seatKey.currentState?.reset();
                  },
                  label: const Text('Clear all'),
                  icon: const Icon(Icons.clear),
                  backgroundColor: Colors.red[700],
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton.extended(
                  key: const ValueKey(3),
                  heroTag: const ValueKey(3),
                  onPressed: () {
                    generateSeetingPdf(
                        "Seating Chart", seatKey.currentState!.tableData);
                    // Navigator.of(context).push(

                    // MaterialPageRoute(
                    //   builder: (context) => Container(
                    //     build: (format) => generateSeetingPdf(
                    //         "Seating Chart", seatKey.currentState!.tableData),
                    //   ),
                    // ),
                    // );
                  },
                  label: const Text('Download'),
                  icon: const Icon(Icons.download),
                  backgroundColor: Colors.green[700],
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        body: SeatingListing(
          key: seatKey,
        ));
  }
}

class RandomSeedModalWidget extends StatefulWidget {
  const RandomSeedModalWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<RandomSeedModalWidget> createState() => _RandomSeedModalWidgetState();
}

class _RandomSeedModalWidgetState extends State<RandomSeedModalWidget> {
  String textValue = "";

  @override
  Widget build(BuildContext context) {
    return ModalCard(
        title: const Text("Random seed"),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              onChanged: (value) {
                textValue = value;
              },
            ),
            ElevatedButton(
                onPressed: () {
                  int i = 0;
                  try {
                    i = int.parse(textValue);
                  } catch (e) {
                    i = Random().nextInt(1000000);
                  }
                  Navigator.pop(context, i);
                },
                child: const Text("Submit"))
          ],
        ));
  }
}

class SeatingListing extends StatefulWidget {
  const SeatingListing({super.key});

  @override
  State<SeatingListing> createState() => SeatingListingState();
}

class SeatingListingState extends State<SeatingListing> {
  List<TableData> tableData;
  SeatingListingState() : tableData = TableData.getTables();

  @override
  void initState() {
    super.initState();
  }

  reset() {
    setState(() {
      for (var element in tableData) {
        element.data
            .removeWhere((key, value) => !["name", "filter"].contains(key));
      }
    });
  }

  bool fitsFilter(TableData t, Map<String, dynamic> p) {
    return (t.filter).contains(p["year"]);
  }

  void generate(int randomSeed, Map<String, Map<String, dynamic>> peopleData) {
    final localPeopleData = List<Map<String, dynamic>>.from(peopleData.values);
    final scopedTableData = TableData.fromTableData(tableData);
    localPeopleData.shuffle(Random(randomSeed));
    localPeopleData.shuffle();
    List<String> alreadyAssigned = [];

    // ? Remove people who have already been placed
    for (var table in scopedTableData) {
      for (var seat in table.seats) {
        if (table.seminarianSeat(seat)) {
          alreadyAssigned.addAll(table.seatPeople(seat));
        }
      }
    }
    localPeopleData
        .removeWhere((person) => alreadyAssigned.contains(person.name));

    // ? Remove people on waiter crew
    localPeopleData
        .removeWhere((person) => person["jobs"].contains(Jobs.waiter.name));

    // ? Remove people with supper crew
    final supperDishCrew = localPeopleData
        .where((element) => element["jobs"].contains(Jobs.supperDishCrew.name))
        .toList();

    localPeopleData.removeWhere(
        (element) => element["jobs"].contains(Jobs.supperDishCrew.name));

    while (localPeopleData.isNotEmpty || supperDishCrew.isNotEmpty) {
      late Map<String, dynamic> curPerson;
      if (localPeopleData.isNotEmpty) {
        curPerson = localPeopleData.removeLast();
      } else {
        curPerson = supperDishCrew.removeLast();
      }

      () {
        for (var table in scopedTableData) {
          for (var seat in table.seats) {
            if (table.seatOccupied(seat)) {
              continue;
            }
            if (fitsFilter(table, curPerson)) {
              table.addPerson(seat, curPerson.name);

              // Dish Crew Check
              if (curPerson["jobs"].contains(Jobs.lunchDishCrew.name)) {
                final i = supperDishCrew
                    .indexWhere((element) => fitsFilter(table, element));
                if (i != -1) {
                  table.addPerson(seat, supperDishCrew[i].name);
                  supperDishCrew.removeAt(i);
                }
              }
              // End Dish Crew Check

              return;
            }
          }
        }
      }();
    }

    setState(() {
      tableData = scopedTableData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      scrollDirection: Axis.vertical,
      children: [
        for (TableData table in tableData) ...[
          ListCard(icon: Icons.table_restaurant, alt: true, children: [
            Container(
              width: 50,
              padding: const EdgeInsets.all(8.0),
              child: Text(table.name),
            ),
            Container(
              width: 120,
              padding: const EdgeInsets.all(8.0),
              child: Text(table.filter.toString()),
            ),
          ]),
          for (var seat in table.seats)
            ListCard(
              icon: Icons.chair,
              children: [
                Container(
                  width: 50,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(seat),
                ),
                AddableBlockWidget(
                  blocks: table.block(seat),
                  addCallback: () async {
                    final response = await showDialog<int>(
                      context: context,
                      builder: (context) {
                        return const SetSeatModal();
                      },
                    );

                    if (response != null) {
                      if (response == 1) {
                        final chosenPerson =
                            await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (innerContext) {
                            return const PeopleListingModal();
                          },
                        );
                        if (chosenPerson != null) {
                          setState(() {
                            table.addPerson(seat, chosenPerson.name);
                          });
                        }
                      } else if (response == 2) {
                        setState(() {
                          table.makeGuestSeat(seat);
                        });
                      }
                    }
                  },
                  deleteCallback: (b) {
                    setState(() {
                      if (b.value.isEmpty) {
                        // Its a guest
                        table.remove(seat);
                      } else {
                        // Its a seminarian
                        table.removePerson(seat, b.value);
                      }
                    });
                  },
                )
              ],
            ),
        ]
      ],
    );
  }
}

class SetSeatModal extends StatelessWidget {
  const SetSeatModal({super.key});

  static const icons = [
    Icons.person,
    Icons.person_outline,
    Icons.lock_open_sharp
  ];
  static const titles = ["Seminarian", "Guest"];
  static const values = [1, 2];

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      title: const Text("Choose new occupier"),
      child: ListView(
        children: [
          for (var i = 0; i < titles.length; i++)
            ListTile(
              leading: Icon(icons[i]),
              title: Text(titles[i]),
              onTap: () => Navigator.pop(
                context,
                values[i],
              ),
            ),
        ],
      ),
    );
  }
}

class TableData {
  Map<String, dynamic> data;
  TableData(this.data);

  static List<TableData> fromTableData(List<TableData> d) {
    return List.from(d.map((e) => TableData(Map.from(e.data))));
  }

  static List<TableData> getTables() {
    return List.from(defaultTablesData.map((e) => TableData(Map.from(e))));
  }

  Iterable<String> get seats sync* {
    for (var i = 1; i < 7; i++) {
      yield i.toString();
    }
  }

  List<BlockRecord> block(String seat) {
    if (seatOccupied(seat)) {
      if (seminarianSeat(seat)) {
        return seatPeople(seat).map((e) => BlockRecord(e, e)).toList();
      } else {
        return [BlockRecord("Guest", "")];
      }
    }
    return [];
  }

  String get name => data["name"].toString().toUpperCase();

  List<int> get filter => data["filter"];

  void remove(String key) {
    data.remove(key);
  }

  void removePerson(String seat, String person) {
    if (seminarianSeat(seat)) {
      (data[seat] as List<String>).remove(person);
      if ((data[seat] as List).isEmpty) {
        remove(seat);
      }
    }
  }

  void addPerson(String seat, String person) {
    data[seat] ??= <String>[];
    data[seat].add(person);
  }

  void makeGuestSeat(String seat) {
    data[seat] = null;
  }

  bool seatOccupied(String seat) => data.containsKey(seat);
  bool guestSeat(String seat) => data.containsKey(seat) && data[seat] == null;
  bool seminarianSeat(String seat) =>
      data.containsKey(seat) && data[seat] is List;

  List<String> seatPeople(String seat) {
    final d = data[seat];
    assert(d is List<String>, "Invalid call of seat People");
    return d;
  }
}
