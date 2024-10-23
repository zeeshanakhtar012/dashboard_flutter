import 'dart:developer';
import 'package:admin/screens/screen_single_retailer_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/retailers.dart';
import '../controllers/controller_retailers.dart';

class ScreenRetailersDetails extends StatelessWidget {
  ScreenRetailersDetails({Key? key}) : super(key: key);

  final RetailerController controller = Get.put(RetailerController());
  @override
  Widget build(BuildContext context) {
    controller.fetchAllRetailers(); // Fetch all retailers on screen load
    log("Retailer Data =  ${controller.retailersList}"); // Log retailer data

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
            "Retailers",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 400, // Adjust height as needed
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.retailersList.isEmpty) {
                return Center(
                  child: Text(
                    "No retailer data available.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView(
                children: [
                  DataTable(
                    columnSpacing: 16.0,
                    columns: const [
                      DataColumn(
                          label: Text("Profile",
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text("Name",
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text("Address",
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text("POS ID",
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text("Delete",
                              style: TextStyle(color: Colors.white))),
                    ],
                    rows: List.generate(
                      controller.retailersList.length,
                          (index) {
                        var retailerInfo = controller.retailersList[index];
                        return retailerDataRow(retailerInfo, context, controller);
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

// Modify retailerDataRow to accept a RetailerModel object and controller
DataRow retailerDataRow(RetailerModel retailerInfo, BuildContext context, RetailerController controller) {
  return DataRow(
    cells: [
      DataCell(
        GestureDetector(
          onTap: () {
            log("Retailer ID: ${retailerInfo.retailerId}");
            Get.to(() => RetailerDetailsScreen(retailerId: retailerInfo.retailerId.toString(),));
          },
          child: CircleAvatar(
            radius: 20,
            child: retailerInfo.imageUrl != null && retailerInfo.imageUrl!.isNotEmpty
                ? ClipOval(
                  child: Image.network(
                                retailerInfo.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/profile_pic.png',
                      fit: BoxFit.cover);
                                },
                              ),
                )
                : Image.asset('assets/images/profile_pic.png',
                fit: BoxFit.cover),
          ),
        ),
      ),
      DataCell(Text(retailerInfo.retailerName ?? "N/A",
          style: TextStyle(color: Colors.white))),
      DataCell(Text(retailerInfo.retailerAddress ?? "N/A",
          style: TextStyle(color: Colors.white))),
      DataCell(Text(retailerInfo.posId ?? "N/A",
          style: TextStyle(color: Colors.white))),
      DataCell(
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () {
            // Show confirmation dialog before deleting
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Delete Retailer'),
                  content: Text('Are you sure you want to delete this retailer?'),
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
                        controller.deleteRetailerFromFirestore(retailerInfo.retailerId!);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    ],
  );
}
