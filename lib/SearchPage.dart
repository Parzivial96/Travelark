import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Map<String, dynamic>>> _busDataFuture;
  late List<Map<String, dynamic>> _busData;
  late List<Map<String, dynamic>> _filteredBusData;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _busDataFuture = fetchBusData();
    _filteredBusData = [];
  }

  Future<List<Map<String, dynamic>>> fetchBusData() async {
    try {
      final response =
      await Dio().get('https://travelarkbackend.onrender.com/api/getAllBus');
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

  void _filterBusData(String query) {
    setState(() {
      _filteredBusData = _busData
          .where((bus) =>
          bus['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0, // Set elevation to 0
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
                  onChanged: _filterBusData,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          toolbarHeight: 120, // Set the height of the toolbar
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
            List<Map<String, dynamic>> displayData =
            _filteredBusData.isNotEmpty ? _filteredBusData : snapshot.data!;

            return ListView.builder(
              itemCount: displayData.length,
              itemBuilder: (context, index) {
                final bus = displayData[index];
                int occupancy = bus['passengerIds'].length;
                int availableSeats = occupancy >= 30 ? 0 : 30 - occupancy;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      bus['name'].toString(),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Occupancy: $occupancy'),
                        Text('Available Seats: $availableSeats'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () async {
                        final List<Map<String, dynamic>> passengerData =
                        await fetchPassengerData(
                            List<String>.from(bus['passengerIds']));
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
              },
            );
          }
        },
      ),
    );
  }
}


class DetailedInfoPage extends StatelessWidget {
  final String busName;
  final List<Map<String, dynamic>> passengerData;

  const DetailedInfoPage({
    Key? key,
    required this.busName,
    required this.passengerData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed Info - $busName'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        toolbarHeight: 100,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Passenger List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: passengerData.length,
              itemBuilder: (context, index) {
                final passenger = passengerData[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      'Passenger Name: ${passenger['name']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${passenger['rfid']}'),
                        Text('Stopping: ${passenger['stopping']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}