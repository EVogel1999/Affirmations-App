import 'dart:convert';
import 'package:affirmations_app/favorites.dart';
import 'package:affirmations_app/types/Affirmation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Affirmations',
      home: HomePage(title: 'Daily Affirmations'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Affirmation> affirmation;

  IconData _icon = Icons.favorite_border;

  String _currentAffirmation;
  final _favorites = Set<String>();

  /// Inits the state of the home page
  @override
  void initState() {
    super.initState();
    // On state init, load the first affirmation
    this.affirmation = fetchAffirmation();
  }

  /// Make an HTTP request to the affirmations API to get an affirmation
  Future<Affirmation> fetchAffirmation() async {
    final response = await http.get('https://www.affirmations.dev/');
    Affirmation result;

    // Check the status of the http request for errors
    switch (response.statusCode) {
      case 200:
        result = Affirmation.fromJson(json.decode(response.body));
        break;
      default:
        throw new Exception('Error getting affirmation from API');
    }

    // Set the favorite icon if it is an already favorite affirmation
    setState(() {
      _icon = _favorites.contains(result.affirmation) ? Icons.favorite : Icons.favorite_border;
    });

    return result;
  }

  /// Builds the bottom button menu which holds the refresh, favorite, and favorite
  /// list menu icon buttons
  Widget buildButtonMenu() {
    return Container(
      color: Colors.black12,
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'Reload Affirmation',
              onPressed: () {
                setState(() {
                  // Reset the values to default state and fetch new affirmation
                  _icon = Icons.favorite_border;
                  _currentAffirmation = null;
                  affirmation = null;
                  this.affirmation = fetchAffirmation();
                });
              }
          ),
          IconButton(
            icon: Icon(_icon),
            tooltip: 'Like current affirmation',
            onPressed: () {
              setState(() {
                // Add/remove the current affirmation from the list
                if (!_favorites.contains(_currentAffirmation)) {
                  _icon = Icons.favorite;
                  _favorites.add(_currentAffirmation);
                } else {
                  _icon = Icons.favorite_border;
                  _favorites.remove(_currentAffirmation);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'See liked affirmations',
            onPressed: () {
              setState(() {
                // Navigate to the favorites list
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage(_favorites))
                ).then((value) {
                  setState(() {
                    // When navigating back to the home page, check if the current
                    // affirmation was removed from the favorites list
                    if (!_favorites.contains(_currentAffirmation)) {
                      _icon = Icons.favorite_border;
                    }
                  });
                });
              });
            },
          )
        ],
      ),
    );
  }

  /// Builds the current affirmation display using the FutureBuilder widget
  Widget buildAffirmation() {
    // Use Expanded to make the current affirmation take up the whole screen
    // minus the button bar
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<Affirmation>(
          future: affirmation,
          builder: (context, snapshot) {
            _currentAffirmation = null;

            // If the snapshot has data, set the new affirmation
            if (snapshot.hasData) {
              _currentAffirmation = snapshot.data.affirmation;
              return Text(_currentAffirmation, textAlign: TextAlign.center,);
            }
            // If the snapshot encountered an error, set to error message
            if (snapshot.hasError) {
                return Text(snapshot.error.toString());
            }

            // If we don't have any data, show a progress indicator
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  /// Builds the homepage: current affirmation and bottom button bar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            buildAffirmation(),
            buildButtonMenu(),
          ],
        ),
      ),
    );
  }
}
