import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:organizer/src/services/providers.dart';
import 'package:organizer/src/services/services.dart';

import 'cards.dart';

List<String> jobs(DocumentSnapshot doc) {
  if (doc.dMap["jobs"] is List) {
    return List<String>.from(doc.dMap["jobs"]);
  }
  return [];
}

enum Jobs {
  // weakly
  lunchDishCrew("Lunch Dish Crew"),
  supperDishCrew("Supper Dish Crew"),
  waiter("Waiter");

  const Jobs(this.pretty);

  final String pretty;
}

class PeopleListing extends ConsumerWidget {
  final List<DocumentSnapshot>? subsetPeopleData;
  final bool tappable;
  final bool editable;
  const PeopleListing({
    super.key,
    this.subsetPeopleData,
    this.tappable = false,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleData = ref.watch(peopleProvider);

    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: peopleData.length,
      itemBuilder: (context, index) {
        final person = peopleData[index];
        return GestureDetector(
          onTap: tappable ? () => Navigator.of(context).pop(person) : null,
          child: ListCard(
            icon: Icons.person,
            children: [
              Container(
                width: 200,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    '${person.dMap["lastName"]}, ${person.dMap["firstName"]}'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Year ${(person.dMap["year"]).toString()}"),
              ),
              AddableBlockWidget(
                  editable: editable,
                  blocks: jobs(person).map((e) => BlockRecord(e, e)),
                  addCallback: () async {
                    final job = await showDialog<String>(
                        context: context,
                        builder: (context) => const JobsModal());
                    if (job != null) {
                      if (editable) {
                        List<String> newJobs = jobs(person);
                        newJobs.add(job);
                        ref
                            .read(peopleProvider.notifier)
                            .update(person.id, {"jobs": newJobs});
                      }
                    }
                  },
                  deleteCallback: (b) {
                    List<String> newJobs = jobs(person);
                    newJobs.remove(b.value);
                    ref
                        .read(peopleProvider.notifier)
                        .update(person.id, {"jobs": newJobs});
                  }),
              if (!tappable)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "Delete") {
                          try {
                            ref.read(peopleProvider.notifier).delete(person.id);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("ERROR: Failed to delete user $e")));
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: "Delete",
                            child: Text('Delete'),
                          )
                        ];
                      },
                    ),
                  ),
                )
            ],
          ),
        );
      },
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

class PeopleListingModal extends ConsumerStatefulWidget {
  const PeopleListingModal({
    super.key,
  });

  @override
  PeopleListingModalState createState() => PeopleListingModalState();
}

class PeopleListingModalState extends ConsumerState<PeopleListingModal> {
  String? filter;

  List<DocumentSnapshot> filteredPeople(BuildContext context) {
    final peopleData = ref.watch(peopleProvider);
    final localFilter = filter;
    if (localFilter != null && localFilter.isNotEmpty) {
      return peopleData
          .where((element) => (element.dMap["lastName"] as String)
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
