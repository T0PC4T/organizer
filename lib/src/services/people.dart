import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PeopleServiceWidget extends StatefulWidget {
  final Widget child;
  const PeopleServiceWidget({super.key, required this.child});

  @override
  State<PeopleServiceWidget> createState() => PeopleService();
}

class PeopleService extends State<PeopleServiceWidget> {
  List<Person> peopleData;

  PeopleService() : peopleData = [];

  static PeopleService? of(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<PeopleServiceInherited>();
    return context.findAncestorStateOfType<PeopleService>();
  }

  @override
  void initState() {
    super.initState();
    getPeople();
  }

  void getPeople() async {
    final peopleRef = FirebaseFirestore.instance.collection('people');

    final response = await peopleRef.get();
    final value = response.docs
      ..sort((a, b) => a["lastName"].compareTo(b.data()["lastName"]));
    setState(() {
      peopleData = value.map((e) => e.person).toList();
    });
  }

  void updatePerson(
    Person newPerson,
  ) async {
    await newPerson.ref.set(newPerson.toJson());
    setState(() {
      final i =
          peopleData.indexWhere((element) => element.path == newPerson.path);
      peopleData[i] = newPerson;
    });
  }

  void deletePerson(
    Person person,
  ) async {
    await person.ref.delete();
    setState(() {
      peopleData.remove(person);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PeopleServiceInherited(
      child: widget.child,
    );
  }
}

class PeopleServiceInherited extends InheritedWidget {
  const PeopleServiceInherited({super.key, required super.child});

  @override
  bool updateShouldNotify(PeopleServiceInherited oldWidget) {
    return true;
  }
}

@immutable
class Person {
  const Person({
    required this.path,
    required this.firstName,
    required this.lastName,
    required this.year,
    required this.jobs,
  });

  DocumentReference<Map<String, dynamic>> get ref =>
      FirebaseFirestore.instance.collection("people").doc(path);

  Person.fromJson(DocumentSnapshot<Map> ref)
      : this(
          path: ref.id,
          firstName: ref.data()!['firstName']! as String,
          lastName: ref.data()!['lastName']! as String,
          year: ref.data()!['year']! as int,
          jobs: ((ref.data()!['jobs'] ?? "") as String)
              .replaceAll(RegExp(r"\s+"), "")
              .split(",")
            ..removeWhere((element) => element.isEmpty),
        );

  final String path;
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

extension PeopleUtil2 on DocumentSnapshot {
  Person get person {
    final localData = data() as Map;
    return Person.fromJson(this as DocumentSnapshot<Map>);
  }
}
