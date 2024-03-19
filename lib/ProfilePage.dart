import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelark_app/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('passengerData');
    if (userDataJson != null) {
      setState(() {
        _userData = Map<String, dynamic>.from(jsonDecode(userDataJson));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('passengerData'); // Clear user data
    await prefs.setBool('isLoggedIn', false); // Clear login flag
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userData.isNotEmpty
          ? Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("asset/images/profileicon.png"),
              backgroundColor: Colors.black87,
            ),
            SizedBox(height: 20),
            Text(
              _userData['name'] ?? 'Name not available',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _userData['phone'] ?? 'Phone number not available',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout', style: TextStyle(color: Colors.white,fontFamily: 'Popins'),),
              style: ButtonStyle(fixedSize: MaterialStatePropertyAll(Size(150, 50)),backgroundColor: MaterialStatePropertyAll(Colors.black87)),
            ),
            SizedBox(height: 20),
          ],
        ),
      )
          : Center(
        child: Text('No user data available'),
      ),
    );
  }
}
