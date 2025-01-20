import 'package:flutter/material.dart';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:flutter_application_1/JsonModels/users.dart';

class UserViewScreen extends StatefulWidget {
  @override
  UserViewScreenState createState() => UserViewScreenState();
}

class UserViewScreenState extends State<UserViewScreen> {
  late DatabaseHelper handler;
  late Future<List<Users>> users;
  List<Users> _users = []; // To store the list of users
  bool _isLoading = true; // To manage loading state
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    fetchAndPrintAllUsers(); // Fetch users when the widget is initialized
  }

  Future<void> fetchAndPrintAllUsers() async {
    List<Users> users = await db.getAllUsers();

    // Update the state with the fetched user data
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Lists'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text('Email: ${user.usrEmail}'),
                  subtitle: Text('Password: ${user.usrPassword}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      db.deleteUser(user.usrId!).whenComplete(() {
                        fetchAndPrintAllUsers(); // Refresh the user list
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
