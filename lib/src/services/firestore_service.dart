import 'package:flutter/material.dart';
import 'package:organizer/src/services/people.dart';
import 'package:organizer/src/services/users.dart';

enum FService {
  people,
  users,
}

class FirestoreServiceWidget extends StatefulWidget {
  final Widget child;
  const FirestoreServiceWidget({super.key, required this.child});

  @override
  State<FirestoreServiceWidget> createState() => FirestoreService();
}

class FirestoreService extends State<FirestoreServiceWidget> {
  // Services
  Map<FService, int> data;
  late PeopleService peopleService;
  late UserService userService;

  FirestoreService() : data = {for (var s in FService.values) s: 0};

  static FirestoreService? of(BuildContext context, FService service) {
    context.dependOnInheritedWidgetOfExactType<FirestoreServiceModel>(
      aspect: service,
    );
    return context.findAncestorStateOfType<FirestoreService>();
  }

  updateService(FService s) {
    setState(() {
      data = Map.from(data);
      data[s] = data[s]! + 1;
    });
  }

  @override
  void initState() {
    userService = UserService(updateService);
    peopleService = PeopleService(updateService);
    userService.initialize();
    peopleService.initialize();
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

class FirestoreServiceModel extends InheritedModel<FService> {
  const FirestoreServiceModel({
    super.key,
    required this.data,
    required super.child,
  });

  final Map<FService, int> data;

  @override
  bool updateShouldNotify(FirestoreServiceModel oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(
      FirestoreServiceModel oldWidget, Set<FService> dependencies) {
    for (var v in FService.values) {
      if (data[v] != oldWidget.data[v] && dependencies.contains(v)) {
        return true;
      }
    }
    return false;
  }
}
