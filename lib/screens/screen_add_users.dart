import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/controller_user.dart';
import '../models/user.dart';

class ScreenAddUsers extends StatefulWidget {
  final bool isUpdate;

  const ScreenAddUsers({Key? key, required this.isUpdate}) : super(key: key);

  @override
  State<ScreenAddUsers> createState() => _ScreenAddUsersState();
}

class _ScreenAddUsersState extends State<ScreenAddUsers> {
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
  String? imageUrl;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List byteData = await pickedFile.readAsBytes();
      String downloadUrl =
      await _uploadImageToFirebase(byteData, pickedFile.name);
      setState(() {
        imageUrl = downloadUrl;
      });
    }
  }

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

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar('Error', 'Please fill all required fields',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserController controller = Get.put(UserController());
      final userId = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      final user = User(
        userId: userId,
        designation: designation.value.text,
        region: region.value.text,
        employeeId: employeeId.value.text,
        mbu: mbu.value.text,
        userName: userName.value.text,
        userAddress: userAddress.value.text,
        password: password.value.text,
        fid: fid.value.text,
        phoneNumber: phoneNo.value.text,
        email: email.value.text,
        imageUrl: imageUrl,
      );

      if (widget.isUpdate == false) {
        await controller.saveUserToFirestore(user);
      } else {
        await controller.updateUserInFirestore(user);
      }

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

      Get.snackbar('Success', 'User added successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } catch (error) {
      Get.snackbar('Error', 'Failed to add user: $error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Obx(() {
            return userController.isLoading.value? CircularProgressIndicator():TextButton(
                onPressed: () async {
                  await userController.pickAndUploadCSV();
                },
                child: Text(
                  "Add Bulk User",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ));
          })
        ],
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(widget.isUpdate ? 'Update User' : 'Add Users'),
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
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl!)
                            : NetworkImage(
                            "https://cdn-icons-png.flaticon.com/512/149/149071.png")
                        as ImageProvider,
                        child: imageUrl == null
                            ? Icon(Icons.add_a_photo, size: 30)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(email, 'Email', Icons.email),
                    const SizedBox(height: 20),
                    _buildTextField(phoneNo, 'Phone Number', Icons.phone),
                    const SizedBox(height: 20),
                    _buildTextField(password, 'User Password', Icons.lock),
                    const SizedBox(height: 20),
                    _buildTextField(userName, 'User Name', Icons.person),
                    const SizedBox(height: 20),
                    _buildTextField(
                        userAddress, 'User Address', Icons.location_on),
                    const SizedBox(height: 20),
                    _buildTextField(fid, 'User FID', Icons.insert_drive_file),
                    const SizedBox(height: 20),
                    _buildTextField(employeeId, 'Employee Id', Icons.work),
                    const SizedBox(height: 20),
                    _buildTextField(region, 'Region', Icons.map),
                    const SizedBox(height: 20),
                    _buildTextField(mbu, 'MBU', Icons.business),
                    const SizedBox(height: 20),
                    _buildTextField(designation, 'Designation', Icons.badge),
                    const SizedBox(height: 30),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _saveUser,
                      child: Text(
                        widget.isUpdate ? "Update User" : "Save User",
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

  Widget _buildTextField(Rx<TextEditingController> controller, String label,
      IconData icon) {
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
