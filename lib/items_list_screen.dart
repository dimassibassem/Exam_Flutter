import 'package:flutter/material.dart';

class Movie {
  final String title;
  final String director;
  final String posterUrl;

  Movie({
    required this.title,
    required this.director,
    required this.posterUrl,
  });
}

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({Key? key}) : super(key: key);

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  final List<Movie> _listMovies = [
    Movie(
      title: "The Shawshank Redemption",
      director: "Frank Darabont",
      posterUrl:
          "https://upload.wikimedia.org/wikipedia/en/8/81/ShawshankRedemptionMoviePoster.jpg",
    ),
    Movie(
      title: "The Godfather",
      director: "Francis Ford Coppola",
      posterUrl:
          "https://upload.wikimedia.org/wikipedia/en/1/1c/Godfather_ver1.jpg",
    ),
    Movie(
      title: "The Godfather: Part II",
      director: "Francis Ford Coppola",
      posterUrl:
          "https://upload.wikimedia.org/wikipedia/en/0/03/Godfather_part_ii.jpg",
    ),
    Movie(
      title: "The Dark Knight",
      director: "Christopher Nolan",
      posterUrl:
          "https://upload.wikimedia.org/wikipedia/en/1/1c/The_Dark_Knight_%282008_film%29.jpg",
    ),
    Movie(
      title: "12 Angry Men",
      director: "Sidney Lumet",
      posterUrl:
          "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/12_Angry_Men_%281957_film_poster%29.jpg/440px-12_Angry_Men_%281957_film_poster%29.jpg",
    ),
    Movie(
      title: "Schindler's List",
      director: "Steven Spielberg",
      posterUrl:
          "https://upload.wikimedia.org/wikipedia/en/3/38/Schindler%27s_List_movie.jpg",
    ),
    Movie(
      title: "The Lord of the Rings: The Return of the King",
      director: "Peter Jackson",
      posterUrl:
          "https://upload.wikimedia.org/wikipedia/en/b/be/The_Lord_of_the_Rings_-_The_Return_of_the_King_%282003%29.jpg",
    ),
    Movie(
      title: "Pulp Fiction",
      director: "Quentin Tarantino",
      posterUrl:
          "https://upload.wikimedia.org/wikipedia/en/3/3b/Pulp_Fiction_%281994%29_poster.jpg",
    ),
    Movie(
      title: "The Good, the Bad and the Ugly",
      director: "Sergio Leone",
      posterUrl:
          "https://upload.wikimedia.org/wikipedia/en/4/45/Good_the_bad_and_the_ugly_poster.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies List'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            shrinkWrap: false,
            itemCount: _listMovies.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: Image.network(
                    _listMovies[index % _listMovies.length].posterUrl,
                    width: 50,
                  ),
                  title: Text(_listMovies[index % _listMovies.length].title),
                  subtitle:
                      Text(_listMovies[index % _listMovies.length].director),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
