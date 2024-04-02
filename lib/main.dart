import 'package:eye_dropper/eye_dropper.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colour Contrast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF234b6e)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Colour Contrast'),
      builder: (context, child) => EyeDropper(child: child!),
    );
  }
}
