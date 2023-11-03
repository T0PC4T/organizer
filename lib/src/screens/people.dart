import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:organizer/src/services/providers.dart';
import 'package:organizer/src/widgets/cards.dart';
import 'package:organizer/src/widgets/people.dart';

class PeoplePage extends ConsumerWidget {
  const PeoplePage({super.key});

  String personToMap(person) {
    final firstName =
        (person["firstName"] as String).replaceAll(",", "&comma;");
    final secondName =
        (person["secondName"] as String).replaceAll(",", "&comma;");
    final year = (person["year"] as int);
    return "$firstName,$secondName,$year\r\n";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
      ),
      floatingActionButton: SizedBox(
        height: 150,
        width: 150,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.extended(
                  heroTag: const ValueKey(2),
                  foregroundColor: Colors.white,
                  label: const Row(
                    children: [
                      Icon(Icons.clear),
                      Padding(padding: EdgeInsets.all(3)),
                      Text("Delete Jobs"),
                    ],
                  ),
                  onPressed: () async {
                    ref.read(peopleProvider.notifier).removeAllJobs();
                    // ref.read(peopleProvider.notifier).increaseYear();
                    ref.invalidate(peopleProvider);
                  },
                  backgroundColor: Colors.red),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.extended(
                heroTag: const ValueKey(1),
                foregroundColor: Colors.white,
                label: const Row(
                  children: [
                    Icon(Icons.person),
                    Padding(padding: EdgeInsets.all(3)),
                    Text("Add Person"),
                  ],
                ),
                onPressed: () async {
                  Map<String, dynamic>? value =
                      await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => const AddPersonModal());
                  if (value != null && context.mounted) {
                    ref.read(peopleProvider.notifier).add(value);
                  }
                },
                backgroundColor: const Color.fromARGB(255, 21, 34, 148),
              ),
            ),
          ],
        ),
      ),
      body: const PeopleListing(
        editable: true,
      ),
    );
  }
}

class AddPersonModal extends StatefulWidget {
  const AddPersonModal({super.key});

  @override
  State<AddPersonModal> createState() => _AddPersonModalState();
}

class _AddPersonModalState extends State<AddPersonModal> {
  String firstName = "";
  String lastName = "";
  int year = 1;

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      title: const Text("Add Person"),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
                decoration: const InputDecoration(labelText: "First Name"),
                onChanged: (value) => firstName = value),
            TextField(
                decoration: const InputDecoration(labelText: "Last Name"),
                onChanged: (value) => lastName = value),
            TextField(
              decoration: const InputDecoration(labelText: "Year"),
              onChanged: (value) => year = int.parse(value),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () {
                Navigator.pop(context, {
                  "firstName": firstName,
                  "lastName": lastName,
                  "year": year,
                  "jobs": [],
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
