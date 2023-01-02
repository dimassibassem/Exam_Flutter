import 'package:flutter/material.dart';
import 'user_list_screen.dart';
class UserOptionsScreen extends StatefulWidget {
  const UserOptionsScreen({Key? key}) : super(key: key);

  @override
  _UserOptionsScreen createState() => _UserOptionsScreen();
}


class _UserOptionsScreen extends State<UserOptionsScreen> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Options'),
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
                child: const Text("Favorite Items"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
