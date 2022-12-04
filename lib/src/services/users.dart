import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:organizer/src/services/firestore_service.dart';

class UserService {
  DocumentSnapshot<Map<String, dynamic>>? user;
  final void Function(FService) update;

  UserService(this.update);

  void initialize() async {
    try {
      final userRef = FirebaseFirestore.instance
          .doc("/users/${FirebaseAuth.instance.currentUser!.uid}");
      print("/users/${FirebaseAuth.instance.currentUser!.uid}");

      user = await userRef.get();
      print(user);
      update(FService.users);
    } catch (e) {
      print(e);
    }
  }
}
