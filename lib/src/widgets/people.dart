import 'package:flutter/material.dart';

import '../services/people.dart';
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
  final List<Person>? subsetPeopleData;
  final bool tappable;
  final bool editable;
  const PeopleListing({
    super.key,
    this.subsetPeopleData,
    this.tappable = false,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    final peopleData =
        subsetPeopleData ?? PeopleService.of(context)!.peopleData;
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        for (var person in peopleData)
          GestureDetector(
            onTap: tappable ? () => Navigator.of(context).pop(person) : null,
            child: ListCard(
              icon: Icons.person,
              children: [
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(person.name),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Year ${(person.year).toString()}"),
                ),
                AddableBlockWidget(
                    editable: editable,
                    blocks: person.jobs.map((e) => BlockRecord(e, e)),
                    addCallback: () async {
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
                        if (editable) {
                          List<String> newJobs = List.from(person.jobs);
                          newJobs.add(job);
                          final newPerson = Person(
                            path: person.path,
                            firstName: person.firstName,
                            lastName: person.lastName,
                            year: person.year,
                            jobs: newJobs,
                          );

                          PeopleService.of(context)?.updatePerson(newPerson);
                        }
                      }
                    },
                    deleteCallback: (b) {
                      List<String> newJobs = List.from(person.jobs);
                      newJobs.remove(b.value);
                      final newPerson = Person(
                        path: person.path,
                        firstName: person.firstName,
                        lastName: person.lastName,
                        year: person.year,
                        jobs: newJobs,
                      );
                      PeopleService.of(context)?.updatePerson(newPerson);
                    }),
                // TODO make people service inherited widget to whom you can refer all people getting.
                if (!tappable)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == "Delete") {
                            PeopleService.of(context)?.deletePerson(person);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Delete'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  )
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

class PeopleListingModal extends StatefulWidget {
  const PeopleListingModal({
    super.key,
  });

  @override
  State<PeopleListingModal> createState() => _PeopleListingModalState();
}

class _PeopleListingModalState extends State<PeopleListingModal> {
  String? filter;

  List<Person> filteredPeople(BuildContext context) {
    final peopleData = PeopleService.of(context)!.peopleData;
    final localFilter = filter;
    if (localFilter != null && localFilter.isNotEmpty) {
      return peopleData
          .where((element) => element.lastName
              .toLowerCase()
              .startsWith(localFilter.toLowerCase()))
          .toList();
    }
    return peopleData;
  }

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      title: TextField(
          decoration: const InputDecoration(
            counterStyle: ModalCard.titleTheme,
            hintText: "Search",
            hintStyle: ModalCard.titleTheme,
            border: InputBorder.none,
          ),
          cursorColor: ModalCard.titleTheme.color,
          style: ModalCard.titleTheme,
          onChanged: (value) {
            setState(() {
              filter = value;
            });
          }),
      child: Column(
        children: [
          Expanded(
            child: PeopleListing(
              tappable: true,
              subsetPeopleData: filteredPeople(context),
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePersonModal extends StatelessWidget {
  const CreatePersonModal({super.key});

  static const icons = [
    Icons.person,
    Icons.person_outline,
    Icons.lock_open_sharp
  ];
  static const titles = ["Seminarian", "Guest"];
  static const values = [1, 2];

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return ModalCard(
      title: const Text("Create new seminarian"),
      child: ListView(
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'First name',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Last name',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Year',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {}
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
