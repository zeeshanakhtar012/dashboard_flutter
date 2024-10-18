import 'dart:typed_data';
import 'package:admin/screens/screen_login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import '../controllers/controller_admin.dart';

class ScreenAdminSignup extends StatefulWidget {
  const ScreenAdminSignup({Key? key}) : super(key: key);

  @override
  _ScreenAdminSignupState createState() => _ScreenAdminSignupState();
}

class _ScreenAdminSignupState extends State<ScreenAdminSignup> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false; // Track confirm password visibility
  final _formKey = GlobalKey<FormState>();
  String? imageUrl; // Variable to hold the image URL
  final ImagePicker _picker = ImagePicker(); // Initialize image picker
  AdminController controller = Get.put(AdminController());

  // Image picking method
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Convert to Uint8List for uploading
      Uint8List data = await image.readAsBytes();
      String downloadUrl = await _uploadImageToFirebase(data, image.name);
      setState(() {
        imageUrl = downloadUrl; // Store the download URL
      });
      // Set the image URL in the controller
      controller.setImageUrl(downloadUrl);
    }
  }

  // Upload Image to Firebase Storage
  Future<String> _uploadImageToFirebase(Uint8List data, String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref('admin/$fileName');
      await storageRef.putData(data);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: screenWidth > 600 ? 400 : double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView( // Add scrolling if content overflows
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl!)
                            : NetworkImage(
                          "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                        ) as ImageProvider, // Display selected image or default
                        child: imageUrl == null
                            ? Icon(Icons.add_a_photo, size: 30)
                            : null, // Show icon if no image selected
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Admin Signup",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                      controller: controller.nameController.value,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(CupertinoIcons.pencil_circle),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email field
                    TextFormField(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                      controller: controller.emailController.value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Phone Number field
                    TextFormField(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                      controller: controller.phoneNoController.value,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password field
                    TextFormField(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                      controller: controller.passwordController.value,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Confirm Password field
                    TextFormField(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                      controller: controller.confirmPasswordController.value,
                      obscureText: !isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible = !isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != controller.passwordController.value.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Signup button
                    Obx(
                          () => ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            controller.adminSignUp(); // Call the signup method
                          }
                        },
                        child: controller.isLoading.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Signup"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login redirect button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () => Get.to(ScreenLogin()),
                          child: Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
