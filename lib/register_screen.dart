import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

Future<void> addUser(email, password, dropDownSelectedValue, context) async {
  await FirebaseFirestore.instance
      .collection('users')
      .add(
          {'email': email, 'password': password, 'role': dropDownSelectedValue})
      .then((value) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ))
      .catchError((error) => print("Failed to add user: $error"));
}

Future<void> registerUser(String email, String password,
    String dropDownSelectedValue, context) async {
  try {
    await addUser(email, password, dropDownSelectedValue, context);
  } catch (error) {
    print(error.toString());
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  String email = '';
  String password = '';

  String _dropDownSelectedValue = 'user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Register",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: _dropDownSelectedValue,
                items: ['admin', 'user'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _dropDownSelectedValue = value!;
                  });
                },
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  await registerUser(
                      email, password, _dropDownSelectedValue, context);
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
