import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final IconData icon;
  final List<Widget> children;
  final bool alt;
  const ListCard(
      {super.key,
      required this.children,
      required this.icon,
      this.alt = false});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Card(
      child: DefaultTextStyle(
        style: TextStyle(
          color: alt ? onPrimary : primary,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: alt ? primary : onPrimary,
          height: 80,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    icon,
                    color: alt ? onPrimary : primary,
                  ),
                ),
                ...children
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ModalCard extends StatelessWidget {
  final Widget child;
  final Widget? title;
  const ModalCard({super.key, required this.child, this.title});

  static const titleTheme = TextStyle(
    fontSize: 24,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(64),
      child: Card(
        child: Column(children: [
          if (title != null)
            DefaultTextStyle(
              style: titleTheme,
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: title,
              ),
            ),
          Expanded(
            child: Container(
              width: double.infinity,
              // constraints: const BoxConstraints(maxHeight: 500),
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          )
        ]),
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
          IconButton(
            onPressed: addCallback,
            icon: const Icon(Icons.add_circle),
            color: primary,
          )
      ],
    );
  }
}
