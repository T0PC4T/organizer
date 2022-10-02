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
      body: PeopleListing(
        actions: [
          ListingAction(
            title: "Lunch Dishcrew",
            icon: Icons.wash,
            func: updatePersonKey("Lunch Dishcrew"),
          ),
          ListingAction(
            title: "Supper Dishcrew",
            icon: Icons.wash_outlined,
            func: updatePersonKey("Supper Dishcrew"),
          ),
          ListingAction(
            title: "Waiter",
            icon: Icons.man,
            func: updatePersonKey("Waiter"),
          )
        ],
      ),
    );
  }
}

PeopleFunction updatePersonKey(String key) {
  return (person) {
    List<String> newJobs = person.data().jobs;
    if (newJobs.contains(key)) {
      newJobs.remove(key);
    } else {
      newJobs.add(key);
    }
    person.reference.set(Person(
      firstName: person.data().firstName,
      lastName: person.data().lastName,
      year: person.data().year,
      jobs: newJobs,
    ));
  };
}
