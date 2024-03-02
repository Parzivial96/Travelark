import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:travelark_app/SearchPage.dart';
import 'package:travelark_app/HomePage.dart';

class Mapper extends StatefulWidget {
  const Mapper({super.key});

  @override
  State<Mapper> createState() => _MapperState();
}

class _MapperState extends State<Mapper> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Check if _pageController is null and initialize if needed
    if (_pageController == null) {
      _pageController = PageController(initialPage: _currentIndex);
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomePage(),
          SearchPage(),
        ],
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
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home,
                  color: _currentIndex == 0 ? Colors.white : Colors.grey),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search,
                  color: _currentIndex == 1 ? Colors.white : Colors.grey),
              label: 'Search',
            ),
          ],
          backgroundColor: Colors.black87,
        ),
      ),
    );
  }
}
