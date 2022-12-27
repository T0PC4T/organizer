import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/src/services/firestore_service.dart';

typedef Doc = QueryDocumentSnapshot<Map<String, dynamic>>;

abstract class Gettable {
  String operator [](String s);
}

class ExampleService extends CacheService {
  ExampleService({required super.update});

  @override
  String dataToString(List d) {
    return json.encode(d);
  }

  @override
  List stringToData(String d) {
    return json.decode(d) as List;
  }

  @override
  Future<List<Map>> fetchData() async {
    final exampleRef = FirebaseFirestore.instance.collection('example');
    final response = await exampleRef.get();
    final value = response.docs.map<Map>((doc) => docToJson(doc)).toList();
    return value;
  }

  @override
  String get name => "example";
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service =
        FirestoreService.serve(context, FServices.example) as ExampleService;
    return Scaffold(
      body: ListView(
        children: [
          for (var d in service.data)
            ListTile(
                leading: const Icon(Icons.help),
                title: Text(
                  d["test"],
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () {
                  service.changeRecord(
                      d, {"test": Random().nextDouble().toString()});
                })
        ],
      ),
    );
  }
}
