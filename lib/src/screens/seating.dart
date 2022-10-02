import 'package:flutter/material.dart';

class SeatingPage extends StatelessWidget {
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
        body: const Text("Oh hello there!"));
  }
}

updatePerson(String key) {
  return (people, person) {
    final index = people.indexOf(person);
    if ((people[index] as Map).containsKey(key)) {
      (people[index] as Map).remove(key);
    } else {
      people[index][key] = true;
    }
  };
}
