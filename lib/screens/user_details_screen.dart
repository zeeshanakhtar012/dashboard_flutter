import 'dart:developer';

import 'package:admin/main.dart';
import 'package:admin/screens/screen_add_users.dart';
import 'package:admin/screens/screen_update_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/controller_user.dart';

class UserDetailsScreen extends StatelessWidget {
  final String userId;
  final UserController controller = Get.find<UserController>();

  UserDetailsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // App bar color
      ),
      body: Obx(() {
        // Display loading indicator while data is being fetched
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // Find the user data based on userId
        var userData = controller.usersList.firstWhereOrNull((user) => user.userId == userId);

        // If user is not found
        if (userData == null) {
          return Center(
            child: Text("User not found", style: TextStyle(fontSize: 20, color: Colors.red)),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24.0), // Padding for the entire body
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundImage: userData.imageUrl != null && userData.imageUrl!.isNotEmpty
                        ? NetworkImage("${userData.imageUrl}")
                        : AssetImage('assets/default_avatar.png') as ImageProvider, // Default avatar
                    radius: 50,
                  ),
                ),
                SizedBox(height: 20), // Space between avatar and details
            
                // User details in styled containers
                _buildDetailContainer("Name", userData.userName ?? 'N/A'),
                _buildDetailContainer("Phone No", userData.phoneNumber ?? 'N/A'),
                _buildDetailContainer("Address", userData.userAddress ?? 'N/A'),
                _buildDetailContainer("FID", userData.fid ?? 'N/A'),
                _buildDetailContainer("MBU", userData.mbu ?? 'N/A'),
                _buildDetailContainer("Region", userData.region ?? 'N/A'),
                _buildDetailContainer("Employee Id", userData.employeeId ?? 'N/A'),
            
                SizedBox(height: 24), // Space before the button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      log("User id == ${userData.userId}");
                      Get.to(ScreenUpdateUser(userID: userData.userId.toString(),));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text("Update User Data"),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Helper method to create detail containers
  Widget _buildDetailContainer(String label, String value) {
    return Container(
      // width: Get.width*.6,
      // height: 70.h,
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Margin between containers
      padding: const EdgeInsets.all(16.0), // Padding inside the container
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the container
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // Position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
        ],
      ),
    );
  }
}
