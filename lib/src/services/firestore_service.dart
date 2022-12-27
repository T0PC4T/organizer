import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:organizer/src/services/example.dart';
import 'package:organizer/src/services/people.dart';
import 'package:organizer/src/services/users.dart';

enum FServices {
  people(PeopleService.new),
  users(UserService.new),
  example(ExampleService.new);

  final FService Function({required void Function(int) update}) cons;
  const FServices(this.cons);
}

class FirestoreServiceWidget extends StatefulWidget {
  final Widget child;
  const FirestoreServiceWidget({super.key, required this.child});

  @override
  State<FirestoreServiceWidget> createState() => FirestoreService();
}

class FirestoreService extends State<FirestoreServiceWidget> {
  // Services
  late Map<FServices, int> data;
  late Map<FServices, FService> services;

  FirestoreService();

  static FirestoreService? of(BuildContext context, FServices service) {
    context.dependOnInheritedWidgetOfExactType<FirestoreServiceModel>(
      aspect: service,
    );
    return context.findAncestorStateOfType<FirestoreService>();
  }

  static FService? serve(BuildContext context, FServices s) {
    context.dependOnInheritedWidgetOfExactType<FirestoreServiceModel>(
      aspect: s,
    );
    final me = context.findAncestorStateOfType<FirestoreService>();
    final service = me?.services[s];
    if (!service!.initialized) {
      service.initialize();
    }
    return service;
  }

  void updateService(FServices s, int newI) {
    setState(() {
      data = Map.from(data);
      data[s] = newI;
    });
  }

  @override
  void initState() {
    const a = ExampleService.new;

    services = {
      for (var key in FServices.values)
        key: key.cons(update: (int i) => updateService(key, i))
    };

    data = {
      for (var key in services.keys) key: services[key]!.index,
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreServiceModel(
      data: data,
      child: widget.child,
    );
  }
}

class FirestoreServiceModel extends InheritedModel<FServices> {
  const FirestoreServiceModel({
    super.key,
    required this.data,
    required super.child,
  });

  final Map<FServices, int> data;

  @override
  bool updateShouldNotify(FirestoreServiceModel oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(
      FirestoreServiceModel oldWidget, Set<FServices> dependencies) {
    for (var v in FServices.values) {
      if (data[v] != oldWidget.data[v] && dependencies.contains(v)) {
        return true;
      }
    }
    return false;
  }
}

// CACHE SERVICE

typedef CacheUpdate = void Function(int);

abstract class FService<T> {
  final CacheUpdate updateFunc;
  dynamic get data;
  bool get initialized;
  int index;
  void initialize();
  FService({required CacheUpdate update, required this.index})
      : updateFunc = update;
}

abstract class CacheService<T> extends FService<T> {
  String get name;
  @override
  List<T> data;
  @override
  bool initialized;
  String get indexName => "${name}Index";

  CacheService({required super.update, super.index = 0, this.data = const []})
      : initialized = false;

  @override
  initialize() async {
    initialized = true;
    if (html.window.localStorage.containsKey(name) &&
        html.window.localStorage.containsKey(indexName)) {
      try {
        data = stringToData(html.window.localStorage[name]!);
        index = int.parse(html.window.localStorage[indexName].toString());
      } catch (e) {
        // Clean cache on error.
        print("There was an error: $e");
        print(e);
        html.window.localStorage.remove(name);
        html.window.localStorage.remove(indexName);
      }
    }
    final cacheRef = FirebaseFirestore.instance.doc("/cache/$name");

    final cacheRecord = await cacheRef.get();
    int liveIndex = cacheRecord.exists ? cacheRecord["index"] : 0;
    if (liveIndex != index) {
      print("-------------FETCHING '$name' DATA-------------");
      data = await fetchData();
      index = liveIndex;
    }
    updateLocalStoreAndWidget(index);
  }

  Map<String, dynamic> docToJson(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return doc.data()..putIfAbsent("id", () => doc.id);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> addRecord(
      Map<String, dynamic> d) async {
    final response = await FirebaseFirestore.instance.collection(name).add(d);
    return response.get();
  }

  void changeRecord(dynamic record, Map<String, dynamic> d) {
    FirebaseFirestore.instance.collection(name).doc(record["id"]).set(d);
    (data[data.indexOf(record)] as Map).addAll(d);
    updateLocalStoreAndWidget(++index);
  }

  void deleteRecord(dynamic record) {
    FirebaseFirestore.instance.collection(name).doc(record["id"]).delete();
    data.remove(record);
    updateLocalStoreAndWidget(++index);
  }

  updateLocalStoreAndWidget(int i) {
    FirebaseFirestore.instance.doc("/cache/$name").set({"index": i});
    html.window.localStorage[name] = dataToString(data);
    html.window.localStorage[indexName] = i.toString();
    updateFunc(i);
  }

  List<T> stringToData(String d);
  String dataToString(List<T> d);
  Future<List<T>> fetchData();
}
