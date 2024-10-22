import 'package:admin/screens/screen_data_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/controller_user.dart';

class UserListScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users List'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('List of Users', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Obx(() {
                  if (userController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userController.usersList.isEmpty) {
                    return Center(child: Text('No users found'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: userController.usersList.length,
                      itemBuilder: (context, index) {
                        var user = userController.usersList[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              // onTap: () {
                              //   Get.to(ScreenUserDetails(userId: user.userId.toString()));
                              // },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: user.imageUrl != null
                                        ? NetworkImage(user.imageUrl!)
                                        : NetworkImage("https://cdn-icons-png.flaticon.com/512/149/149071.png"),
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('User: ${user.userName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text('Email: ${user.email}', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String? userId = prefs.getString('userId');

                                      if (userId == null) {
                                        Get.snackbar("Error", "User ID not found. Please log in again.");
                                        return;
                                      }
                                      bool? confirm = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("Download CSV"),
                                          content: Text("Do you want to download the user data?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: Text("Yes"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: Text("No"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await userController.downloadCsv(); // Call the download method
                                      }
                                    },
                                    icon: Icon(Icons.download, color: Colors.blue),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(height: 30),
                          ],
                        );
                      },
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

