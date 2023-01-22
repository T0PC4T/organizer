import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, Persistence;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:organizer/src/screens/calendar.dart';
// WEB

import 'package:organizer/src/screens/home.dart';
import 'package:organizer/src/screens/login.dart';
import 'package:organizer/src/screens/people.dart';
import 'package:organizer/src/screens/seating.dart';
import 'package:organizer/src/services/firestore_service.dart';
import 'package:organizer/theme.dart';

import 'firebase_options.dart';

// flutter build web --web-renderer=canvaskit

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
            theme: themeData,
            home: const LoginPage(),
          );
        }
        return FirestoreServiceWidget(
          child: MaterialApp(
            title: 'Organizer',
            theme: themeData,
            home: const HomePage(),
            onGenerateRoute: (settings) {
              Widget? widget;
              Map routeMap = {
                '/people': (context) => const PeoplePage(),
                '/seating': (context) => const SeatingPage(),
                '/calendar': (context) => const CalendarScreen(),
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
