import 'package:admin/controllers/controller_retailers.dart';
import 'package:admin/screens/screen_add_retailers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../models/retailers.dart';

class ScreenRetailersDetails extends StatelessWidget {
  ScreenRetailersDetails({Key? key}) : super(key: key);

  final RetailerController controller = Get.put(RetailerController());

  @override
  Widget build(BuildContext context) {
    controller.fetchAllRetailers();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Admin Panel",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Retailers",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.retailersList.isEmpty) {
                  return Center(
                    child: Text(
                      "No retailers available.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.retailersList.length,
                  itemBuilder: (context, index) {
                    var retailerInfo = controller.retailersList[index];
                    return RetailerListTile(
                      retailerInfo: retailerInfo,
                      onEdit: () {
                        // Navigate to editing screen
                        Get.to(ScreenAddRetailers(retailer: retailerInfo));
                      },
                      onDelete: () {
                        // Handle delete action
                        // controller.deleteRetailer(retailerInfo.id);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Create a ListTile widget for each retailer with edit and delete actions
class RetailerListTile extends StatelessWidget {
  final RetailerModel retailerInfo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RetailerListTile({
    Key? key,
    required this.retailerInfo,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey,
        child: retailerInfo.imageUrl != null && retailerInfo.imageUrl!.isNotEmpty
            ? ClipOval(
          child: Image.network(
            retailerInfo.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/profile_pic.png', fit: BoxFit.cover);
            },
          ),
        )
            : Image.asset('assets/images/profile_pic.png', fit: BoxFit.cover),
      ),
      title: Text(
        retailerInfo.retailerName ?? "N/A",
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            retailerInfo.retailerAddress ?? "N/A",
            style: TextStyle(color: Colors.white),
          ),
          Text(
            retailerInfo.region ?? "N/A",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit, // Edit action
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Confirm before deleting
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Confirm Delete"),
                    content: Text("Are you sure you want to delete this retailer?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back(); // Cancel
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          onDelete(); // Delete action
                          Get.back(); // Close dialog
                        },
                        child: Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
