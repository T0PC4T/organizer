import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Image.asset("assets/images/fssplogo.png"),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('People'),
              onTap: () {
                Navigator.of(context).pushNamed("/people");
              },
            ),
            ListTile(
              leading: const Icon(Icons.chair_rounded),
              title: const Text('Seating'),
              onTap: () => Navigator.of(context).pushNamed("/seating"),
            ),
          ],
        ),
      ),
    );
  }
}
