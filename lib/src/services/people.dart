import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PeopleServiceParent extends StatefulWidget {
  final Widget child;
  const PeopleServiceParent({super.key, required this.child});

  @override
  State<PeopleServiceParent> createState() => PeopleServiceParentState();
}

class PeopleServiceParentState extends State<PeopleServiceParent> {
  List<DocumentSnapshot<Person>> peopleData;

  PeopleServiceParentState() : peopleData = [];

  @override
  void initState() {
    super.initState();
    getPeople();
  }

  void getPeople() async {
    final peopleRef = FirebaseFirestore.instance
        .collection('people')
        .withConverter<Person>(
          fromFirestore: (snapshots, _) => Person.fromJson(snapshots.data()!),
          toFirestore: (person, _) => person.toJson(),
        );

    final response = await peopleRef.get();
    final value = response.docs
      ..sort((a, b) => a.data().lastName.compareTo(b.data().lastName));
    setState(() {
      peopleData = value;
    });
  }

  void updatePerson(
    DocumentSnapshot<Person> ref,
    Person person,
  ) async {
    await ref.reference.set(person);
    final newRef = FirebaseFirestore.instance
        .collection('people')
        .where("lastName", isEqualTo: person.lastName)
        .where("firstName", isEqualTo: person.firstName)
        .withConverter<Person>(
          fromFirestore: (snapshots, _) => Person.fromJson(snapshots.data()!),
          toFirestore: (person, _) => person.toJson(),
        );

    final results = await newRef.get();

    setState(() {
      peopleData[peopleData.indexOf(ref)] = results.docs[0];
    });
  }

  void deletePerson(
    DocumentSnapshot<Person> ref,
  ) async {
    await ref.reference.delete();
    setState(() {
      peopleData.remove(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PeopleService(
      child: widget.child,
    );
  }
}

class PeopleService extends InheritedWidget {
  const PeopleService({super.key, required super.child});

  static PeopleServiceParentState? of(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<PeopleService>();
    return context.findAncestorStateOfType<PeopleServiceParentState>();
  }

  @override
  bool updateShouldNotify(PeopleService oldWidget) {
    return true;
  }
}

@immutable
class Person {
  const Person({
    required this.firstName,
    required this.lastName,
    required this.year,
    required this.jobs,
  });

  Person.fromJson(Map<String, Object?> json)
      : this(
          firstName: json['firstName']! as String,
          lastName: json['lastName']! as String,
          year: json['year']! as int,
          jobs: ((json['jobs'] ?? "") as String)
              .replaceAll(RegExp(r"\s+"), "")
              .split(",")
            ..removeWhere((element) => element.isEmpty),
        );

  final String firstName;
  final String lastName;
  final int year;
  final List<String> jobs;

  String get name => "$lastName, $firstName";

  Map<String, Object?> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'year': year,
      'jobs': jobs.join(","),
    };
  }
}

extension PeopleUtil on List<DocumentSnapshot<Person>> {
  List<Person> get data {
    return map<Person>((e) => e.data()!).toList();
  }
}
