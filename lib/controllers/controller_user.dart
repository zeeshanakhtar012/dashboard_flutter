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
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/modules.dart';
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
    fetchAllUsers();
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

// Function to generate CSV file
  Future<void> fetchAllUsersWithModules() async {
    try {
      isLoading(true);
      // Fetching all users from the 'users' collection
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      // Clear previous data
      usersList.clear();

      // Iterate through each user
      for (var userDoc in usersSnapshot.docs) {
        // Create user object from document snapshot
        User user = User.fromDocumentSnapshot(userDoc.data() as Map<String, dynamic>);
        user.modules = []; // Initialize the modules list for the user

        // Fetch the modules associated with the user from the 'modules' sub-collection
        QuerySnapshot modulesSnapshot = await userDoc.reference.collection('modules').get();

        // Add each module to the user object
        for (var moduleDoc in modulesSnapshot.docs) {
          // Use the fromMap method to create a Module instance from the snapshot data
          Module module = Module.fromMap(moduleDoc.data() as Map<String, dynamic>);
          user.modules.add(module); // Add the Module instance to the user's modules list
        }

        // Add user to the users list
        usersList.add(user);
      }

      log("Fetched ${usersList.length} users with their modules.");
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users and modules: $e');
      log("Error fetching users: $e");
    } finally {
      isLoading(false);
    }
  }

  // Function to generate CSV for a specific user
  // users -> {userId} -> modules -> {moduleName} -> dataByDate -> {documentId}
  Future<String> generateCsv(String userId) async {
    // Fetch user details
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userSnapshot.exists) {
      log("User not found");
      return ""; // Return empty string if user is not found
    }

    // Extract user details
    String userName = userSnapshot['userName'] ?? 'N/A';
    String email = userSnapshot['email'] ?? 'N/A';
    String designation = userSnapshot['designation'] ?? 'N/A';
    String employeeId = userSnapshot['employeeId'] ?? 'N/A';
    String phoneNumber = userSnapshot['phoneNumber'] ?? 'N/A';
    String region = userSnapshot['region'] ?? 'N/A';
    String mbu = userSnapshot['mbu'] ?? 'N/A';
    String userAddress = userSnapshot['userAddress'] ?? 'N/A';

    // Initialize CSV rows
    List<List<String>> rows = [];
    // Header row
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
      "Time Uploaded",
      "Date Uploaded"
    ]);

    // Fetch all modules for the user
    QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('modules')
        .get();

    log("Number of modules found: ${moduleSnapshot.docs.length}");

    if (moduleSnapshot.docs.isNotEmpty) {
      for (var moduleDoc in moduleSnapshot.docs) {
        String moduleName = moduleDoc.id;

        // Fetch dataByDate for each module
        QuerySnapshot dataByDateSnapshot = await moduleDoc.reference.collection('dataByDate').get();
        log("Found module: $moduleName with ${dataByDateSnapshot.docs.length} entries");

        if (dataByDateSnapshot.docs.isNotEmpty) {
          for (var dataDoc in dataByDateSnapshot.docs) {
            // Extracting data
            String assetType = dataDoc['assetType'] ?? 'N/A';
            List<dynamic> images = dataDoc['images'] ?? [];
            String location = dataDoc['location'] ?? 'N/A';
            String timeUploaded = dataDoc['time']?.toDate().toString() ?? 'N/A'; // Format if necessary

            // Create a new row for the CSV
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
              images.join(", "), // Convert list to string
              location,
              timeUploaded,
              DateFormat('yyyy-MM-dd').format(DateTime.now()) // Current date as Date Uploaded
            ]);
          }
        } else {
          // No entries found in dataByDate
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
            "N/A",
            "N/A",
            "N/A",
            "N/A",
            DateFormat('yyyy-MM-dd').format(DateTime.now()) // Current date as Date Uploaded
          ]);
        }
      }
    } else {
      // No modules found
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
        DateFormat('yyyy-MM-dd').format(DateTime.now()) // Current date as Date Uploaded
      ]);
    }

    // Generate CSV
    String csvData = const ListToCsvConverter().convert(rows);
    log("Generated CSV Data:\n$csvData");

    return csvData; // Return the generated CSV data
  }

// Function to download the CSV file
  // Function to download the CSV file
  Future<void> downloadCsv(String userId) async {
    try {
      // Generate CSV data for the specific user
      String csvData = await generateCsv(userId);

      // Fetch user details to get the user name for the file name
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      String userName = userDoc.exists ? (userDoc.data() as Map<String, dynamic>)['userName'] ?? "user" : "user";

      // Create a unique filename for the CSV using the user name
      String fileName = "${userName.replaceAll(' ', '_')}_report.csv";

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

