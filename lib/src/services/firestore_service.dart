import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

Future<List<DocumentSnapshot<Person>>> getPeople() async {
  final peopleRef =
      FirebaseFirestore.instance.collection('people').withConverter<Person>(
            fromFirestore: (snapshots, _) => Person.fromJson(snapshots.data()!),
            toFirestore: (person, _) => person.toJson(),
          );

  final response = await peopleRef.get();
  return response.docs
    ..sort((a, b) => a.data().lastName.compareTo(b.data().lastName));
}

void addPerson(Map<String, dynamic> data) {
  FirebaseFirestore.instance.collection('people').add(data);
}
