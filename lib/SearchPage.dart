import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:travelark_app/DetailedInfoPage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Map<String, dynamic>>> _busDataFuture;
  late List<Map<String, dynamic>> _busData;
  TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Default to current date

  @override
  void initState() {
    super.initState();
    _busDataFuture = fetchBusData();
  }

  Future<List<Map<String, dynamic>>> fetchBusData() async {
    try {
      final response = await Dio()
          .get('https://travelarkbackend.onrender.com/api/getAllBus');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _busData = data.cast<Map<String, dynamic>>(); // Update the data
        return _busData;
      } else {
        throw Exception('Failed to load bus data');
      }
    } catch (e) {
      throw Exception('Error fetching bus data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPassengerData(
      List<String> passengerIds) async {
    try {
      final response = await Dio().post(
        'https://travelarkbackend.onrender.com/api/getPassengerById',
        data: jsonEncode(passengerIds),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to load passenger data. Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching passenger data: $e');
    }
  }

  List<String> extractPassengerIds(Map<String, dynamic> busData) {
    List<dynamic>? history = busData['history'];
    if (history != null && history.isNotEmpty) {
      for (var entry in history) {
        String? dateString = entry['date'];
        if (dateString != null) {
          try {
            DateTime entryDate = DateTime.parse(dateString);
            if (entryDate.year == _selectedDate.year &&
                entryDate.month == _selectedDate.month &&
                entryDate.day == _selectedDate.day) {
              if (entry.containsKey("passengerIds")) {
                List<dynamic> passengerIds = entry["passengerIds"];
                if (passengerIds.isNotEmpty &&
                    passengerIds.every((element) => element is String)) {
                  return List<String>.from(passengerIds);
                }
              }
            }
          } catch (e) {
            print('Invalid date format: $dateString');
            return [];
          }
        }
      }
    }
    return [];
  }

  String extractDriverName(Map<String, dynamic> busData) {
    List<dynamic>? history = busData['history'];
    if (history != null && history.isNotEmpty) {
      for (var entry in history) {
        String? dateString = entry['date'];
        if (dateString != null) {
          try {
            DateTime entryDate = DateTime.parse(dateString);
            if (entryDate.year == _selectedDate.year &&
                entryDate.month == _selectedDate.month &&
                entryDate.day == _selectedDate.day) {
              if (entry.containsKey("driverName")) {
                return entry["driverName"];
              }
            }
          } catch (e) {
            print('Invalid date format: $dateString');
            return '';
          }
        }
      }
    }
    return '';
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0,
          title: Column(
            children: [
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: 16, fontFamily: 'Popins'),
                  decoration: InputDecoration(
                    hintText: 'Search Bus',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // Add right padding here
              child: IconButton(
                icon: Icon(Icons.calendar_today),
                color: Colors.white,
                onPressed: () => _selectDate(context),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          toolbarHeight: 120,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _busDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bus data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final bus = snapshot.data![index];
                List<dynamic>? history = bus['history'];
                bool hasHistoryOnSelectedDate = history?.any((entry) {
                      String? dateString = entry['date'];
                      if (dateString != null) {
                        try {
                          DateTime entryDate = DateTime.parse(dateString);
                          return entryDate.year == _selectedDate.year &&
                              entryDate.month == _selectedDate.month &&
                              entryDate.day == _selectedDate.day;
                        } catch (e) {
                          print('Invalid date format: $dateString');
                          return false;
                        }
                      }
                      return false;
                    }) ??
                    false;

                if (hasHistoryOnSelectedDate) {
                  int occupancy = extractPassengerIds(bus).length;
                  int availableSeats = occupancy >= 30 ? 0 : 30 - occupancy;
                  String driverName = extractDriverName(bus);

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        bus['name'].toString(),
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver: $driverName'),
                          Text('Occupancy: $occupancy'),
                          Text('Available Seats: $availableSeats'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () async {
                          final List<String> passengerIds =
                              extractPassengerIds(bus);
                          final List<Map<String, dynamic>> passengerData =
                              await fetchPassengerData(passengerIds);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailedInfoPage(
                                busName: bus['name'],
                                passengerData: passengerData,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  // Display a message indicating no history found on the selected date
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        bus['name'].toString(),
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('No history found on the selected date'),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
