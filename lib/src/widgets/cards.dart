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

class ModalCard extends StatelessWidget {
  final Widget child;
  const ModalCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(64),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: child,
        ),
      ),
    );
  }
}

class BlockRecord {
  final String name;
  final String value;
  BlockRecord(this.name, this.value);
}

class AddableBlockWidget extends StatelessWidget {
  const AddableBlockWidget({
    super.key,
    required this.blocks,
    required this.addCallback,
    required this.deleteCallback,
    this.editable = true,
  });

  final Iterable<BlockRecord> blocks;
  final bool editable;
  final void Function() addCallback;
  final void Function(BlockRecord) deleteCallback;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color primary = Theme.of(context).colorScheme.primary;
    Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Row(
      children: [
        for (var block in blocks)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    block.name,
                    style: TextStyle(
                      color: onPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (editable)
                  GestureDetector(
                    child: Icon(
                      Icons.clear,
                      size: 16,
                      color: onPrimary,
                    ),
                    onTap: () {
                      deleteCallback(block);
                    },
                  )
              ],
            ),
          ),
        if (editable)
          IconButton(onPressed: addCallback, icon: const Icon(Icons.add))
      ],
    );
  }
}
