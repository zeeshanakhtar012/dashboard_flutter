import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var userData = Map<String, dynamic>().obs;
  var usersList = <User>[].obs;
  var isLoading = false.obs;
  var userModules = <Map<String, dynamic>>[].obs;
  var searchUserByName = TextEditingController().obs;

  Future<void> getUserModuleProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId'); // Retrieve user ID

    if (userId != null) {
      var modulesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('modules')
          .get();

      for (var doc in modulesSnapshot.docs) {
        print('Module: ${doc.id}, Data: ${doc['data']}, Status: ${doc['status']}');
      }
    } else {
      print("Error: User is not logged in.");
    }
  }
  @override
  void onInit() {
    super.onInit();
    fetchAllUsers(); // Fetch users on controller initialization
  }
  Future<void> fetchAllUsers() async {
    try {
      isLoading(true);
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      usersList.value = querySnapshot.docs.map((doc) {
        return User.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
      }).toList();
      log("usersList = ${usersList.join(', ')}"); // Improved logging
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      isLoading(false);
    }
  }

// generate csv file

  Future<String> generateCsv(String userId) async {
    List<List<dynamic>> rows = [];

    // Add headers for the CSV
    rows.add([
      "User ID",
      "User Name",
      "Email",
      "Designation",
      "Employee ID",
      "Phone Number",
      "Region",
      "MBU",
      "User Address",
      "Module Name",
      "Asset Type",
      "Images",
      "Location",
      "Retailer Address",
      "Retailer Name",
      "Time",
      "Visit Date"
    ]);

    try {
      // Fetch the specific user from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        User user = User.fromDocumentSnapshot(userDoc.data() as Map<String, dynamic>);
        String userName = user.userName ?? "N/A";
        String email = user.email ?? "N/A";
        String designation = user.designation ?? "N/A";
        String employeeId = user.employeeId ?? "N/A";
        String phoneNumber = user.phoneNumber ?? "N/A";
        String region = user.region ?? "N/A";
        String mbu = user.mbu ?? "N/A";
        String userAddress = user.userAddress ?? "N/A";

        // Fetch modules for the user
        QuerySnapshot moduleSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('modules')
            .get();

        if (moduleSnapshot.docs.isNotEmpty) {
          for (var moduleDoc in moduleSnapshot.docs) {
            Map<String, dynamic> moduleData = moduleDoc.data() as Map<String, dynamic>;

            // Use the document ID as the module name
            String moduleName = moduleDoc.id; // Use document ID for module name
            String assetType = moduleData['assetType'] ?? "N/A";
            List<String> images = List<String>.from(moduleData['images'] ?? []);
            String location = moduleData['location'] ?? "N/A";
            String retailerAddress = moduleData['retailerAddress'] ?? "N/A";
            String retailerName = moduleData['retailerName'] ?? "N/A";

            // Convert Timestamp to String for 'time' and 'visitDate'
            String time = moduleData['time'] is Timestamp
                ? DateFormat.yMMMd().add_jm().format((moduleData['time'] as Timestamp).toDate())
                : "N/A";
            String visitDate = moduleData['visitDate'] is Timestamp
                ? DateFormat.yMMMd().format((moduleData['visitDate'] as Timestamp).toDate())
                : "N/A";

            // Add a row for each module's data with the user details
            rows.add([
              userId,
              userName,
              email,
              designation,
              employeeId,
              phoneNumber,
              region,
              mbu,
              userAddress,
              moduleName,
              assetType,
              images.join(", "), // Convert images list to a comma-separated string
              location,
              retailerAddress,
              retailerName,
              time,
              visitDate,
            ]);
          }
        } else {
          // If there are no modules, add a single row for the user with "No Modules"
          rows.add([
            userId,
            userName,
            email,
            designation,
            employeeId,
            phoneNumber,
            region,
            mbu,
            userAddress,
            "No Modules",
            "N/A",
            "N/A",
            "N/A",
            "N/A",
            "N/A",
            "N/A",
          ]);
        }
      } else {
        // Handle case where the user does not exist
        rows.add([userId, "User not found", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]);
      }

      log("CSV rows created for user ID $userId: $rows");
    } catch (e) {
      log("Error fetching user or modules: $e");
    }

    // Convert rows to CSV string
    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }

// Function to download the CSV file

  Future<void> downloadCsv(String userId) async {
    try {
      // Generate CSV data for the specific user
      String csvData = await generateCsv(userId);

      // Create a unique filename for the CSV using the user ID
      String fileName = "user_$userId.csv";

      if (kIsWeb) {
        // Web: Trigger CSV download using AnchorElement
        final bytes = utf8.encode(csvData);
        final blob = html.Blob([Uint8List.fromList(bytes)], 'text/csv'); // Create a Blob
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Create an anchor element and trigger the download
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();

        // Revoke the object URL after download
        html.Url.revokeObjectUrl(url);

        // Show a success message in the web app
        Get.snackbar("Success", "CSV file is being downloaded");
      } else {
        // Desktop: Save the CSV file locally using path_provider and dart:io
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/$fileName"; // Use the new filename
        final file = File(path);

        // Write the CSV data to the file
        await file.writeAsString(csvData);

        // Show a success message in the desktop app
        Get.snackbar("Success", "CSV saved at: $path");
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Failed to download/save CSV: $e");
    }
  }

// Function to fetch module data

  Future<void> fetchModuleData(String userId, String moduleName) async {
    var doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('modules')
        .doc(moduleName)
        .get();

    if (doc.exists) {
      userData.value = doc.data()!;
    } else {
      Get.snackbar("Error", "No data found for this module");
    }
  }
  /// save user to firestore
  Future<void> saveUserToFirestore(User user) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.userId)
        .set(user.toMap())
        .then((_) {
      print("User saved successfully!");
    })
        .catchError((error) {
      print("Failed to save user: $error");
    });
  }
  // Method to remove a user from Firestore by userId
  Future<void> removeUserFromFirestore(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      Get.snackbar("Success", "User removed successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
      usersList.removeWhere((user) => user.userId == userId);
    } catch (e) {
      Get.snackbar("Error", "Failed to remove user: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Error removing user: $e");
    }
  }
  /// get users from firestore
  Future<User?> getUserFromFirestore(String userId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      return User.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Update user details

  Future<void> updateUserInFirestore(User user) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.userId).get();
      if (doc.exists) {
        await _firestore.collection('users').doc(user.userId).update(user.toMap());
        Get.snackbar("Success", "User updated successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "User not found.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update user: $e");
      print("Failed to update user: $e");
    }
  }


  // Add this method to UserController

  Future<void> searchUsersByUsername(String username) async {
    try {
      isLoading(true);
      String trimmedUsername = username.trim();
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userName', isGreaterThanOrEqualTo: trimmedUsername)  // Start matching from the trimmed username
          .where('userName', isLessThanOrEqualTo: trimmedUsername + '\uf8ff') // Include all possible endings
          .get();

      usersList.value = querySnapshot.docs.map((doc) {
        return User.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
      }).toList();
      log("User found = ${querySnapshot}");
      if (usersList.isEmpty) {
        Get.snackbar('Info', 'No users found matching "$trimmedUsername".');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to search users: $e');
    } finally {
      isLoading(false);
    }
  }
  // Fetch user modules
  Future<void> fetchUserModules() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('modules')
            .get(); // Fetch the modules sub-collection

        if (querySnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> moduleList = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          log("User modules fetched successfully: $moduleList");
        } else {
          log("No modules found for this user.");
          Get.snackbar('No Modules Found', 'This user has no modules.', snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        log('User ID not found. Cannot fetch modules.');
      }
    } catch (e) {
      log("Error fetching user modules: $e");
      Get.snackbar('Error', 'Failed to fetch modules: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }
  Future<void> fetchUserListWithModules() async {
    try {
      // Fetch all users from the 'users' collection
      var userQuerySnapshot = await _firestore.collection('users').get();

      // Iterate through each user document
      for (var userDoc in userQuerySnapshot.docs) {
        String userId = userDoc.id;
        Map<String, dynamic> userData = userDoc.data();

        log('User ID: $userId, User Data: $userData');

        // Initialize a map to store module data for this user
        Map<String, dynamic> modulesData = {};
        List<String> moduleNames = ['MarketVisit', 'MarketIntelligence', 'NewAsset', 'TradeAsset'];

        // Fetch each module's subcollection data
        for (String moduleName in moduleNames) {
          var moduleSnapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('modules')
              .doc(moduleName)
              .get();

          if (moduleSnapshot.exists) {
            Map<String, dynamic>? moduleData = moduleSnapshot.data();
            modulesData[moduleName] = moduleData ?? {};  // Store the module data in the map
            log('$moduleName data for User $userId: $moduleData');
          } else {
            log('$moduleName data not found for User $userId');
          }
        }

        // Now you have user data and their module data in modulesData
        log('All module data for User $userId: $modulesData');
      }
    } catch (e) {
      log('Error fetching users with modules: $e');
    }
  }


}

