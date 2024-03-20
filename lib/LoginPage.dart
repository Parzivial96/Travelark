import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:travelark_app/Mapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    // Check if input fields are empty
    if (_phoneNumberController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both phone number and password'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://travelarkbackend.onrender.com/api/login'),
      body: jsonEncode({
        'phone': _phoneNumberController.text,
        'password': _passwordController.text,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      // Check if response body is empty
      if (response.body.isEmpty) {
        print('Invalid login credentials');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid login credentials'),
          ),
        );
      } else {
        final passengerData = jsonDecode(response.body);
        print('Login successful. Passenger data: $passengerData');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('passengerData', jsonEncode(passengerData));
        await prefs.setBool('isLoggedIn', true); // Set login flag
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Mapper()));
      }
    } else {
      print('Login failed. Status code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Set to false to prevent resizing
      appBar: AppBar(
        title: Text('Welcome to TravelArk', style: TextStyle(fontFamily: "Popins", fontSize: 26),),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust vertical padding here
        child: Column(
          children: [
            Image.asset("asset/images/login.png"),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _login(context),
              child: _isLoading ? CircularProgressIndicator() : const Text('Login', style: TextStyle(color: Colors.white,fontFamily: 'Popins'),),
              style: ButtonStyle(fixedSize: MaterialStatePropertyAll(Size(150, 50)),backgroundColor: MaterialStatePropertyAll(Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}
