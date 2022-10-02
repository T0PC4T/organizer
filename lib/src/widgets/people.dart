import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/src/services/firestore_service.dart';

typedef PeopleFunction = void Function(QueryDocumentSnapshot<Person>);

class ListingAction {
  final String title;
  final IconData icon;
  final PeopleFunction func;
  ListingAction({
    required this.title,
    required this.icon,
    required this.func,
  });
}

class PeopleListing extends StatefulWidget {
  final List<ListingAction> actions;
  const PeopleListing({
    super.key,
    this.actions = const [],
  });

  @override
  State<PeopleListing> createState() => PeopleListingState();
}

class PeopleListingState extends State<PeopleListing> {
  List<DocumentSnapshot<Person>> peopleData;
  List<Person> data;

  PeopleListingState()
      : peopleData = [],
        data = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    final rawData = await getPeople();
    setState(() {
      peopleData = rawData;
      data = rawData.map<Person>((e) => e.data()).toList()
        ..sort((a, b) => a.lastName.compareTo(b.lastName));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color primary = Theme.of(context).colorScheme.primary;
    Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16 + (size.width / 40),
        16,
        16 + (size.width / 40),
        16,
      ),
      scrollDirection: Axis.vertical,
      children: [
        for (var person in data)
          Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.person),
                    ),
                    Container(
                      width: 200,
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${person.lastName}, ${person.firstName}"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text((person.year).toString()),
                    ),
                    for (String job in person.jobs)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: primary,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                job,
                                style: TextStyle(
                                  color: onPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Icon(
                                Icons.delete,
                                size: 16,
                                color: onPrimary,
                              ),
                              onTap: () async {
                                final ref = peopleData[data.indexOf(person)];
                                final result =
                                    await changeJob(ref, person, job, false);
                                setState(() {
                                  data[data.indexOf(person)] = result;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    IconButton(
                        onPressed: () async {
                          final response = await Navigator.of(
                            context,
                            rootNavigator: true,
                          ).push<String>(
                            DialogRoute<String>(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: EdgeInsets.all(size.width / 8),
                                    child: Card(
                                      child: ListView(children: [
                                        ListTile(
                                          leading: const Icon(Icons.wash),
                                          title: const Text("Lunch Dish Crew"),
                                          onTap: () => Navigator.pop(
                                            context,
                                            "Lunch Dish Crew",
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.wash),
                                          title: const Text("Supper Dish Crew"),
                                          onTap: () => Navigator.pop(
                                            context,
                                            "Supper Dish Crew",
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.wash),
                                          title: const Text("Waiter"),
                                          onTap: () => Navigator.pop(
                                            context,
                                            "Waiter",
                                          ),
                                        ),
                                      ]),
                                    ),
                                  );
                                }),
                          );

                          if (response != null) {
                            final ref = peopleData[data.indexOf(person)];
                            final result =
                                await changeJob(ref, person, response, true);
                            setState(() {
                              data[data.indexOf(person)] = result;
                            });
                          }
                        },
                        icon: const Icon(Icons.add))
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Future<Person> changeJob(
  DocumentSnapshot<Person> ref,
  Person person,
  String key,
  bool add,
) async {
  List<String> newJobs = List.from(person.jobs);
  if (add) {
    newJobs.add(key);
  } else {
    newJobs.remove(key);
  }
  final newPerson = Person(
    firstName: person.firstName,
    lastName: person.lastName,
    year: person.year,
    jobs: newJobs,
  );
  ref.reference.set(newPerson);

  return newPerson;
}
