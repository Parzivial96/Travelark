import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _rfidController = TextEditingController();
  String _selectedRole = 'Passenger'; // Default role
  bool _isLoading = false;
  late Map<String, dynamic> _passengerData = {};
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>(); // Form key for input validation

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _rfidController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> userData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'rfid': _rfidController.text,
        'role': _selectedRole,
      };

      final Uri apiUrl =
          Uri.parse('https://travelarkbackend.onrender.com/api/addPassenger');

      final response = await http.post(
        apiUrl,
        body: json.encode(userData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _passengerData = json.decode(response.body);
          _resetFields();
        });
        _showSuccessDialog();
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(response.reasonPhrase as String);
      }
    }
  }

  void _resetFields() {
    _nameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _rfidController.clear();
    setState(() {
      _selectedRole = 'Passenger';
    });
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Created Successfully'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${_passengerData['id']}'),
              Text('Name: ${_passengerData['name']}'),
              Text('Phone: ${_passengerData['phone']}'),
              Text('Role: ${_passengerData['role']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add User',
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Assigning form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _rfidController,
                decoration: InputDecoration(
                  labelText: 'RFID',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an RFID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                items: <String>['Admin', 'Passenger', 'Driver']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: TextStyle(fontFamily: 'popins',fontWeight: FontWeight.w500),),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          'Sign Up',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Popins'),
                        ),
                  style: ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(Size(150, 50)),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
