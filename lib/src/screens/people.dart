import 'package:flutter/material.dart';
import 'package:organizer/src/services/firestore_service.dart';
import 'package:organizer/src/services/people_service.dart';
import 'package:organizer/src/widgets/cards.dart';

import '../widgets/people.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic>? value = await showDialog<Map<String, dynamic>>(
              context: context, builder: (context) => const AddPersonModal());
          if (value != null && context.mounted) {
            FirestoreService.serve<PeopleService>(context, FServices.people)
                ?.addRecord(value);
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
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
