import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var userData = Map<String, dynamic>().obs;
  var usersList = <User>[].obs;
  var isLoading = false.obs;
  var userModules = <Map<String, dynamic>>[].obs;

  Future<void> uploadModuleData(String moduleName, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('modules')
          .doc(moduleName)
          .set({
        'data': data,
        'uploadedAt': Timestamp.now(),
        'status': 'completed',
      });
    } else {
      print("Error: User is not logged in.");
    }
  }

  // Optionally, you can add methods for fetching user module data and showing progress
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
  ////

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
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      isLoading(false);
    }
  }
  // Save module data for a user
  Future<void> saveModuleData(String userId, String moduleName, Map<String, dynamic> moduleData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('userData')
          .doc(moduleName)
          .set(moduleData);
      Get.snackbar("Success", "Data saved successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // generate csv data
  Future<String> generateCsv() async {
    List<List<dynamic>> rows = [];

    // Add headers
    rows.add(["User ID", "User Name", "Email", "Module Name", "Module Data"]);

    for (var user in usersList) {
      for (var module in user.modules) {
        rows.add([
          user.userId,
          user.userName,
          user.email,
          module['name'], // Assuming the module has a 'name' field
          module['data'], // Adjust as per your module structure
        ]);
      }
    }

    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }

  // download csv
  Future<void> downloadCsv() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        Get.snackbar("Error", "User ID not found. Please log in again.");
        return;
      }

      // Retrieve module data from Firestore
      QuerySnapshot moduleSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('modules')
          .get();

      // Prepare CSV data
      StringBuffer csvData = StringBuffer();
      csvData.writeln("Module Name, Module Data"); // CSV header

      for (var doc in moduleSnapshot.docs) {
        String moduleName = doc.id; // Module name as document ID
        Map<String, dynamic>? moduleData = doc.data() as Map<String, dynamic>?;

        if (moduleData != null) {
          csvData.writeln('$moduleName, ${moduleData.toString()}'); // Format your data as needed
        }
      }

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/modules.csv";

      // Write CSV data to the file
      final file = File(path);
      await file.writeAsString(csvData.toString());

      Get.snackbar("Success", "CSV downloaded at: $path");
    } on PlatformException catch (e) {
      Get.snackbar("Error", "Platform error: ${e.message}");
    } catch (e) {
      Get.snackbar("Error", "Failed to download CSV: ${e.toString()}");
    }
  }



  // Fetch module data for a user
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

  // delete user
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

  void searchUsersByUsername(String username) async {
    try {
      isLoading(true);
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userName', isEqualTo: username)  // Search by username
          .get();
      usersList.value = querySnapshot.docs.map((doc) {
        return User.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
      }).toList();
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
          updateUserModules(moduleList); // Update the userModules observable
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

// Method to handle updating the UI or controller with fetched module data
  void updateUserModules(List<Map<String, dynamic>> modules) {
    userModules.value = modules; // Update the observable list
    update(); // Update the UI with GetX
  }

  // fetch user list with modules

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

