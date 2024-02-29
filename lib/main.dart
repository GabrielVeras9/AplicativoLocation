import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Sender',
      home: LocationSender(),
    );
  }
}

class LocationSender extends StatefulWidget {
  @override
  _LocationSenderState createState() => _LocationSenderState();
}

class _LocationSenderState extends State<LocationSender> {
  Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _startSendingLocation();
  }

  void _startSendingLocation() {
    _locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      _sendLocation(currentLocation);
    });
    Timer.periodic(Duration(seconds: 30), (timer) {
      _sendLocation(null); // Send last known location
    });
  }

  Future<void> _sendLocation(LocationData? locationData) async {
    // Replace "http://localhost:8080/servico/prestado/adicionar" with your actual endpoint
    final String url = "http://192.168.1.101:8080/servico/prestado/adicionar";

    // Forming the payload
    Map<String, dynamic> data = {
      'latitude': locationData?.latitude,
      'longitude': locationData?.longitude,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        print("Location sent successfully!");
      } else {
        print("Failed to send location. Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending location: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _locationSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Sender'),
      ),
      body: Center(
        child: Text(
          'Sending location data...',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}