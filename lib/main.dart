import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recherche de Films',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieSearchPage(),
    );
  }
}

class MovieSearchPage extends StatefulWidget {
  @override
  _MovieSearchPageState createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List movies = [];
  bool isLoading = false;

  // Remplacez YOUR_API_KEY par votre clé API obtenue depuis OMDb API
  String apiKey = 'b532d5c3';

  // Méthode pour appeler l'API OMDb et récupérer les films
  Future<void> fetchMovies(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final url = 'https://www.omdbapi.com/?s=$query&apikey=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map result = json.decode(response.body);
      setState(() {
        movies = result['Search'] ?? [];
      });
    } else {
      setState(() {
        movies = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche de Films'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Champ de texte pour la recherche
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Titre du film',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    fetchMovies(_controller.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                fetchMovies(value);
              },
            ),
            SizedBox(height: 16.0),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : movies.isEmpty
                    ? Text('Aucun film trouvé')
                    : Expanded(
                        child: ListView.builder(
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            return Card(
                              child: ListTile(
                                leading: movie['Poster'] != 'N/A'
                                    ? Image.network(movie['Poster'])
                                    : Icon(Icons.movie),
                                title: Text(movie['Title']),
                                subtitle: Text(movie['Year']),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MovieDetailPage(movie: movie),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class MovieDetailPage extends StatelessWidget {
  final Map movie;

  MovieDetailPage({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['Title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            movie['Poster'] != 'N/A'
                ? Image.network(movie['Poster'])
                : Icon(Icons.movie, size: 100),
            SizedBox(height: 16.0),
            Text(
              'Titre: ${movie['Title']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Année: ${movie['Year']}'),
            Text('Type: ${movie['Type']}'),
          ],
        ),
      ),
    );
  }
}
