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
  List<Map> localTableData;
  SeatingListingState()
      : peopleData = [],
        localTableData = List.from(tablesData.map((e) => Map.from(e)));

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
        element.removeWhere((key, value) => !["name", "filter"].contains(key));
      }
    });
  }

  generate() {
    final localPeopleData = List<DocumentSnapshot<Person>>.from(peopleData);
    final moreLocalTableData = List<Map>.from(localTableData);
    localPeopleData.shuffle();
    List<String> alreadyAssigned = [];
    // Remove people who have already been placed
    for (var table in moreLocalTableData) {
      final keys = table.keys.where((key) => !["name", "filter"].contains(key));
      for (var key in keys) {
        final value = table[key];
        if (value is String) {
          alreadyAssigned.add(table[key]);
        }
      }
    }

    bool fitsFilter(Map t, Person p) {
      return (t["filter"] as List<int>).contains(p.year);
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
          for (var seat = 1; seat < 7; seat++) {
            if (table.containsKey(seat.toString())) {
              continue;
            }
            if (fitsFilter(table, curPerson)) {
              table[seat.toString()] = curPerson.name;

              // Dish Crew Check
              if (curPerson.jobs.contains(Jobs.lunchDishCrew.name)) {
                final i = supperDishCrew.indexWhere(
                    (element) => fitsFilter(table, element.data()!));
                if (i != -1) {
                  table[seat.toString()] =
                      "${table[seat.toString()]};${supperDishCrew[i].data()!.name}";
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
    Size size = MediaQuery.of(context).size;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16 + (size.width / 40),
        16,
        16 + (size.width / 40),
        16,
      ),
      scrollDirection: Axis.vertical,
      children: [
        for (Map table in localTableData)
          ListCard(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.table_restaurant),
              ),
              Container(
                width: 50,
                padding: const EdgeInsets.all(8.0),
                child: Text(table["name"].toString().toUpperCase()),
              ),
              Container(
                width: 120,
                padding: const EdgeInsets.all(8.0),
                child: Text("${table["filter"]}"),
              ),
              for (var i = 1; i < 7; i++)
                GestureDetector(
                  onTap: () async {
                    final response = await showDialog<int>(
                      context: context,
                      builder: (context) {
                        return SetSeatModal(
                            current: table[i.toString()] as String?);
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
                            table[i.toString()] = chosenPerson.name;
                          });
                        }
                      } else if (response == 2) {
                        setState(() {
                          table[i.toString()] = null;
                        });
                      } else if (response == 3) {
                        setState(() {
                          table.remove(i.toString());
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: table.containsKey(i.toString())
                          ? table[i.toString()] is String
                              ? Colors.red
                              : Colors.cyan
                          : primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        i.toString(),
                        style: TextStyle(color: onPrimary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class SetSeatModal extends StatelessWidget {
  final String? current;
  const SetSeatModal({super.key, this.current});

  static const icons = [
    Icons.person,
    Icons.person_outline,
    Icons.lock_open_sharp
  ];
  static const titles = ["Seminarian", "Guest", "Empty"];
  static const values = [1, 2, 3];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ModalCard(
      child: ListView(
        children: [
          if (current != null) ...[
            const Text(
              "Occupied",
              style: TextStyle(fontSize: 24),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(current!),
            ),
          ],
          const Text(
            "Choose new occupier",
            style: TextStyle(fontSize: 24),
          ),
          for (var i = 0; i < 3; i++)
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
