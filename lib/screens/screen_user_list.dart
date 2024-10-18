import 'package:admin/screens/screen_data_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screen_user_details_data.dart'; // Make sure this import points to the correct file

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final users = [
      {'name': 'User 1', 'phoneNumber': '123-456-7890'},
      {'name': 'User 2', 'phoneNumber': '987-654-3210'},
      {'name': 'User 3', 'phoneNumber': '555-555-5555'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Users',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Column(
                children: users.map((user) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 2, child: Text(user['name']!, style: TextStyle(fontSize: 16))),
                        Expanded(flex: 2, child: Text(user['phoneNumber']!, style: TextStyle(fontSize: 16))),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              // Pass the user ID (or name in this case) to UserDataScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDataScreen(userId: user['name']!), // Passing user name
                                ),
                              );
                            },
                            child: Text('View Data'),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
