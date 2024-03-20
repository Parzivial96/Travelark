import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double currentZoom = 10.0;
  late StreamController<List<Map<String, dynamic>>> _locationStreamController;
  late Future<List<Map<String, dynamic>>> _geolocationFuture;
  LatLng? _userLocation;
  List<Marker> _markers = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _locationStreamController = StreamController<List<Map<String, dynamic>>>();
    _geolocationFuture = fetchGeolocationData();
    // Start fetching data continuously
    fetchDataContinuously();
    _getUserLocation(); // Get user location when the app starts
  }

  @override
  void dispose() {
    _locationStreamController.close();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchGeolocationData() async {
    final response = await http.get(
        Uri.parse('https://travelarkbackend.onrender.com/api/getAllBus'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load geolocation data');
    }
  }

  Future<void> fetchDataContinuously() async {
    while (true) {
      try {
        // Fetch data
        final List<Map<String, dynamic>> newData = await fetchGeolocationData();
        // Add data to stream
        _locationStreamController.add(newData);
      } catch (e) {
        print('Error fetching data: $e');
      }
      // Wait for some time (adjust as needed)
      await Future.delayed(Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TravelArk', style: TextStyle(fontFamily: "Popins", fontSize: 26),),
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _locationStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle errors
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // No data received yet
            return Center(child: Text('No data available'));
          } else {
            // Display map with markers
            return FlutterMap(
              mapController: _mapController, // Use the map controller
              options: MapOptions(
                center: _userLocation != null
                    ? _userLocation!
                    : LatLng(11.914060, 79.810745),
                zoom: _userLocation != null ? 16.0 : 6.0,
                onPositionChanged: (MapPosition position, bool hasGesture) {
                  setState(() {
                    currentZoom = position.zoom!;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ...snapshot.data!
                        .map(
                          (bus) {
                        final List<dynamic> location = bus['location'];
                        final LatLng busLocation = LatLng(location[0], location[1]);
                        final String busName = bus['name'];

                        // TODO: Calculate time difference

                        return Marker(
                          point: busLocation,
                          child: GestureDetector(
                            onTap: () {
                              // Show tooltip when marker is tapped
                              final RenderBox renderBox = context.findRenderObject() as RenderBox;
                              final Offset localOffset = renderBox.localToGlobal(Offset.zero);
                              final Offset tapPosition = localOffset.translate(20.0, 60.0); // Adjust the vertical offset as needed

                              showTooltip(context, tapPosition, busName, bus['history'].last['passengerIds'].length);
                            },
                            child: Image(
                              image: AssetImage("asset/images/bus.png"),
                              width: 40,
                              height: 40,
                            ),
                          ),
                          width: currentZoom*3,
                          height: currentZoom*3,
                        );
                      },
                    )
                        .toList(),
                  ],
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () {
            // Add your logic to find the user's location
            _getUserLocation();
          },
          child: Icon(Icons.location_searching,color: Colors.white,),
          backgroundColor: Colors.black87,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void showTooltip(BuildContext context, Offset tapPosition, String busName, int occupancy) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: tapPosition.dx,
        top: tapPosition.dy,
        child: Tooltip(
          message: 'Occupancy: $occupancy passengers',
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Text(busName, style: TextStyle(color: Colors.white, fontFamily: 'Popins', fontSize: 16,decoration: TextDecoration.none)),
                SizedBox(height: 2.0),
                Text('Occupancy: $occupancy passengers', style: TextStyle(color: Colors.white, fontFamily: 'Popins', fontSize: 16,decoration: TextDecoration.none)),
                SizedBox(height: 2.0),
                IconButton(
                  onPressed: () {
                    overlayEntry?.remove(); // Close the tooltip when the button is pressed
                  },
                  icon: Icon(Icons.close,color: Colors.white,),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(overlayEntry);

    // Close the tooltip after a delay (adjust as needed)
    Future.delayed(Duration(seconds: 10), () {
      overlayEntry?.remove();
    });
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _markers = [
        Marker(
          point: _userLocation!,
          child: Icon(
            Icons.my_location_sharp,
            color: Colors.blue,
          ),
        ),
      ];

      // Zoom to the user's location
      _mapController.move(_userLocation!, 16.0);
    });
  }
}
