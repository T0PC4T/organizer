import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../services/firestore_service.dart';
import '../services/pdf_gen.dart';
import '../services/seating_data.dart';
import '../widgets/cards.dart';
import '../widgets/people.dart';

class SeatingPage extends StatelessWidget {
  static GlobalKey<SeatingListingState> seatKey =
      GlobalKey<SeatingListingState>();
  const SeatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Seating'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_alert),
              tooltip: 'Show Snackbar',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This is a snackbar')));
              },
            ),
          ],
        ),
        floatingActionButton: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton.extended(
                  key: const ValueKey(1),
                  heroTag: const ValueKey(1),
                  onPressed: () {
                    seatKey.currentState?.generate();
                  },
                  label: const Text('Generate'),
                  icon: const Icon(Icons.settings),
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton.extended(
                  key: const ValueKey(3),
                  heroTag: const ValueKey(3),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PdfPreview(
                          build: (format) => generateSeetingPdf("Seating Chart",
                              seatKey.currentState!.localTableData),
                        ),
                      ),
                    );
                  },
                  label: const Text('Download'),
                  icon: const Icon(Icons.download),
                  backgroundColor: Colors.green[700],
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

class SeatingListing extends StatefulWidget {
  const SeatingListing({super.key});

  @override
  State<SeatingListing> createState() => SeatingListingState();
}

class SeatingListingState extends State<SeatingListing> {
  List<DocumentSnapshot<Person>> peopleData;
  List<TableData> localTableData;
  SeatingListingState()
      : peopleData = [],
        localTableData = TableData.getTables();

  @override
  void initState() {
    super.initState();
    getPeople().then((value) {
      setState(() {
        peopleData = value;
      });
    });
  }

  reset() {
    setState(() {
      for (var element in localTableData) {
        element.data
            .removeWhere((key, value) => !["name", "filter"].contains(key));
      }
    });
  }

  generate() {
    final localPeopleData = List<DocumentSnapshot<Person>>.from(peopleData);
    final moreLocalTableData = TableData.fromTableData(localTableData);
    localPeopleData.shuffle();
    List<String> alreadyAssigned = [];
    // Remove people who have already been placed
    for (var table in moreLocalTableData) {
      for (var seat in table.seats) {
        if (table.seminarianSeat(seat)) {
          alreadyAssigned.addAll(table.seatPeople(seat));
        }
      }
    }

    bool fitsFilter(TableData t, Person p) {
      return (t.filter).contains(p.year);
    }

    localPeopleData.removeWhere(
        (element) => alreadyAssigned.contains(element.data()!.name));

    // Remove people with waiter crew
    localPeopleData.removeWhere(
        (element) => element.data()!.jobs.contains(Jobs.waiter.name));

    // Remove people with waiter crew
    final supperDishCrew = localPeopleData
        .where((element) =>
            element.data()!.jobs.contains(Jobs.supperDishCrew.name))
        .toList();

    localPeopleData.removeWhere(
        (element) => element.data()!.jobs.contains(Jobs.supperDishCrew.name));

    while (localPeopleData.isNotEmpty && supperDishCrew.isNotEmpty) {
      late Person curPerson;
      if (localPeopleData.isNotEmpty) {
        curPerson = localPeopleData.removeLast().data()!;
      } else {
        curPerson = supperDishCrew.removeLast().data()!;
      }

      () {
        for (var table in moreLocalTableData) {
          for (var seat in table.seats) {
            if (table.seatOccupied(seat)) {
              continue;
            }
            if (fitsFilter(table, curPerson)) {
              table.addPerson(seat, curPerson.name);

              // Dish Crew Check
              if (curPerson.jobs.contains(Jobs.lunchDishCrew.name)) {
                final i = supperDishCrew.indexWhere(
                    (element) => fitsFilter(table, element.data()!));
                if (i != -1) {
                  table.addPerson(seat, supperDishCrew[i].data()!.name);
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
      localTableData = moreLocalTableData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      scrollDirection: Axis.vertical,
      children: [
        for (TableData table in localTableData) ...[
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
                        final chosenPerson = await showDialog<Person>(
                          context: context,
                          builder: (innerContext) {
                            return PeopleListingModal(
                              peopleData: peopleData,
                            );
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
    return List.from(tablesData.map((e) => TableData(Map.from(e))));
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
