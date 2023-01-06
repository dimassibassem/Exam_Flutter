import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:tp_flutter_3/user_options.dart';
import 'user_list_screen.dart';

class Dish {
  final String dish;
  final String description;

  Dish({
    required this.dish,
    required this.description,
  });
}

var currentUser = '';

Future<void> getCurrentUser() async {
  try {
    currentUser = await SessionManager().get('email');
  } catch (e) {
    print(e);
  }
}

class FavoriteItemsListScreen extends StatefulWidget {
  const FavoriteItemsListScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteItemsListScreen> createState() => _FavoriteItemsListScreen();
}

Future<List> getFavDishes() async {
  var fetchedFavorites = [];
  var fetchedFavoritesNames = [];
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser)
        .get()
        .then((QuerySnapshot querySnapshot) async {
        fetchedFavoritesNames = querySnapshot.docs[0]['favorites'];
       await FirebaseFirestore.instance
            .collection('dishes')
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            if (fetchedFavoritesNames.contains(doc['dish'])) {
              fetchedFavorites.add(Dish(
                dish: doc['dish'],
                description: doc['description'],
              ));
            }
          }
          return fetchedFavorites;
        });
    });
  } catch (e) {
    print(e);
  }
  return fetchedFavorites;
}

class _FavoriteItemsListScreen extends State<FavoriteItemsListScreen> {
  var _listFavorites = [];
  @override
  void initState() {
    super.initState();
    try {
      getCurrentUser();
      getFavDishes().then((value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Dishes List'),
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
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              title: Text('Home'),
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
              title: Text('Dishes'),
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
              title: Text('Favorite Dishes'),
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
              title: Text('Logout'),
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
            itemCount: _listFavorites.length,
            itemBuilder: (context, index) {
              if (_listFavorites.isNotEmpty) {
                return Card(
                  child: ListTile(
                    title: Text(
                        _listFavorites[index % _listFavorites.length].dish),
                    subtitle: Text(_listFavorites[index % _listFavorites.length]
                        .description),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite),
                      color: Colors.red,
                      onPressed: () async{
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: currentUser)
                            .get()
                            .then((QuerySnapshot querySnapshot) async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(querySnapshot.docs[0].id)
                              .update({
                            'favorites': FieldValue.arrayRemove([
                              _listFavorites[index % _listFavorites.length].dish
                            ])
                          });
                        });
                        setState(() {
                          _listFavorites.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }
              return const Center(
                child: Text('No favorites yet'),
              );
            },
          ),
        ),
      ),
    );
  }
}

