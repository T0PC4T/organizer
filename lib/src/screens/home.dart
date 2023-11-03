import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:organizer/src/services/providers.dart';

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
            ListTile(
              leading: const Icon(Icons.luggage),
              title: const Text('Guestmasters'),
              onTap: () => Navigator.of(context).pushNamed("/calendar"),
            ),
          ],
        ),
      ),
      body: const UserWidget(),
    );
  }
}

class UserWidget extends ConsumerWidget {
  const UserWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DocumentSnapshot<Map<String, dynamic>>> doc =
        ref.watch(fbuserProvider);

    final widg = switch (doc) {
      AsyncData(:final value) => Text(
          'Hi ${value["name"]}!',
        ),
      AsyncError() => const Text('Oops, something unexpected happened'),
      _ => const CircularProgressIndicator(),
    };
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(20),
      elevation: 20,
      child: SizedBox(
        width: 400,
        height: 600,
        child: Column(children: [
          const FractionallySizedBox(
            widthFactor: 0.5,
            child: FittedBox(
              child: Icon(
                Icons.person,
              ),
            ),
          ),
          FittedBox(
            child: widg,
          ),
        ]),
      ),
    );
  }
}
