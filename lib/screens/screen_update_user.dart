import 'dart:developer';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package
import '../controllers/controller_user.dart';
import '../models/user.dart';

class ScreenUpdateUser extends StatefulWidget {
  String userID;
  ScreenUpdateUser({Key? key, required this.userID}) : super(key: key);

  @override
  State<ScreenUpdateUser> createState() => _ScreenUpdateUserState();
}

class _ScreenUpdateUserState extends State<ScreenUpdateUser> {
  User? user;
  var phoneNo = TextEditingController().obs;
  var userName = TextEditingController().obs;
  var password = TextEditingController().obs;
  var userAddress = TextEditingController().obs;
  var email = TextEditingController().obs;
  var fid = TextEditingController().obs;
  var employeeId = TextEditingController().obs;
  var region = TextEditingController().obs;
  var mbu = TextEditingController().obs;
  var designation = TextEditingController().obs;
  String? imageUrl; // Variable to hold the image URL
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Method to pick image using image_picker
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List byteData = await pickedFile.readAsBytes();
      String downloadUrl = await _uploadImageToFirebase(byteData, pickedFile.name);
      setState(() {
        imageUrl = downloadUrl; // Store the download URL
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImageToFirebase(Uint8List data, String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref('users/$fileName');
      await storageRef.putData(data);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      return '';
    }
  }

  // Save user data
  Future<void> _updateUSer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserController controller = Get.put(UserController());
      final userId = widget.userID;
      final user = User(
        userId: userId,
        designation: designation.value.text,
        region: region.value.text,
        employeeId: employeeId.value.text,
        mbu: mbu.value.text,
        userName: userName.value.text,
        password: password.value.text,
        userAddress: userAddress.value.text,
        fid: fid.value.text,
        phoneNumber: phoneNo.value.text,
        email: email.value.text,
        imageUrl: imageUrl,
      );
      await controller.updateUserInFirestore(user);
      phoneNo.value.clear();
      userName.value.clear();
      userAddress.value.clear();
      password.value.clear();
      email.value.clear();
      fid.value.clear();
      employeeId.value.clear();
      region.value.clear();
      mbu.value.clear();
      designation.value.clear();
    } catch (error) {
      log('Failed to add user: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text('Update User' ),
        centerTitle: true,
      ),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage, // Call image picker on tap
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl!)
                            : NetworkImage("https://cdn-icons-png.flaticon.com/512/149/149071.png") as ImageProvider, // Display selected image or default
                        child: imageUrl == null ? Icon(Icons.add_a_photo, size: 30) : null, // Show icon if no image selected
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                       "Update User",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(email, 'Email', Icons.email),
                    const SizedBox(height: 30),
                    _buildTextField(phoneNo, 'Phone Number', Icons.phone),
                    const SizedBox(height: 20),
                    _buildTextField(password, 'Password', Icons.phone),
                    const SizedBox(height: 20),
                    _buildTextField(phoneNo, 'Phone Number', Icons.phone),
                    const SizedBox(height: 20),
                    _buildTextField(userName, 'User Name', Icons.drive_file_rename_outline),
                    const SizedBox(height: 20),
                    _buildTextField(userAddress, 'User Address', Icons.location_on),
                    const SizedBox(height: 20),
                    _buildTextField(fid, 'User FID', Icons.insert_drive_file_outlined),
                    const SizedBox(height: 20),
                    _buildTextField(employeeId, 'Employee Id', Icons.work),
                    const SizedBox(height: 20),
                    _buildTextField(region, 'Region', Icons.map),
                    const SizedBox(height: 30),
                    _buildTextField(mbu, 'MBU', Icons.menu_book),
                    const SizedBox(height: 30),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _updateUSer,
                      child: Text(
                        "Update User",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(Rx<TextEditingController> controller, String label, IconData icon) {
    return TextFormField(
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      controller: controller.value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: Icon(icon, color: Colors.black),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
