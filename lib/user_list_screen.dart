import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({Key? key}) : super(key: key);

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

Future<void> getDishes() async {
  final fetchedDishes = [];
  var fetchedFavorites = [];
  try {
    FirebaseFirestore.instance
        .collection('dishes')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        fetchedDishes.add(Dish(
          dish: doc['dish'],
          description: doc['description'],
          photo: doc['photo'],
        ));
      }
      _listDishes = fetchedDishes;
    });
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      fetchedFavorites = querySnapshot.docs[0]['favorites'];
    });
  } catch (e) {
    print(e);
  }
}

var _listDishes = [];
var _listFavorites = [];

class _ItemsListScreenState extends State<ItemsListScreen> {
  @override
  void initState() {
    super.initState();
    try {
      getDishes();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    final listDishes = _listDishes;
    final listFavorites = _listFavorites;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dishes List'),
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
                  leading: Image.network(
                    listDishes[index % listDishes.length].photo,
                    width: 50,
                  ),
                  title: Text(listDishes[index % listDishes.length].dish),
                  subtitle:
                      Text(listDishes[index % listDishes.length].description),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite),
                    color: listFavorites.contains(
                            listDishes[index % listDishes.length].dish)
                        ? Colors.red
                        : Colors.grey,
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: user!.email)
                          .get()
                          .then((QuerySnapshot querySnapshot) {
                        if (listFavorites.contains(
                            listDishes[index % listDishes.length].dish)) {
                          FirebaseFirestore.instance
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
                          FirebaseFirestore.instance
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
