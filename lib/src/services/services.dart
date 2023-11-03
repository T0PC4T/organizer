import 'dart:convert';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';

// CACHE SERVICE

typedef CacheUpdate = void Function(int);

abstract class FService<T> {
  final CacheUpdate updateWidget;
  dynamic get data;
  bool get initialized;
  int index;
  void initialize();
  FService({required CacheUpdate update, required this.index})
      : updateWidget = update;
}

abstract class ListService extends FService<Map<String, dynamic>> {
  String get name;
  @override
  Map<String, Map<String, dynamic>>? data;
  @override
  bool initialized;
  String get indexName => "${name}Index";
  bool get ready => data != null;

  ListService({required super.update, super.index = 0}) : initialized = false;

  @override
  void initialize() async {
    initialized = true;
    data = await fetchData();
    updateWidget(++index);
  }

  Map<String, dynamic> docToJson(dynamic doc) {
    return doc.data()..putIfAbsent("id", () => doc.id);
  }

  Future<void> addRecord(Map<String, dynamic> d) async {
    final response = await FirebaseFirestore.instance.collection(name).add(d);
    final results = await response.get();
    data![response.id] = docToJson(results);
    updateWidget(++index);
  }

  void updateRecord(dynamic record, Map<String, dynamic> d) {
    FirebaseFirestore.instance.collection(name).doc(record["id"]).update(d);
    (data?[record["id"]])?.addAll(d);
    updateWidget(++index);
  }

  void deleteRecord(dynamic record) {
    FirebaseFirestore.instance.collection(name).doc(record["id"]).delete();
    data?.remove(record["id"]);
    updateWidget(++index);
  }

  List<Map<String, dynamic>>? get dataList =>
      data == null ? [] : List<Map<String, dynamic>>.from(data!.values);

  Future<Map<String, Map<String, dynamic>>> fetchData();
}

abstract class CacheService extends ListService {
  CacheService({required super.update, super.index = 0});

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
    updateLocalStore(index);
    updateWidget(index);
  }

  @override
  Future<void> addRecord(Map<String, dynamic> d) async {
    await super.addRecord(d);
    updateLocalStore(index);
  }

  @override
  void updateRecord(dynamic record, Map<String, dynamic> d) {
    super.updateRecord(record, d);
    updateLocalStore(index);
  }

  @override
  void deleteRecord(dynamic record) {
    super.deleteRecord(record);
    updateLocalStore(index);
  }

  updateLocalStore(int i) {
    FirebaseFirestore.instance.doc("/cache/$name").set({"index": i});
    html.window.localStorage[name] = dataToString(data!);
    html.window.localStorage[indexName] = i.toString();
  }

  String dataToString(Map<String, Map<String, dynamic>> d) {
    return json.encode(d);
  }

  Map<String, Map<String, dynamic>> stringToData(String d) {
    return Map<String, Map<String, dynamic>>.from(json.decode(d));
  }
}

extension DocExtension on DocumentSnapshot {
  Map<String, dynamic> get dMap => data() as Map<String, dynamic>;
}
