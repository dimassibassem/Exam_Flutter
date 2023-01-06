import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'admin_options.dart';

class Dish {
  final String dish;
  final String description;

  Dish({
    required this.dish,
    required this.description,
  });
}

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

class _ItemsListScreenState extends State<ItemsListScreen> {
var _listDishes = [];
  @override
  void initState() {
    super.initState();
    try {
       getDishes().then((value) {
         setState(() {
           _listDishes = value;
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
    final listDishes = _listDishes;

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
                    builder: (context) => const AdminOptionsScreen(),
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
              title: Text('Add Dishes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItemScreen(),
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
            itemCount: listDishes.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(listDishes[index % listDishes.length].dish),
                  subtitle:
                      Text(listDishes[index % listDishes.length].description),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditDishScreen(dish: listDishes[index]),
                        ),
                      );
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

class EditDishScreen extends StatelessWidget {
  EditDishScreen({super.key, required this.dish});

  final Dish dish;

  Future<void> updateDish(dish, newDishTitle, description) async {
    await FirebaseFirestore.instance
        .collection('dishes')
        .where('dish', isEqualTo: dish)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({
          'dish': newDishTitle,
          'description': description,
        });
      });
    });
  }

  final dishTitleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Dish'),
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
                    builder: (context) => const AdminOptionsScreen(),
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
              title: Text('Add Dishes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItemScreen(),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Edit ${dish.dish}",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: dishTitleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Dish Title',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await deleteDish(dish.dish);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: const Text('Delete Dish'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await updateDish(
                        dish.dish,
                        dishTitleController.text,
                        descriptionController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Update dish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> deleteDish(dish) async {
  await FirebaseFirestore.instance
      .collection('dishes')
      .where('dish', isEqualTo: dish)
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      doc.reference.delete();
    });
  });
}
