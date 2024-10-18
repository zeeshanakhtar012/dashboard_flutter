import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var userData = Map<String, dynamic>().obs;
  var usersList = <User>[].obs;
  var isLoading = false.obs;

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

  // Fetch module data for a user
  Future<void> fetchModuleData(String userId, String moduleName) async {
    var doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('userData')
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
  // Update user details
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

}

