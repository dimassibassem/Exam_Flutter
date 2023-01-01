import 'package:flutter/material.dart';
import 'items_list_screen.dart';
class AdminOptionsScreen extends StatefulWidget {
  const AdminOptionsScreen({Key? key}) : super(key: key);

  @override
  _AdminOptionsScreen createState() => _AdminOptionsScreen();
}

class _AdminOptionsScreen extends State<AdminOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Options'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ItemsListScreen(),
                    ),
                  );
                },
                child: const Text("Show Items"),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Add Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
