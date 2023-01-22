import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizer/src/services/services.dart';

class PeopleService extends CacheService {
  PeopleService({required super.update}) : super();

  @override
  Future<Map<String, Map<String, dynamic>>> fetchData() async {
    final ref = FirebaseFirestore.instance.collection(name);
    final result = await ref.get();
    final results = {for (var doc in result.docs) doc.id: docToJson(doc)};
    return results;
  }

  @override
  List<Map<String, dynamic>>? get dataList {
    return data?.values.toList()
      ?..sort((a, b) => a["lastName"].compareTo(b["lastName"]));
  }

  @override
  String get name => "people";
}

extension PersonName on Map<String, dynamic> {
  String get name => '${this["firstName"]}  ${this["lastName"]}';
  List<String> get jobs {
    if (this["jobs"] is List) {
      return List<String>.from(this["jobs"]);
    }
    return [];
  }
}
