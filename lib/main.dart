import 'package:flutter/material.dart';
import 'package:travelark_app/Mapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelark',
      home: const Mapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}