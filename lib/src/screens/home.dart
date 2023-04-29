import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:organizer/theme.dart';

import '../services/firestore_service.dart';
import '../services/user_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
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
              leading: const Icon(Icons.work),
              title: const Text('Weekly Jobs'),
              onTap: () {
                Navigator.of(context).pushNamed("/people");
              },
            ),
            ListTile(
              leading: const Icon(Icons.chair_rounded),
              title: const Text('Seating'),
              onTap: () => Navigator.of(context).pushNamed("/seating"),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Calendar'),
              onTap: () => Navigator.of(context).pushNamed("/calendar"),
            ),
          ],
        ),
      ),
      body: const UserWidget(),
    );
  }
}

class UserWidget extends StatelessWidget {
  const UserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        (FirestoreService.serve(context, FServices.user) as UserService).data;
    if (user != null) {
      return Card(
        margin: const EdgeInsets.all(20),
        child: ColoredBox(
          color: themeData.hoverColor,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 0.9,
            child: Column(children: [
              const FractionallySizedBox(
                widthFactor: 0.5,
                child: FittedBox(
                  child: Icon(
                    Icons.person,
                  ),
                ),
              ),
              Text(
                'Name: ${user["name"]}',
                style: themeLarge,
              ),
              const Text(
                "Last active: just now!",
                style: themeLarge,
              ),
            ]),
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
