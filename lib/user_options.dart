import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'main.dart';
import 'user_list_screen.dart';
import 'user_favorite_dishes_screen.dart';

class UserOptionsScreen extends StatefulWidget {
  const UserOptionsScreen({Key? key}) : super(key: key);

  @override
  _UserOptionsScreen createState() => _UserOptionsScreen();
}

var currentUser = '';

Future<void> getCurrentUser(context) async {
  try {
    currentUser = await SessionManager().get('email');
    if (currentUser == '') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  } catch (e) {
    print(e);
  }
}

class _UserOptionsScreen extends State<UserOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    getCurrentUser(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Options'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await SessionManager().set("email", "");
                Navigator.of(context).pushReplacementNamed('/');
              }),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 120,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserOptionsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: const Text('Dishes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ItemsListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: const Text('favorite Dishes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoriteItemsListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await SessionManager().set("email", "");
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoriteItemsListScreen(),
                    ),
                  );
                },
                child: const Text("Favorite Items"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
