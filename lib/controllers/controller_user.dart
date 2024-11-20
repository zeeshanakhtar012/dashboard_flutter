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
  List<String> validModules = [
    "MarketIntelligence",
    "MarketVisit",
    "NewAsset",
    "TradeAsset",
  ];

  // fetch user details modules data
  Future<void> fetchAllUsersWithModules() async {
    try {
      isLoading(true);
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      // Clear existing data only if necessary, otherwise leave it intact
      if (usersList.isNotEmpty) usersList.clear();

      // Fetch users in parallel
      await Future.wait(usersSnapshot.docs.map((userDoc) async {
        User user = User.fromDocumentSnapshot(userDoc.data() as Map<String, dynamic>);
        user.modules = [];
        QuerySnapshot modulesSnapshot = await userDoc.reference.collection('modules').get();
        await Future.wait(modulesSnapshot.docs.map((moduleDoc) async {
          Module module = Module.fromMap(moduleDoc.data() as Map<String, dynamic>);
          module.dataByDate = [];
          QuerySnapshot dataByDateSnapshot = await moduleDoc.reference.collection('dataByDate').get();
          module.dataByDate.addAll(dataByDateSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
          user.modules.add(module);
        }));

        // Add user to usersList once the modules have been processed
        usersList.add(user);
        log("Fetched users with modules: ${usersList.join(', ')}");
      }));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users and modules: $e');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
  }

  fetchAllUsers() async {
    try {
      isLoading(true);
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      usersList.value = querySnapshot.docs.map((doc) {
        return User.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
      }).toList();
      log("Fetched users: ${usersList.join(', ')}");
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchUserData(String userId) async {
    // Reference to the user's document
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Fetch the user details
    DocumentSnapshot userSnapshot = await userDocRef.get();
    if (userSnapshot.exists) {
      var userData = userSnapshot.data();
      log("Fetched user details: $userData");

      // Reference to the 'modules' subcollection
      final modulesRef = userDocRef.collection('modules');

      // Fetch modules (like MarketIntelligence, MarketVisit, etc.)
      QuerySnapshot modulesSnapshot = await modulesRef.get();
      log("Modules snapshot count: ${modulesSnapshot.docs.length}");

      if (modulesSnapshot.docs.isNotEmpty) {
        for (var moduleDoc in modulesSnapshot.docs) {
          log("Fetched module: ${moduleDoc.id}");

          // Fetch the 'dataByDate' subcollection for each module
          final dataByDateRef = moduleDoc.reference.collection('dataByDate');
          QuerySnapshot dataByDateSnapshot = await dataByDateRef.get();

          log("Data by date snapshot count for module ${moduleDoc.id}: ${dataByDateSnapshot.docs.length}");

          if (dataByDateSnapshot.docs.isNotEmpty) {
            for (var dataDoc in dataByDateSnapshot.docs) {
              print("Fetched data document with ID: ${dataDoc.id}");
              var data = dataDoc.data();

              // Merge the user data and module data here
              // Example: user data + module data (dataDoc.data)
              // You can now process or store this merged data for CSV generation or other purposes
            }
          } else {
            log("No data found in dataByDate for module: ${moduleDoc.id}");
          }
        }
      } else {
        log("No modules found for user: $userId");
      }
    } else {
      log("User document not found for userId: $userId");
    }
  }
  // generate csv file
  Future<String> generateCsv(String userId) async {
    // Fetch user details from Firestore
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userSnapshot.exists) {
      log("User not found");
      return "";
    }

    // Extract user details from the snapshot
    String userName = userSnapshot['userName'] ?? 'N/A';
    String email = userSnapshot['email'] ?? 'N/A';
    String designation = userSnapshot['designation'] ?? 'N/A';
    String employeeId = userSnapshot['employeeId'] ?? 'N/A';
    String phoneNumber = userSnapshot['phoneNumber'] ?? 'N/A';
    String region = userSnapshot['region'] ?? 'N/A';
    String mbu = userSnapshot['mbu'] ?? 'N/A';
    String userAddress = userSnapshot['userAddress'] ?? 'N/A';

    // Initialize the CSV rows
    List<List<String>> rows = [];

    // Add header row
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
      "Company Asset Type",
      "Retailer Name",
      "Retailer Address",
      "Location",
      "Field 5",
      "Images",
      "Location",
      "Time Uploaded",
      "Date Uploaded",
      "Visit Date"
    ]);

    // Predefined list of valid module names
    List<String> validModules = [
      "MarketIntelligence",
      "MarketVisit",
      "NewAsset",
      "TradeAsset",
    ];

    bool hasModulesData = false; // Flag to track if modules data is found

    for (String moduleName in validModules) {
      try {
        // Fetch the dataByDate collection
        QuerySnapshot dataByDateSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('modules')
            .doc(moduleName)
            .collection('dataByDate')
            .get();

        if (dataByDateSnapshot.docs.isEmpty) {
          log("No data found in module $moduleName for user $userId");
          continue;
        }

        hasModulesData = true; // Modules data found

        // Process each document in the dataByDate collection
        for (var doc in dataByDateSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Extract and handle array fields
          List<String> images =
              (data['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
                  ['N/A'];
          String imageList = images.join(", "); // Convert list to a comma-separated string

          // Handle Timestamp fields safely
          String timeUploaded = (data['timeUploaded'] is Timestamp)
              ? (data['timeUploaded'] as Timestamp).toDate().toIso8601String()
              : 'N/A';
          String dateUploaded = (data['dateUploaded'] is Timestamp)
              ? (data['dateUploaded'] as Timestamp).toDate().toIso8601String()
              : 'N/A';

          // Handle other fields safely
          String assetType = data['assetType'] ?? 'N/A';
          String location = data['location'] ?? 'N/A';
          String visitDate = (data['visitDate'] is Timestamp)
              ? (data['visitDate'] as Timestamp).toDate().toIso8601String()
              : 'N/A';
          String retailerName = data['retailerName'] ?? 'N/A';
          String retailerAddress = data['retailerAddress'] ?? 'N/A';

          // Add row for each document
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
            retailerName,
            retailerAddress,
            location,
            timeUploaded,
            imageList,
            location,
            timeUploaded,
            dateUploaded,
            visitDate,
          ]);
        }
      } catch (e) {
        log("Error fetching module data for $moduleName: $e");
      }
    }

    // If no modules were found, add a row with 'N/A'
    if (!hasModulesData) {
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
        "N/A",
        "N/A",
        "N/A",
        "N/A",
        "N/A",
        "N/A",
        "N/A",
        "N/A",
      ]);
    }

    // Convert the rows into CSV format
    String csvData = const ListToCsvConverter().convert(rows);
    log("Generated CSV Data:\n$csvData");

    return csvData; // Return the generated CSV data
  }
  // download csv fil
  Future<void> downloadCsv(String userId) async {
    try {
      String csvData = await generateCsv(userId);
      if (csvData.isEmpty) {
        Get.snackbar("Error", "CSV data is empty, user not found.");
        return;
      }

      String fileName =
          "user_report_${userId}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv";

      // Web download logic or mobile download logic here
      // For example:
      if (kIsWeb) {
        // Web download logic
        final bytes = utf8.encode(csvData);
        final blob = html.Blob([Uint8List.fromList(bytes)], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        Get.snackbar(
          snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            "Success", "CSV file is being downloaded");
      } else {

        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/$fileName";
        File file = File(path);
        await file.writeAsString(csvData);
        Get.snackbar(
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            "Success", "CSV saved at: $path");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to download/save CSV: $e");
    }
  }

  // save user to firestore
  Future<void> saveUserToFirestore(User user) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.userId)
        .set(user.toMap())
        .then((_) {
      print("User saved successfully!");
    }).catchError((error) {
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

  // get users from firestore
  Future<User?> getUserFromFirestore(String userId) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      return User.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Update user details
  Future<void> updateUserInFirestore(User user) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.userId).get();
      if (doc.exists) {
        await _firestore
            .collection('users')
            .doc(user.userId)
            .update(user.toMap());
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
          .where('userName',
              isGreaterThanOrEqualTo:
                  trimmedUsername) // Start matching from the trimmed username
          .where('userName',
              isLessThanOrEqualTo:
                  trimmedUsername + '\uf8ff') // Include all possible endings
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

  //
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
        List<String> moduleNames = [
          'MarketVisit',
          'MarketIntelligence',
          'NewAsset',
          'TradeAsset'
        ];

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
            modulesData[moduleName] =
                moduleData ?? {}; // Store the module data in the map
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
