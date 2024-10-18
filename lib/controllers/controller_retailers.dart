import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/retailers.dart';

class RetailerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isLoading = false.obs;
  var retailersList = <RetailerModel>[].obs;  // Observable list for retailers

  // Save retailer to Firestore
  Future<void> saveRetailerToFirestore(RetailerModel retailer) async {
    try {
      isLoading(true); // Start loading

      // Generate a unique retailerId using the current timestamp if not already set
      retailer.retailerId = retailer.retailerId ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Save the retailer document with the generated retailerId as the document ID
      await _firestore.collection('retailers')
          .doc(retailer.retailerId)  // Use retailerId as the document ID
          .set(retailer.toMap());

      Get.snackbar("Success", "Retailer added successfully!", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false); // Stop loading
    }
  }

  // Update retailer in Firestore
  Future<void> updateRetailerInFirestore(RetailerModel retailer) async {
    try {
      isLoading(true);
      DocumentReference retailerRef = _firestore.collection('retailers').doc(retailer.retailerId);
      DocumentSnapshot docSnapshot = await retailerRef.get();
      if (docSnapshot.exists) {
        await retailerRef.update(retailer.toMap());
        Get.snackbar("Success", "Retailer updated successfully!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.black);
        log("Retailer updated successfully with ID: ${retailer.retailerId}");
      } else {
        log("Error: No retailer found with ID: ${retailer.retailerId}");
        Get.snackbar("Error", "No retailer found with this ID.", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (error) {
      log("Error updating retailer: $error");
      Get.snackbar("Update failed", "Failed to update retailer: $error", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Delete retailer from Firestore
  Future<void> deleteRetailerFromFirestore(String retailerId) async {
    try {
      isLoading(true); // Start loading
      await _firestore.collection('retailers').doc(retailerId).delete();

      retailersList.removeWhere((retailer) => retailer.retailerId == retailerId);  // Remove from list

      Get.snackbar("Success", "Retailer deleted successfully!", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete retailer: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false); // Stop loading
    }
  }

  // Fetch all retailers
  Future<void> fetchAllRetailers() async {
    try {
      isLoading(true); // Start loading
      QuerySnapshot snapshot = await _firestore.collection('retailers').get();
      var retailers = snapshot.docs
          .map((doc) => RetailerModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      retailersList.value = retailers;  // Update the observable list
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Fetch retailer by retailerId
  Future<void> fetchRetailerById(String retailerId) async {
    try {
      isLoading(true); // Start loading
      var query = await _firestore
          .collection('retailers')
          .where('retailerId', isEqualTo: retailerId)
          .get();

      if (query.docs.isNotEmpty) {
        retailersList.value = query.docs
            .map((doc) => RetailerModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      } else {
        Get.snackbar("Error", "No retailer found with this ID.", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false); // Stop loading
    }
  }

  // Search retailers by POS ID
  Future<void> searchRetailersByPosId(String posId) async {
    try {
      isLoading(true);
      QuerySnapshot querySnapshot = await _firestore
          .collection('retailers')
          .where('posId', isEqualTo: posId)  // Search by POS ID
          .get();
      retailersList.value = querySnapshot.docs.map((doc) {
        return RetailerModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to search retailers: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Search retailers by Name
  Future<void> searchRetailersByName(String retailerName) async {
    try {
      isLoading(true);
      QuerySnapshot querySnapshot = await _firestore
          .collection('retailers')
          .where('retailerName', isEqualTo: retailerName)  // Search by retailer name
          .get();
      retailersList.value = querySnapshot.docs.map((doc) {
        return RetailerModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to search retailers: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }
}
