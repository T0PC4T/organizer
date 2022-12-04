import 'package:flutter/material.dart';

final themeData = ThemeData(
  useMaterial3: true,
  cardTheme: const CardTheme(elevation: 0),
  colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 14, 44, 142),
      secondary: const Color.fromARGB(255, 255, 194, 13)),
);
