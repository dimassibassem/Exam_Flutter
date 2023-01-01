import 'package:cloud_firestore/cloud_firestore.dart';
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
  } catch (e) {
    print(e);
  }
}

var _listDishes = [];

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
    final listDishes = _listDishes;

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
                    onPressed: () {
                      // todo : add to favorites
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

