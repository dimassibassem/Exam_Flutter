import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_session_manager/flutter_session_manager.dart';

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

  Future<void> getCurrentUser() async {
    try {
      currentUser = await SessionManager().get('email');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();

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
