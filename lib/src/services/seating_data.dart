import 'package:flutter_riverpod/flutter_riverpod.dart';

final tableFilterProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      "name": "a",
      "filter": [2, 3, 4, 5, 6, 7],
    },
    {
      "name": "b",
      "filter": [2, 3, 4, 5, 6, 7],
    },
    {
      "name": "c",
      "filter": [2, 3, 4, 5, 6, 7],
      "2": null // automatically adds a guest seat.
    },
    {
      "name": "d",
      "filter": [1],
    },
    {
      "name": "e",
      "filter": [2, 3, 4, 5, 6, 7],
    },
    {
      "name": "f",
      "filter": [2, 3, 4, 5, 6, 7],
    },
    {
      "name": "g",
      "filter": [1],
    },
    {
      "name": "h",
      "filter": [2, 3, 4, 5, 6, 7],
    },
    {
      "name": "i",
      "filter": [2, 3, 4, 5, 6, 7],
    },
    {
      "name": "j",
      "filter": [2, 3, 4, 5, 6, 7],
    },
    {
      "name": "k",
      "filter": [2, 3, 4, 5, 6, 7],
    },
    {
      "name": "l",
      "filter": [2, 3, 4, 5, 6, 7],
    },
    {
      "name": "m",
      "filter": [1],
    },
    {
      "name": "n",
      "filter": [2, 3, 4, 5, 6, 7],
    },
  ];
});
