import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  final Set<String> _favorites;

  FavoritesPage(this._favorites);

  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  /// Checks the current favorites list and chooses which screen to display
  Widget _buildScreen() {
    if (widget._favorites.length > 0) {
      return _buildFavoritesList();
    }
    return _buildNoFavorites();
  }

  /// Builds the no favorites list view
  Widget _buildNoFavorites() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.favorite, color: Colors.red),
        Container(
          margin: EdgeInsets.all(16.0),
          child: Text(
            'You have no favorites. Like something to see it on this page!',
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  /// Builds the favorites list view
  Widget _buildFavoritesList() {
    List<Widget> result = [];

    widget._favorites.forEach((element) {
      result.add(
          ListTile(
            title: Text(element),
            trailing: IconButton(
              icon: Icon(Icons.favorite),
              color: Colors.red,
              tooltip: 'Remove from favorites',
              onPressed: () {
                setState(() {
                  // Remove selected favorite on button tap
                  widget._favorites.remove(element);
                });
              },
            ),
          ));
    });
    
    return ListView(children: result, padding: EdgeInsets.fromLTRB(0, 16, 0, 16),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.cyan,
      ),
      body: _buildScreen()
    );
  }
}