import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user.dart';
import '../../user_details_screen.dart';
import '../../../controllers/controller_user.dart';

class UserDetailsTable extends StatefulWidget {
  @override
  _UserDetailsTableState createState() => _UserDetailsTableState();
}

class _UserDetailsTableState extends State<UserDetailsTable> {
  final UserController controller = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data on initialization
  }

  void _fetchData() {
    controller.fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[800],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 400, // Adjust this height as needed
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.usersList.isEmpty) {
                return Center(
                  child: Text(
                    "No user data available.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView(
                children: [
                  DataTable(
                    columnSpacing: 16.0,
                    columns: const [
                      DataColumn(label: Text("Profile", style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Name", style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Address", style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Employee ID", style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Delete", style: TextStyle(color: Colors.white))),
                    ],
                    rows: List.generate(
                      controller.usersList.length,
                          (index) {
                        var userInfo = controller.usersList[index];
                        return userDataRow(userInfo, context);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Helper Functions
DataRow userDataRow(User userInfo, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(
        GestureDetector(
          onTap: () {
            log("User ID: ${userInfo.userId}");
            Get.to(() => UserDetailsScreen(userId: userInfo.userId.toString()));
          },
          child: CircleAvatar(
            radius: 20,
            child: userInfo.imageUrl != null && userInfo.imageUrl!.isNotEmpty
                ? ClipOval(
              child: Image.network(
                userInfo.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/profile_pic.png', fit: BoxFit.cover);
                },
              ),
            )
                : Image.asset('assets/images/profile_pic.png', fit: BoxFit.cover),
          ),
        ),
      ),
      DataCell(Text(userInfo.userName ?? "N/A", style: TextStyle(color: Colors.white))),
      DataCell(Text(userInfo.userAddress ?? "N/A", style: TextStyle(color: Colors.white))),
      DataCell(Text(userInfo.employeeId ?? "N/A", style: TextStyle(color: Colors.white))),
      DataCell(
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () {
            _showDeleteConfirmationDialog(context, userInfo);
          },
        ),
      ),
    ],
  );
}

void _showDeleteConfirmationDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.userName}?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              Get.find<UserController>().removeUserFromFirestore(user.userId!);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
