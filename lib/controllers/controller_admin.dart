import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/screens/screen_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminController extends GetxController {
  // Define controllers for admin details
  var emailController = TextEditingController().obs;
  var nameController = TextEditingController().obs;
  var passwordController = TextEditingController().obs;
  var confirmPasswordController = TextEditingController().obs;
  var isPasswordVisible = false.obs;
  var phoneNoController = TextEditingController().obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var image = ''.obs; // Path to the selected image
  var imageUrl = ''.obs; // Store the image URL

  // Method to set image URL after upload
  void setImageUrl(String url) {
    imageUrl.value = url;
  }

  // Signup Admin: Save admin details to Firestore
  Future<void> adminSignUp() async {
    if (imageUrl.value.isEmpty) {
      Get.snackbar("Error", "Please upload an image", colorText: Colors.black, backgroundColor: Colors.red, snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isLoading.value = true;

      if (passwordController.value.text != confirmPasswordController.value.text) {
        Get.snackbar("Error", "Passwords do not match", colorText: Colors.black, backgroundColor: Colors.red, snackPosition: SnackPosition.TOP);
        return;
      }

      await FirebaseFirestore.instance.collection('admin').doc(emailController.value.text).set({
        'email': emailController.value.text,
        'name': nameController.value.text,
        'password': passwordController.value.text,
        'phoneNo': phoneNoController.value.text,
        'image': imageUrl.value, // Store the image URL
        'createdAt': Timestamp.now(),
      });

      Get.to(MainScreen());
      Get.snackbar("Successful", "Admin account created successfully!", colorText: Colors.black, backgroundColor: Colors.green, snackPosition: SnackPosition.TOP);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', emailController.value.text);
      isLoggedIn.value = true;
    } catch (e) {
      Get.snackbar("Error", "Error creating admin account: $e", colorText: Colors.black, backgroundColor: Colors.red, snackPosition: SnackPosition.TOP);
      print("Error signing up admin: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> adminLogin(String email, String password) async {
    try {
      isLoading.value = true;

      var adminSnapshot = await FirebaseFirestore.instance.collection('admin').doc(email).get();

      if (!adminSnapshot.exists) {
        Get.snackbar("Error", "Admin with this email does not exist.", colorText: Colors.white, backgroundColor: Colors.red, snackPosition: SnackPosition.TOP);
        return;
      }

      String storedPassword = adminSnapshot.data()?['password'];
      if (storedPassword != password) {
        Get.snackbar("Error", "Incorrect password.", colorText: Colors.white, backgroundColor: Colors.red, snackPosition: SnackPosition.TOP);
        return;
      }

      // Store the image URL when logging in
      imageUrl.value = adminSnapshot.data()?['image'] ?? '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      isLoggedIn.value = true;

      Get.offAll(MainScreen());
    } catch (e) {
      Get.snackbar("Error", "Failed to login: $e", colorText: Colors.white, backgroundColor: Colors.red, snackPosition: SnackPosition.TOP);
      print("Error logging in admin: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAdminDetails(String adminEmail) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection('admin').doc(adminEmail).update({
        'email': emailController.value.text,
        'password': passwordController.value.text,
        'phoneNo': phoneNoController.value.text,
      });

      Get.snackbar("Success", "Admin details updated successfully!");
    } catch (e) {
      print("Error updating admin details: $e");
      Get.snackbar("Error", "Failed to update admin details.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdmin(String email) async {
    try {
      isLoading.value = true;

      var snapshot = await FirebaseFirestore.instance.collection('admin').where('email', isEqualTo: email).limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        var adminData = snapshot.docs.first.data();
        emailController.value.text = adminData['email'] ?? '';
        nameController.value.text = adminData['name'] ?? '';
        phoneNoController.value.text = adminData['phoneNo'] ?? '';
        imageUrl.value = adminData['image'] ?? ''; // Fetch and store image URL
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch admin details.", colorText: Colors.white, backgroundColor: Colors.red, snackPosition: SnackPosition.TOP);
      print("Error fetching admin: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkAdminLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminEmail = prefs.getString('email');

    if (adminEmail != null) {
      isLoggedIn.value = true;
      emailController.value.text = adminEmail;
    } else {
      isLoggedIn.value = false;
    }
  }

  Future<void> adminLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    isLoggedIn.value = false;
    Get.offAll(ScreenLogin());
  }
}
