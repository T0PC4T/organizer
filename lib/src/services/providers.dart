import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<String, dynamic> docToJson(DocumentSnapshot doc) {
  return (doc.data() as Map<String, dynamic>)..putIfAbsent("id", () => doc.id);
}

abstract mixin class DocOperation {
  CollectionReference get fsref;
  List<DocumentSnapshot> get state;
  set state(List<DocumentSnapshot> data);

  Future<DocumentReference<Object?>> add(Map<String, dynamic> data) async {
    final response = await fsref.add(data);
    final newDoc = await response.get();
    state = [...state, newDoc];
    return response;
  }

  Future<void> update(docId, Map<String, dynamic> data) async {
    final response = await fsref.doc(docId).update(data);
    final newState = state.toList();
    final updateDoc = newState.firstWhere((element) => element.id == docId);
    final index = newState.indexOf(updateDoc);
    final newDoc = await fsref.doc(docId).get();
    newState.replaceRange(index, index + 1, [newDoc]);
    state = newState;
    return response;
  }

  Future<void> delete(String docId) async {
    await fsref.doc(docId).delete();
    state = state.toList()..removeWhere((element) => element.id == docId);
  }
}

class PeopleManager extends StateNotifier<List<DocumentSnapshot>>
    with DocOperation {
  @override
  PeopleManager() : super([]) {
    fsref.get().then((value) {
      state = ([for (var doc in value.docs) doc])
        ..sort((a, b) => a["lastName"].compareTo(b["lastName"]));
    });
  }
  @override
  CollectionReference get fsref =>
      FirebaseFirestore.instance.collection("people");

  removeAllJobs() {
    final batch = FirebaseFirestore.instance.batch();
    for (var person in state) {
      if ((person["jobs"] as List).isNotEmpty) {
        batch.update(fsref.doc(person.id), {"jobs": []});
      }
    }
    batch.commit();
  }

  increaseYear() {
    final batch = FirebaseFirestore.instance.batch();
    for (var person in state) {
      batch.update(
          FirebaseFirestore.instance.collection("people").doc(person["id"]),
          {"year": person["year"] + 1});
    }
    batch.commit();
  }
}

final peopleProvider =
    StateNotifierProvider<PeopleManager, List<DocumentSnapshot>>((ref) {
  return PeopleManager();
});

extension PersonName on DocumentSnapshot {
  String get name =>
      '${(data() as Map)["lastName"]}, ${(data() as Map)["firstName"]}';
  List<String> get jobs {
    if ((data() as Map)["jobs"] is List) {
      return List<String>.from((data() as Map)["jobs"]);
    }
    return [];
  }
}

final fbuserProvider = FutureProvider.autoDispose((ref) async {
  final userRef = FirebaseFirestore.instance
      .doc("/users/${FirebaseAuth.instance.currentUser!.uid}");

  final user = await userRef.get();
  return user;
});
