import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller_retailers.dart';
import '../controllers/controller_user.dart';

class SearchScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final RetailerController retailerController = Get.put(RetailerController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users and Retailers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input Field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by POS ID or Username',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Perform search when user types
                if (value.isNotEmpty) {
                  performSearch(value);
                } else {
                  // Clear the search results if input is empty
                  userController.usersList.clear();
                  retailerController.retailersList.clear();
                }
              },
            ),
            SizedBox(height: 20),

            // Results Section (Users & Retailers)
            Expanded(
              child: Obx(() {
                // Loading indicator
                if (userController.isLoading.value || retailerController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                // Display search results
                return ListView(
                  children: [
                    // Users Section
                    if (userController.usersList.isNotEmpty) ...[
                      Text('Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...userController.usersList.map((user) {
                        return ListTile(
                          title: Text(user.userName!),
                          subtitle: Text('User ID: ${user.userId}'),
                        );
                      }).toList(),
                    ],

                    // Retailers Section
                    if (retailerController.retailersList.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text('Retailers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...retailerController.retailersList.map((retailer) {
                        return ListTile(
                          title: Text(retailer.retailerName!),
                          subtitle: Text('POS ID: ${retailer.posId}'),
                        );
                      }).toList(),
                    ],

                    // No results message
                    if (userController.usersList.isEmpty && retailerController.retailersList.isEmpty)
                      Center(child: Text('No results found')),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Function to perform search based on input value
  void performSearch(String query) {
    userController.searchUsersByUsername(query);
    retailerController.searchRetailersByName(query);
  }
}
