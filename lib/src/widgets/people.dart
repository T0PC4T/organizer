import 'package:cloud_firestore/cloud_firestore.dart';
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
  final List<DocumentSnapshot<Person>>? subsetPeopleData;
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
    List<Person> localData = peopleData.map<Person>((e) => e.data()!).toList();
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        for (var i = 0; i < localData.length; i++)
          GestureDetector(
            onTap:
                tappable ? () => Navigator.of(context).pop(localData[i]) : null,
            child: ListCard(
              icon: Icons.person,
              children: [
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(localData[i].name),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Year ${(localData[i].year).toString()}"),
                ),
                AddableBlockWidget(
                    blocks: localData[i].jobs.map((e) => BlockRecord(e, e)),
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
                          List<String> newJobs = List.from(localData[i].jobs);
                          newJobs.add(job);
                          final newPerson = Person(
                            firstName: localData[i].firstName,
                            lastName: localData[i].lastName,
                            year: localData[i].year,
                            jobs: newJobs,
                          );
                          PeopleService.of(context)
                              ?.updatePerson(peopleData[i], newPerson);
                        }
                      }
                    },
                    deleteCallback: (b) {
                      List<String> newJobs = List.from(localData[i].jobs);
                      newJobs.remove(b.value);
                      final newPerson = Person(
                        firstName: localData[i].firstName,
                        lastName: localData[i].lastName,
                        year: localData[i].year,
                        jobs: newJobs,
                      );
                      PeopleService.of(context)
                          ?.updatePerson(peopleData[i], newPerson);
                    }),
                // TODO make people service inherited widget to whom you can refer all people getting.
                if (!tappable)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          PeopleService.of(context)
                              ?.deletePerson(peopleData[i]);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
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

  List<DocumentSnapshot<Person>> filteredPeople(BuildContext context) {
    final peopleData = PeopleService.of(context)!.peopleData;
    final localFilter = filter;
    if (localFilter != null && localFilter.isNotEmpty) {
      return peopleData
          .where((element) => element
              .data()!
              .lastName
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
            hintText: "Search",
            hintStyle: ModalCard.titleTheme,
            border: InputBorder.none,
          ),
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
