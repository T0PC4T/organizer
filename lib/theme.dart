import 'package:flutter/material.dart';

const themePrimary = Color.fromARGB(255, 14, 44, 142);
const themeSecondary = Color.fromARGB(255, 255, 194, 13);

final themeData = ThemeData(
    useMaterial3: true,
    cardTheme: const CardTheme(elevation: 0),
    colorScheme: ColorScheme.fromSeed(
      seedColor: themePrimary,
      secondary: themeSecondary,
    ),
    textTheme: const TextTheme());

const themeNormal = TextStyle(
  color: Colors.black,
  fontSize: 14,
);

const themeLarge = TextStyle(
  color: Colors.black,
  fontSize: 28,
);
