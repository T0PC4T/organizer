import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/src/services/firestore_service.dart';

class PeopleService extends CacheService<Person> {
  PeopleService({required super.update}) : super();

  void updatePerson(
    Person newPerson,
  ) async {
    await newPerson.ref.set(newPerson.toJson());
    final i = data.indexWhere((element) => element.id == newPerson.id);
    data[i] = newPerson;
    updateLocalStoreAndWidget(++index);
  }

  void deletePerson(
    Person person,
  ) async {
    deleteRecord(person);
  }

  @override
  Future<List<Person>> fetchData() async {
    final peopleRef = FirebaseFirestore.instance.collection('people');

    final response = await peopleRef.get();
    final value = response.docs
      ..sort((a, b) => a["lastName"].compareTo(b.data()["lastName"]));
    return value.map((e) => e.person).toList();
  }

  @override
  String get name => "people";

  @override
  List<Person> stringToData(String d) {
    return (json.decode(d) as List).map((e) => Person.fromJson(e)).toList();
  }

  @override
  String dataToString(List<Person> d) {
    return json.encode(data
        .map((e) => {
              'id': e.id,
              'firstName': e.firstName,
              'lastName': e.lastName,
              'year': e.year,
              'jobs': e.jobs,
            })
        .toList());
  }
}

Map<String, String> mapToPerson(
    QueryDocumentSnapshot<Map<String, dynamic>> ref) {
  return {
    "id": ref.id,
    "firstName": ref.data()['firstName']! as String,
    "lastName": ref.data()['lastName']! as String,
    "year": (ref.data()['year']! as int).toString(),
    "jobs": ((ref.data()['jobs'] ?? "") as String),
  };
}

@immutable
class Person {
  const Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.year,
    required this.jobs,
  });

  String operator [](String key) {
    if (key == "id") {
      return id;
    }
    throw UnimplementedError("[] not implemented for Person");
  }

  DocumentReference<Map<String, dynamic>> get ref =>
      FirebaseFirestore.instance.collection("people").doc(id);

  Person.fromDoc(DocumentSnapshot<Map> ref)
      : this(
          id: ref.id,
          firstName: ref.data()!['firstName']! as String,
          lastName: ref.data()!['lastName']! as String,
          year: ref.data()!['year']! as int,
          jobs: ((ref.data()!['jobs'] ?? "") as String)
              .replaceAll(RegExp(r"\s+"), "")
              .split(",")
            ..removeWhere((element) => element.isEmpty),
        );

  Person.fromJson(dynamic d)
      : this(
          id: d["id"],
          firstName: d["firstName"],
          lastName: d["lastName"],
          year: d["year"],
          jobs: (d["jobs"] as List).map((e) => e.toString()).toList(),
        );

  final String id;
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
    return Person.fromDoc(this as DocumentSnapshot<Map>);
  }
}
