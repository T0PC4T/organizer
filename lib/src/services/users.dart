import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:organizer/src/services/firestore_service.dart';

class UserService extends FService<DocumentSnapshot<Map<String, dynamic>>> {
  DocumentSnapshot<Map<String, dynamic>>? user;

  @override
  bool initialized = false;

  UserService({required super.update}) : super(index: 0);

  @override
  void initialize() async {
    final userRef = FirebaseFirestore.instance
        .doc("/users/${FirebaseAuth.instance.currentUser!.uid}");

    user = await userRef.get();
    initialized = true;
    updateFunc(++index);
  }

  @override
  get data => user;
}
