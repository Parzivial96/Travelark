import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelark_app/LoginPage.dart';
import 'package:travelark_app/Mapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkIfLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          final isLoggedIn = snapshot.data ?? false;
          return MaterialApp(
            title: 'Travelark',
            home: isLoggedIn ? Mapper() : LoginPage(),
            debugShowCheckedModeBanner: false,
          );
        }
      },
    );
  }

  Future<bool> checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('isLoggedIn') && prefs.getBool('isLoggedIn')!;
  }
}
