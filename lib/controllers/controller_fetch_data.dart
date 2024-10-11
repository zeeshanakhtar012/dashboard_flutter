import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ControllerDataManagement extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var usersList = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsersData();
  }

  Future<void> fetchUsersData() async {
    try {
      isLoading(true);
      var snapshot = await _firestore.collection('users').get();
      usersList.assignAll(snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
      log('Fetched users data: ${usersList.toString()}');
    } catch (e) {
      log('Error fetching users data: $e');
      Get.snackbar("Error", "Failed to fetch users data.", backgroundColor: Colors.red, snackPosition: SnackPosition.TOP);
    } finally {
      isLoading(false);
    }
  }
  Future<void> updateUserData(String docId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(docId).update(updatedData);
      Get.snackbar("Success", "User data updated successfully!", backgroundColor: Colors.green, snackPosition: SnackPosition.BOTTOM);
      fetchUsersData();
    } catch (e) {
      log('Error updating user data: $e');
      Get.snackbar("Error", "Failed to update user data.", backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
