import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class DownloadController extends GetxController {
  var isDownloading = false.obs;
  var collectionName = ''.obs;  // Store the collection name

  // Fetch Firestore data based on the provided collection name
  Future<List<Map<String, dynamic>>> fetchFirestoreCollections(String collection) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection(collection).get();

      List<Map<String, dynamic>> data = snapshot.docs.map((doc) => doc.data()).toList();
      return data;
    } catch (e) {
      print("Error fetching Firestore data: $e");
      return [];
    }
  }

  // Generate CSV File for Users
  Future<String> generateCSVUsers(List<Map<String, dynamic>> data) async {
    List<List<String>> csvData = [
      ["designation", "email", "employeeId", "fid", "imageUrl", "linkedRetailers", "mbu", "phoneNumber", "region", "userAddress", "userId", "userName"]
    ];

    // Add user data to CSV
    data.forEach((element) {
      csvData.add([
        element["designation"] ?? "",
        element["email"] ?? "",
        element["employeeId"] ?? "",
        element["fid"] ?? "",
        element["imageUrl"] ?? "",
        element["linkedRetailers"]?.toString() ?? "",
        element["mbu"] ?? "",
        element["phoneNumber"] ?? "",
        element["region"] ?? "",
        element["userAddress"] ?? "",
        element["userId"] ?? "",
        element["userName"] ?? ""
      ]);
    });

    String csvString = const ListToCsvConverter().convert(csvData);
    return saveToFile(csvString, "users_data.csv");
  }

  // Generate CSV File for Retailers
  Future<String> generateCSVRetailers(List<Map<String, dynamic>> data) async {
    List<List<String>> csvData = [
      ["imageUrl", "posId", "region", "retailerAddress", "retailerFid", "retailerId", "retailerMbu", "retailerName"]
    ];

    // Add retailer data to CSV
    data.forEach((element) {
      csvData.add([
        element["imageUrl"] ?? "",
        element["posId"] ?? "",
        element["region"] ?? "",
        element["retailerAddress"] ?? "",
        element["retailerFid"] ?? "",
        element["retailerId"] ?? "",
        element["retailerMbu"] ?? "",
        element["retailerName"] ?? ""
      ]);
    });

    String csvString = const ListToCsvConverter().convert(csvData);
    return saveToFile(csvString, "retailers_data.csv");
  }

  // Save file to device storage
  Future<String> saveToFile(String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    await file.writeAsString(content);
    return filePath;
  }

  // Show input dialog to enter collection name and then show download options
  void showCollectionInputDialog() {
    Get.defaultDialog(
      title: "Enter Collection Name",
      content: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Collection Name",
            ),
            onChanged: (value) {
              collectionName.value = value; // Update the collection name
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (collectionName.value.isNotEmpty) {
                Get.back();  // Close input dialog
                showDownloadOptions(collectionName.value); // Proceed to download options
              } else {
                Get.snackbar("Error", "Collection name cannot be empty!");
              }
            },
            child: Text("Proceed"),
          ),
        ],
      ),
    );
  }

  // Show download options and handle file download
  void showDownloadOptions(String collection) async {
    Get.defaultDialog(
      title: "Download Options",
      content: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              isDownloading.value = true;
              List<Map<String, dynamic>> data = await fetchFirestoreCollections(collection);
              if (data.isNotEmpty) {
                String filePath = await generateCSVUsers(data);
                isDownloading.value = false;
                Get.back(); // Close the dialog
                Get.snackbar("Download Complete", "Users CSV file saved at $filePath");
              } else {
                Get.snackbar("Error", "No data found in the collection!");
              }
            },
            child: Text("Download Users CSV"),
          ),
          ElevatedButton(
            onPressed: () async {
              isDownloading.value = true;
              List<Map<String, dynamic>> data = await fetchFirestoreCollections(collection);
              if (data.isNotEmpty) {
                String filePath = await generateCSVRetailers(data);
                isDownloading.value = false;
                Get.back(); // Close the dialog
                Get.snackbar("Download Complete", "Retailers CSV file saved at $filePath");
              } else {
                Get.snackbar("Error", "No data found in the collection!");
              }
            },
            child: Text("Download Retailers CSV"),
          ),
        ],
      ),
    );
  }
}
