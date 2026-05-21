import 'package:flutter/material.dart';
import 'pages/greenhouse_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenhouse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 40, 166, 45)),
      ),
      home: const GreenhousePage(),
    );
  }
}


