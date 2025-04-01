import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ginraidee/api/fetch_recipe_api.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeItem recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isFavorite = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  // Check if the recipe is marked as favorite in Firebase Firestore
  Future<void> _checkIfFavorite() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String recipeId = widget.recipe.recipeUrl.replaceAll(RegExp(r'\/+'), '-');
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(recipeId) // Use sanitized recipeUrl as unique ID
        .get();

    setState(() {
      _isFavorite = doc.exists; // If the document exists, it's a favorite
    });
  }

  // Toggle favorite status in Firestore
  Future<void> _toggleFavorite() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Sanitize recipeUrl to avoid invalid Firestore path
    String recipeId = widget.recipe.recipeUrl
        .replaceAll(RegExp(r'\/+'), '-'); // Replace slashes with a dash

    // Immediately update UI before Firestore operation
    setState(() {
      _isFavorite = !_isFavorite; // Toggle the favorite status
    });

    DocumentReference favRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(recipeId);

    if (_isFavorite) {
      // Add to favorites
      await favRef.set({
        'name': widget.recipe.name,
        'imageUrl': widget.recipe.imageUrl,
        'calories': widget.recipe.calories,
        'source': widget.recipe.source,
        'recipeUrl': widget.recipe.recipeUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Remove from favorites
      await favRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.yellow : null,
            ),
            onPressed: _toggleFavorite, // Toggle favorite
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.recipe.imageUrl),
              const SizedBox(height: 16),
              Text(widget.recipe.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  "Calories: ${widget.recipe.calories.toStringAsFixed(1)} kcal"),
              const SizedBox(height: 8),
              Text("Source: ${widget.recipe.source}"),
              const SizedBox(height: 16),
              Text("Ingredients:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var ingredient in widget.recipe.ingredients)
                Text("- $ingredient"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _launchURL(widget.recipe.recipeUrl),
                child: Text("View Full Recipe"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to launch URL
  void _launchURL(String url) async {
    if (url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true) {
      // Uncomment below if you use a package like url_launcher
      // if (await canLaunch(url)) {
      //   await launch(url, forceSafariVC: false, forceWebView: false);
      // } else {
      //   throw 'Could not launch $url';
      // }
    } else {
      throw 'Invalid URL: $url';
    }
  }
}
