import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/src/services/firestore_service.dart';

import 'cards.dart';

enum Jobs {
  // weakly
  lunchDishCrew("Lunch Dish Crew"),
  supperDishCrew("Supper Dish Crew"),
  waiter("Waiter");

  const Jobs(this.pretty);

  final String pretty;
}

class PeopleListing extends StatelessWidget {
  final List<DocumentSnapshot<Person>> peopleData;
  final bool tappable;
  final void Function(Person, String, bool)? editFunc;
  const PeopleListing({
    super.key,
    required this.peopleData,
    this.tappable = false,
    this.editFunc,
  });

  List<Person> get data {
    return peopleData.map<Person>((e) => e.data()!).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color primary = Theme.of(context).colorScheme.primary;
    Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
      scrollDirection: Axis.vertical,
      children: [
        for (var person in data)
          GestureDetector(
            onTap: tappable ? () => Navigator.of(context).pop(person) : null,
            child: ListCard(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.person),
                ),
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(person.name),
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
                        if (!tappable)
                          GestureDetector(
                            child: Icon(
                              Icons.clear,
                              size: 16,
                              color: onPrimary,
                            ),
                            onTap: () {
                              if (editFunc != null) {
                                editFunc!(person, job, false);
                              }
                            },
                          )
                      ],
                    ),
                  ),
                if (!tappable)
                  IconButton(
                      onPressed: () async {
                        final job = await Navigator.of(
                          context,
                          rootNavigator: true,
                        ).push<String>(
                          DialogRoute<String>(
                              context: context,
                              builder: (context) {
                                return const JobsModal();
                              }),
                        );

                        if (job != null) {
                          if (editFunc != null) {
                            editFunc!(person, job, true);
                          }
                        }
                      },
                      icon: const Icon(Icons.add))
              ],
            ),
          ),
      ],
    );
  }
}

class JobsModal extends StatelessWidget {
  const JobsModal({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      child: ListView(children: [
        const Center(
          child: Text(
            "Choose a job",
            style: TextStyle(fontSize: 24),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.lunch_dining_sharp),
          title: Text(Jobs.lunchDishCrew.pretty),
          onTap: () => Navigator.pop(
            context,
            Jobs.lunchDishCrew.name,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.nightlight),
          title: Text(Jobs.supperDishCrew.pretty),
          onTap: () => Navigator.pop(
            context,
            Jobs.supperDishCrew.name,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.food_bank),
          title: Text(Jobs.waiter.pretty),
          onTap: () => Navigator.pop(
            context,
            Jobs.waiter.name,
          ),
        ),
      ]),
    );
  }
}

Future<DocumentSnapshot<Person>> changeJob(
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
  final newRef = FirebaseFirestore.instance
      .collection('people')
      .where("lastName", isEqualTo: newPerson.lastName)
      .withConverter<Person>(
        fromFirestore: (snapshots, _) => Person.fromJson(snapshots.data()!),
        toFirestore: (person, _) => person.toJson(),
      );

  final results = await newRef.get();

  return results.docs[0];
}

class PeopleListingModal extends StatefulWidget {
  final List<DocumentSnapshot<Person>> peopleData;

  const PeopleListingModal({
    super.key,
    required this.peopleData,
  });

  @override
  State<PeopleListingModal> createState() => _PeopleListingModalState();
}

class _PeopleListingModalState extends State<PeopleListingModal> {
  String? filter;

  List<DocumentSnapshot<Person>> filteredPeople() {
    final localFilter = filter;
    if (localFilter != null && localFilter.isNotEmpty) {
      return widget.peopleData
          .where((element) => element
              .data()!
              .lastName
              .toLowerCase()
              .startsWith(localFilter.toLowerCase()))
          .toList();
    }
    return widget.peopleData;
  }

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      child: Flex(
        direction: Axis.vertical,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
              child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Seminarian Name",
                    label: Text("Search"),
                  ),
                  style: const TextStyle(fontSize: 24),
                  onChanged: (value) {
                    setState(() {
                      filter = value;
                    });
                  }),
            ),
          ),
          Expanded(
            child: PeopleListing(
              tappable: true,
              peopleData: filteredPeople(),
            ),
          ),
        ],
      ),
    );
  }
}
