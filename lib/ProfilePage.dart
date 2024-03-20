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
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontFamily: "Popins", fontSize: 26),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        toolbarHeight: 80,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userData.isNotEmpty
          ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                AssetImage("asset/images/profileicon.png"),
                backgroundColor: Colors.black87,
              ),
              SizedBox(height: 20),
              _buildProfileItem(label: 'ID', value: _userData['rfid'] ?? 'ID not available'),
              _buildProfileItem(label: 'Name', value: _userData['name'] ?? 'Name not available'),
              _buildProfileItem(label: 'Phone', value: _userData['phone'] ?? 'Phone number not available'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _logout(context),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontFamily: 'Popins'),
                ),
                style: ButtonStyle(
                  fixedSize:
                  MaterialStateProperty.all(Size(150, 50)),
                  backgroundColor:
                  MaterialStateProperty.all(Colors.black87),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      )
          : Center(
        child: Text('No user data available'),
      ),
    );
  }

  Widget _buildProfileItem({required String label, required String value}) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
          Divider(), // Add a divider between items
        ],
    );
  }
}
