import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_session_manager/flutter_session_manager.dart';

class Dish {
  final String dish;
  final String description;
  final String photo;

  Dish({
    required this.dish,
    required this.description,
    required this.photo,
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
      // if (querySnapshot.docs.isNotEmpty) {
        fetchedFavoritesNames = querySnapshot.docs[0]['favorites'];
       await FirebaseFirestore.instance
            .collection('dishes')
            .get()
            .then((QuerySnapshot querySnapshot) {
              print("fetchedFavoritesNames");
              print(fetchedFavoritesNames);
          for (var doc in querySnapshot.docs) {
            if (fetchedFavoritesNames.contains(doc['dish'])) {
              fetchedFavorites.add(Dish(
                dish: doc['dish'],
                description: doc['description'],
                photo: doc['photo'],
              ));
            }
          }
          print("fetchedFavorites");
          print(fetchedFavorites);
          return fetchedFavorites;
        });
      // }
      // return fetchedFavorites;
    });
  } catch (e) {
    print(e);
  }
  print("here");
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
        print("value");
        print(value);
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
    // getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dishes List'),
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
                    leading: Image.network(
                      _listFavorites[index % _listFavorites.length].photo,
                      width: 50,
                    ),
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
                          if (querySnapshot.docs.isNotEmpty) {
                            var fetchedFavorites =
                                querySnapshot.docs[0]['favorites'];
                            fetchedFavorites.remove(
                                _listFavorites[index % _listFavorites.length]
                                    .dish);
                          await FirebaseFirestore.instance
                                .collection('users')
                                .doc(querySnapshot.docs[0].id)
                                .update({'favorites': fetchedFavorites});
                          }
                          setState(() {
                            _listFavorites.removeAt(index);
                          });
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
