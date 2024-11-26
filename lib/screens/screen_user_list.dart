import 'dart:developer';
import 'package:admin/screens/screen_data_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/controller_user.dart';
import 'screen_search_user.dart'; // Import the SearchUserScreen

class UserListScreen extends StatefulWidget {
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> with WidgetsBindingObserver {
  final UserController userController = Get.put(UserController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    _fetchData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchData(); // Fetch data when screen resumes
    }
  }

  void _fetchData() {
    userController.fetchAllUsers();
    userController.fetchUserListWithModules();
  }

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
                Text('List of Users', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),

                // Search box
                TextField(
                  controller: searchController,
                  readOnly: true,
                  onTap: () {
                    Get.to(() => SearchUserScreen(searchQuery: searchController.text.trim()))!
                        .then((_) => _fetchData()); // Fetch data when navigating back
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Users',
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
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
                                      Text('${user.userName}',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text('${user.email}', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  Spacer(),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: Colors.blue),
                                    onSelected: (value) async {
                                      await userController.fetchUserData(user.userId.toString());
                                      if (value == 'download') {
                                        await userController.downloadCsv(user.userId.toString());
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        PopupMenuItem<String>(
                                          value: 'download',
                                          child: Text('Download CSV'),
                                        ),
                                      ];
                                    },
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
