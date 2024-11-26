import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controller_user.dart';

class SearchUserScreen extends StatefulWidget {
  final String searchQuery;

  SearchUserScreen({Key? key, required this.searchQuery}) : super(key: key) {

  }

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final UserController userController = Get.put(UserController());

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search User'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    setState(() async {
                      if (searchController.text.isNotEmpty) {
                        await userController.searchUsersByUsername(
                            searchController.text.trim());
                      } else {
                        Get.snackbar('Input Error',
                            'Please enter a username to search.');
                      }
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Obx(() {
              // Check if the search has been performed and usersList is updated
              if (userController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (userController.usersList.isEmpty &&
                  searchController.text.isNotEmpty) {
                return Center(child: Text('No users found'));
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: userController.usersList.length,
                  itemBuilder: (context, index) {
                    var user = userController.usersList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: user.imageUrl != null
                            ? NetworkImage(user.imageUrl!)
                            : NetworkImage(
                                "https://cdn-icons-png.flaticon.com/512/149/149071.png"),
                      ),
                      title: Text(user.userName ?? "Unknown"),
                      subtitle: Text(user.email ?? "No email"),
                      trailing: IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () async {
                          await userController
                              .downloadCsv(user.userId.toString());
                          log("CSV downloaded for user: ${user.userName}");
                        },
                      ),
                    );
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
