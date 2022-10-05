import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../widgets/people.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              // for (var record in peopleData["data"]!) {
              //   addPerson(record);
              // }
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar')));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('This functionality does not exist yet!'),
            backgroundColor: Colors.red,
          ));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      body: const PeopleBody(),
    );
  }
}

class PeopleBody extends StatefulWidget {
  const PeopleBody({
    Key? key,
  }) : super(key: key);

  @override
  State<PeopleBody> createState() => _PeopleBodyState();
}

class _PeopleBodyState extends State<PeopleBody> {
  List<DocumentSnapshot<Person>>? peopleData;

  @override
  void initState() {
    () async {
      final response = await getPeople();
      setState(() {
        peopleData = response;
      });
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (peopleData == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return PeopleListing(
        peopleData: peopleData!,
        editFunc: ((person, job, add) async {
          final ref = peopleData!
              .firstWhere((element) => element.data()!.name == person.name);
          DocumentSnapshot<Person> newDoc =
              await changeJob(ref, person, job, add);
          setState(() {
            final oldDoc = peopleData!
                .firstWhere((element) => element.data()?.name == person.name);
            peopleData![peopleData!.indexOf(oldDoc)] = newDoc;
          });
        }),
      );
    }
  }
}
