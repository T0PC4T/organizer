import 'package:flutter/material.dart';
import 'package:organizer/src/services/people_service.dart';
import 'package:organizer/src/services/services.dart';
import 'package:organizer/src/services/user_service.dart';

enum FServices {
  user(UserService.new),
  people(PeopleService.new);

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

  static T? serve<T extends FService>(BuildContext context, FServices s) {
    context.dependOnInheritedWidgetOfExactType<FirestoreServiceModel>(
      aspect: s,
    );
    final me = context.findAncestorStateOfType<FirestoreService>();
    final service = me?.services[s];
    if (service == null) {
      throw "No Firestore Service Running!";
    }

    if (!service.initialized) {
      service.initialize();
    }

    return service as T;
  }

  void updateService(FServices s, int newI) {
    print("updating service: ${s.name} // ${data[s]} -> $newI");
    setState(() {
      data = Map.from(data);
      data[s] = newI;
    });
  }

  @override
  void initState() {
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
    for (var v in dependencies) {
      if (data[v] != oldWidget.data[v]) {
        print("SENDING UPDATE");
        return true;
      }
    }
    return false;
  }
}
