import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/food_detail_screen.dart';
import 'package:flutter_application_1/api/fetch_recipe_api.dart'; // Ensure this is correctly set up

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> _favoriteRecipes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Load favorite recipes from Firestore
  Future<void> _loadFavorites() async {
    var user = _auth.currentUser;
    if (user == null) return;

    // Fetch favorite recipes from Firestore
    var snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    List<Map<String, dynamic>> favoriteRecipes = [];
    for (var doc in snapshot.docs) {
      favoriteRecipes.add(doc.data());
    }

    setState(() {
      _favoriteRecipes = favoriteRecipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite Recipes')),
      body: _favoriteRecipes.isEmpty
          ? Center(child: Text('No favorite recipes yet'))
          : ListView.builder(
              itemCount: _favoriteRecipes.length,
              itemBuilder: (context, index) {
                var recipe = _favoriteRecipes[index];
                return ListTile(
                  leading: recipe['imageUrl'] != null
                      ? Image.network(recipe['imageUrl'], width: 50, height: 50)
                      : Icon(Icons.image, size: 50),
                  title: Text(recipe['label'] ?? 'Unknown Recipe'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
