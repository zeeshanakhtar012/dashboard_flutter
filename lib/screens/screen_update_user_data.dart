import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller_fetch_data.dart';

class UpdateUserScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> initialData;

  UpdateUserScreen({Key? key, required this.userId, required this.initialData}) : super(key: key);

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final ControllerDataManagement controller = Get.find();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialData['retailerName']);
    phoneController = TextEditingController(text: widget.initialData['phoneNo']);
    addressController = TextEditingController(text: widget.initialData['formattedAddress']);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void updateUser() {
    var updatedData = {
      'retailerName': nameController.text,
      'phoneNo': phoneController.text,
      'formattedAddress': addressController.text,
      // Add any additional fields here
    };

    controller.updateUserData(widget.userId.toString(), updatedData);
    Get.back(); // Go back to the previous screen after update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update User Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone No"),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: "Address"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateUser,
              child: Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
