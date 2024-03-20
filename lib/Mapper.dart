import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelark_app/HomePage.dart';
import 'package:travelark_app/ProfilePage.dart';
import 'package:travelark_app/SearchPage.dart';
import 'package:travelark_app/SignupPage.dart';

class Mapper extends StatefulWidget {
  const Mapper({Key? key}) : super(key: key);

  @override
  State<Mapper> createState() => _MapperState();
}

class _MapperState extends State<Mapper> {
  int _currentIndex = 0;
  late PageController _pageController;
  String? _userRole; // Make _userRole nullable
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _loadUserRole();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('passengerData');
    if (userDataJson != null) {
      setState(() {
        _userData = Map<String, dynamic>.from(jsonDecode(userDataJson));
        _userRole = _userData['role'];
      });
    } else {
      print("No user data found");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if _userRole is null before using it
    if (_userRole == null) {
      // You can return a loading indicator or any other widget here
      return CircularProgressIndicator(); // Example of a loading indicator
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _buildPages(),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _pageController.jumpToPage(index);
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: _buildNavigationItems(),
          backgroundColor: Colors.black87,
        ),
      ),
    );
  }

  List<Widget> _buildPages() {
    // Check if _userRole is null before accessing it
    if (_userRole == 'Admin') {
      return [HomePage(), SearchPage(), SignupPage(),ProfilePage()];
    } else {
      return [HomePage(), ProfilePage()];
    }
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    // Check if _userRole is null before accessing it
    if (_userRole == 'Admin') {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: _currentIndex == 0 ? Colors.white : Colors.grey),
          label: 'Home',
          backgroundColor: Colors.black87
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded, color: _currentIndex == 1 ? Colors.white : Colors.grey),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add, color: _currentIndex == 2 ? Colors.white : Colors.grey),
          label: 'Signup', // Label for SignupPage
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: _currentIndex == 3 ? Colors.white : Colors.grey),
          label: 'Profile',
        ),
      ];
    } else {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: _currentIndex == 0 ? Colors.white : Colors.grey),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: _currentIndex == 1 ? Colors.white : Colors.grey),
          label: 'Profile',
        ),
      ];
    }
  }
}
