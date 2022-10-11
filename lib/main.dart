import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, Persistence;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// WEB

import 'package:organizer/src/screens/home.dart';
import 'package:organizer/src/screens/login.dart';
import 'package:organizer/src/screens/people.dart';
import 'package:organizer/src/screens/seating.dart';
import 'package:organizer/src/services/people.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  // debugRepaintRainbowEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // authed
  static Widget Function(BuildContext) authed(
      Widget Function(BuildContext) func) {
    if (FirebaseAuth.instance.currentUser != null) {
      return func;
    }
    return (context) => const LoginPage();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (FirebaseAuth.instance.currentUser == null) {
          return MaterialApp(
            title: 'Organizer',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 14, 44, 142),
                  secondary: const Color.fromARGB(255, 255, 194, 13)),
            ),
            home: const LoginPage(),
          );
        }
        return PeopleServiceParent(
          child: MaterialApp(
            title: 'Organizer',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 14, 44, 142),
                  secondary: const Color.fromARGB(255, 255, 194, 13)),
            ),
            home: const HomePage(),
            onGenerateRoute: (settings) {
              Widget? widget;
              Map routeMap = {
                '/people': (context) => const PeoplePage(),
                '/seating': (context) => const SeatingPage(),
              };
              if (routeMap.containsKey(settings.name)) {
                widget = routeMap[settings.name](context);
              }
              widget ??= const HomePage();
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => widget!,
              );
            },
          ),
        );
      },
    );
  }
}
