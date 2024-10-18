import 'dart:developer';

import 'package:admin/screens/screen_update_retailers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controller_retailers.dart';

class RetailerDetailsScreen extends StatelessWidget {
  final String retailerId;
  final RetailerController retailerController = Get.find<RetailerController>();

  RetailerDetailsScreen({Key? key, required this.retailerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch retailer details on screen load
    retailerController.fetchRetailerById(retailerId);

    return Scaffold(
      appBar: AppBar(
        title: Text("Retailer Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // App bar color
      ),
      body: Obx(() {
        // Display loading indicator while data is being fetched
        if (retailerController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // If no retailer data is available
        if (retailerController.retailersList.isEmpty) {
          return Center(
            child: Text("Retailer not found", style: TextStyle(fontSize: 20, color: Colors.red)),
          );
        }

        // Assuming the first retailer in the list is the one we want to display
        var retailerData = retailerController.retailersList[0];

        return Padding(
          padding: const EdgeInsets.all(24.0), // Padding for the entire body
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundImage: retailerData.imageUrl != null && retailerData.imageUrl!.isNotEmpty
                        ? NetworkImage("${retailerData.imageUrl}")
                        : AssetImage('assets/default_avatar.png') as ImageProvider, // Default avatar
                    radius: 50,
                  ),
                ),
                _buildDetailContainer("Name", retailerData.retailerName ?? 'N/A'),
                _buildDetailContainer("POSID", retailerData.posId ?? 'N/A'),
                _buildDetailContainer("Address", retailerData.retailerAddress ?? 'N/A'),
                _buildDetailContainer("FID", retailerData.retailerFid ?? 'N/A'),
                _buildDetailContainer("MBU", retailerData.retailerMbu ?? 'N/A'),
                _buildDetailContainer("Region", retailerData.region ?? 'N/A'),
                _buildDetailContainer("PhoneNo", retailerData.phoneNo ?? 'N/A'),
                SizedBox(height: 24), // Space before the button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      log("Retailer ID ${retailerId}");
                      Get.to(ScreenUpdateRetailers(retailerId: retailerId,));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text("Update Retailer Data"),
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
