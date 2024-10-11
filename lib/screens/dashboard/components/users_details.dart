import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controller_fetch_data.dart';
import '../../user_details_screen.dart';

class UserDetailsTable extends StatelessWidget {
  UserDetailsTable({Key? key}) : super(key: key);

  final ControllerDataManagement controller = Get.put(ControllerDataManagement());

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
            "User Details",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.usersList.isEmpty) {
                return Center(child: Text("No user data available.", style: TextStyle(color: Colors.white)));
              }

              return DataTable(
                columnSpacing: 16.0,
                columns: const [
                  DataColumn(label: Text("Id")),
                  DataColumn(label: Text("Profile")),
                  DataColumn(label: Text("User")),
                  DataColumn(label: Text("Current Location")),
                  DataColumn(label: Text("Position ID")),
                ],
                rows: List.generate(
                  controller.usersList.length,
                      (index) {
                    var userInfo = controller.usersList[index];
                    return userDataRow(userInfo, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

DataRow userDataRow(Map<String, dynamic> userInfo, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(Text(userInfo['id']?.toString() ?? "N/A")),
      DataCell(
        GestureDetector(
          onTap: () {
            Get.to(() => UserDetailsScreen(userId: userInfo['id']));
          },
          child: CircleAvatar(
            backgroundImage: userInfo['images'] != null && userInfo['images'].isNotEmpty
                ? NetworkImage(userInfo['images'][0])
                : AssetImage('assets/images/profile_pic.png'), // Provide a default avatar
            radius: 20,
          ),
        ),
      ),
      DataCell(Text(userInfo['user'] ?? "N/A")), // Adjust according to your data structure
      DataCell(Text(userInfo['currentLocation'] ?? "N/A")),
      DataCell(Text(userInfo['posId'] ?? "N/A")),
    ],
  );
}
