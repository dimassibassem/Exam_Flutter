import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:tp_flutter_3/user_favorite_dishes_screen.dart';
import 'package:tp_flutter_3/user_options.dart';

import 'main.dart';

class Dish {
  final String dish;
  final String description;

  Dish({
    required this.dish,
    required this.description,
  });
}

var currentUser = '';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({Key? key}) : super(key: key);

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

Future<List> getDishes() async {
  final fetchedDishes = [];
  try {
  await FirebaseFirestore.instance
        .collection('dishes')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        fetchedDishes.add(Dish(
          dish: doc['dish'],
          description: doc['description'],
        ));
      }
      return fetchedDishes;
    });
  } catch (e) {
    print(e);
  }
  return fetchedDishes;
}

Future<List> getCurrentUserFavorites() async {
  var fetchedFavorites = [];
  try {
   await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        fetchedFavorites = querySnapshot.docs[0]['favorites'];
      }
    });
  } catch (e) {
    print(e);
  }
  return fetchedFavorites;
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  var _listDishes = [];
  var _listFavorites = [];

  @override
  void initState() {
    super.initState();
    try {
      getDishes().then((value) {
        setState(() {
          _listDishes = value;
        });
      });
      getCurrentUserFavorites().then((value) {
        setState(() {
          _listFavorites = value;
        });
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      print(error.toString());
    }
  }

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

  @override
  Widget build(BuildContext context) {
    getCurrentUser(context);

    final listDishes = _listDishes;
    final listFavorites = _listFavorites;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dishes List'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await SessionManager().set("email", "");
                Navigator.of(context).pushReplacementNamed('/');
              }
          ),
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
          child: ListView.builder(
            shrinkWrap: false,
            itemCount: listDishes.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(listDishes[index % listDishes.length].dish),
                  subtitle:
                      Text(listDishes[index % listDishes.length].description),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite),
                    color: listFavorites.contains(
                            listDishes[index % listDishes.length].dish)
                        ? Colors.red
                        : Colors.grey,
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: currentUser)
                          .get()
                          .then((QuerySnapshot querySnapshot) async {
                        if (listFavorites.contains(
                            listDishes[index % listDishes.length].dish)) {
                         await FirebaseFirestore.instance
                              .collection('users')
                              .doc(querySnapshot.docs[0].id)
                              .update({
                            'favorites': FieldValue.arrayRemove(
                                [listDishes[index % listDishes.length].dish])
                          });
                          listFavorites.remove(
                              listDishes[index % listDishes.length].dish);
                          setState(() {
                            _listFavorites = listFavorites;
                          });
                        } else {
                         await FirebaseFirestore.instance
                              .collection('users')
                              .doc(querySnapshot.docs[0].id)
                              .update({
                            'favorites': FieldValue.arrayUnion(
                                [listDishes[index % listDishes.length].dish])
                          });
                          listFavorites
                              .add(listDishes[index % listDishes.length].dish);
                          setState(() {
                            _listFavorites = listFavorites;
                          });
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
