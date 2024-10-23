import 'dart:developer';
import 'package:admin/controllers/controller_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user.dart';
import '../../user_details_screen.dart';

class UserDetailsTable extends StatelessWidget {
  UserDetailsTable({Key? key}) : super(key: key);

  final UserController controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    controller.fetchAllUsers();
    log("User Data =  ${controller.usersList}");

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

// Modify userDataRow to accept a User object
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
            _showUserOptionsDialog(context, userInfo);
          },
        ),
      ),
    ],
  );
}

// Show dialog with options to edit or delete user
void _showUserOptionsDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text('You are going to delete ${user.userName}'),
        actions: [
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _showDeleteConfirmationDialog(context, user);
            },
          ),
        ],
      );
    },
  );
}

// Show edit user dialog
// void _showEditUserDialog(BuildContext context, User user) {
//   TextEditingController nameController = TextEditingController(text: user.userName);
//   TextEditingController addressController = TextEditingController(text: user.userAddress);
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Edit User'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: addressController,
//               decoration: InputDecoration(labelText: 'Address'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             child: Text('Cancel'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text('Save'),
//             onPressed: () {
//               // User updatedUser = user.copyWith(
//               //   userName: nameController.text,
//               //   userAddress: addressController.text,
//               // );
//               // Get.find<UserController>().updateUserInFirestore(updatedUser);
//               Navigator.of(context).pop(); // Close the dialog after saving
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// Show delete confirmation dialog
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
