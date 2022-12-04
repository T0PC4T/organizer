import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/src/services/firestore_service.dart';

class PeopleService {
  List<Person> peopleData;
  final void Function(FService) update;

  PeopleService(this.update) : peopleData = [];

  void initialize() async {
    final peopleRef = FirebaseFirestore.instance.collection('people');

    final response = await peopleRef.get();
    final value = response.docs
      ..sort((a, b) => a["lastName"].compareTo(b.data()["lastName"]));
    peopleData = value.map((e) => e.person).toList();
    update(FService.people);
  }

  void updatePerson(
    Person newPerson,
  ) async {
    await newPerson.ref.set(newPerson.toJson());
    final i =
        peopleData.indexWhere((element) => element.path == newPerson.path);
    peopleData[i] = newPerson;
    update(FService.people);
  }

  void deletePerson(
    Person person,
  ) async {
    await person.ref.delete();

    peopleData.remove(person);
    update(FService.people);
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
