import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final List<Widget> children;
  const ListCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      padding: const EdgeInsets.all(16),
      height: 80,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children)),
    ));
  }
}
