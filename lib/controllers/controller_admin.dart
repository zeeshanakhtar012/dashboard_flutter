import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControllerSaveData extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  var isLoading = false.obs;

  Future<bool> login() async {
    isLoading.value = true;
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter both email and password.");
      return false;
    }
    await Future.delayed(Duration(seconds: 1));
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore
        .collection('admin').doc('email').collection('password').doc('password')
        .get();
    // Simulated delay
    // if (email == "admin@example.com" && password == "password123") {
    //   return true; // Login success
    // } else {
    isLoading.value = false;
      return false; // Login failure
    // }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

var email = TextEditingController().obs;
var password = TextEditingController().obs;
var phoneNo = TextEditingController().obs;
class AdminController extends GetxController {
  var isLoggedIn = false.obs;

  // Signup Admin: Save admin details to Firestore
  Future<void> adminSignUp() async {
    try {
      await FirebaseFirestore.instance.collection('adminDetails').doc(email.value.text).set({
        'email': email,
        'password': password,
        'createdAt': Timestamp.now(),
      });

      // Save login status in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('adminEmail', email.value.text);
      isLoggedIn.value = true;
    } catch (e) {
      print("Error signing up admin: $e");
    }
  }

  Future<void> adminLogin(String email, String password) async {
    try {
      var adminSnapshot = await FirebaseFirestore.instance.collection('adminDetails').doc(email).get();

      if (adminSnapshot.exists && adminSnapshot['password'] == password) {
        // Save login status in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('adminEmail', email);
        isLoggedIn.value = true;
      } else {
        print("Admin login failed: Incorrect email or password.");
      }
    } catch (e) {
      print("Error logging in admin: $e");
    }
  }

  // Check if admin is already logged in
  Future<void> checkAdminLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminEmail = prefs.getString('adminEmail');

    if (adminEmail != null) {
      isLoggedIn.value = true;
    } else {
      isLoggedIn.value = false;
    }
  }

  // Logout Admin: Clear SharedPreferences
  Future<void> adminLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminEmail');
    isLoggedIn.value = false;
  }
}
