import 'package:admin/screens/screen_update_user_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller_fetch_data.dart';

class UserDetailsScreen extends StatelessWidget {
  final int userId;
  final ControllerDataManagement controller = Get.find();

  UserDetailsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the user data based on userId
    var userData = controller.usersList.firstWhere((user) => user['id'] == userId, orElse: () => {});

    return Scaffold(
      appBar: AppBar(
        title: Text("User Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: userData['images'] != null && userData['images'].isNotEmpty
                  ? NetworkImage(userData['images'][0])
                  : AssetImage('assets/default_avatar.png'), // Provide a default avatar
              radius: 50,
            ),
            SizedBox(height: 16),
            Text("Name: ${userData['retailerName'] ?? 'N/A'}", style: TextStyle(fontSize: 16)),
            Text("Phone No: ${userData['phoneNo'] ?? 'N/A'}", style: TextStyle(fontSize: 16)),
            Text("Address: ${userData['formattedAddress'] ?? 'N/A'}", style: TextStyle(fontSize: 16)),
            Text("Position ID: ${userData['posId'] ?? 'N/A'}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to update screen
                Get.to(() => UpdateUserScreen(userId: userId, initialData: userData));
              },
              child: Text("Update User Data"),
            ),
          ],
        ),
      ),
    );
  }
}
