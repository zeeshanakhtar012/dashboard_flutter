import 'dart:typed_data';
import 'package:admin/controllers/controller_retailers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import '../controllers/controller_user.dart';
import '../models/retailers.dart';
import '../models/user.dart';

class ScreenAddRetailers extends StatefulWidget {
  final RetailerModel? retailer;

  ScreenAddRetailers({this.retailer, });

  @override
  State<ScreenAddRetailers> createState() => _ScreenAddRetailersState();
}

class _ScreenAddRetailersState extends State<ScreenAddRetailers> {
  var retailerName = TextEditingController().obs;
  var retailerAddress = TextEditingController().obs;
  var posid = TextEditingController().obs;
  var fid = TextEditingController().obs;
  var mbu = TextEditingController().obs;
  var region = TextEditingController().obs;
  var phoneNo = TextEditingController().obs;
  String? imageUrl;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker(); // Create an ImagePicker instance

  @override
  void initState() {
    super.initState();
    if (widget.retailer != null) {
      // Pre-fill data if editing
      retailerName.value.text = widget.retailer!.retailerName!;
      phoneNo.value.text = widget.retailer!.phoneNo!;
      retailerAddress.value.text = widget.retailer!.retailerAddress!;
      posid.value.text = widget.retailer!.posId!;
      fid.value.text = widget.retailer!.retailerFid!;
      mbu.value.text = widget.retailer!.retailerMbu!;
      region.value.text = widget.retailer!.region!;
      imageUrl = widget.retailer!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    // Use ImagePicker to pick an image from the gallery
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Convert the picked file to Uint8List
      final byteData = await pickedFile.readAsBytes();
      String downloadUrl = await _uploadImageToFirebase(byteData, pickedFile.name);
      setState(() {
        imageUrl = downloadUrl;
        print("Image URL generated: $imageUrl");
      });
    }
  }

  Future<String> _uploadImageToFirebase(Uint8List data, String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref('retailers/$fileName');
      await storageRef.putData(data);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      return '';
    }
  }

  Future<void> _saveRetailer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      RetailerController retailerController = Get.put(RetailerController());

      // Create a new or updated retailer model
      final retailerModel = RetailerModel(
        retailerId: DateTime.now().millisecondsSinceEpoch.toString(),
        retailerName: retailerName.value.text,
        retailerAddress: retailerAddress.value.text,
        posId: posid.value.text,
        region: region.value.text,
        retailerMbu: mbu.value.text,
        retailerFid: fid.value.text,
        phoneNo: phoneNo.value.text,
        imageUrl: imageUrl ?? "",
      );

      // Call update if in editing mode, otherwise save
      await retailerController.saveRetailerToFirestore(retailerModel);
      Get.snackbar('Success', 'Retailer added successfully!', backgroundColor: Colors.green);

      if (widget.retailer != null) {
        retailerAddress.value.clear();
        retailerName.value.clear();
        fid.value.clear();
        region.value.clear();
        posid.value.clear();
        mbu.value.clear();
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to save retailer: $error', backgroundColor: Colors.red);
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
        title: Text('Add Retailer'),
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
                            : NetworkImage("https://cdn-icons-png.flaticon.com/512/149/149071.png") as ImageProvider,
                        child: imageUrl == null ? Icon(Icons.add_a_photo, size: 30) : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                       "Add Retailer",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(retailerName, 'Retailer Name', Icons.drive_file_rename_outline),
                    const SizedBox(height: 20),
                    _buildTextField(retailerAddress, 'Retailer Address', CupertinoIcons.location),
                    const SizedBox(height: 20),
                    _buildTextField(phoneNo, 'Phone No', Icons.phone),
                    const SizedBox(height: 20),
                    _buildTextField(fid, 'Retailer FID', Icons.insert_drive_file_outlined),
                    const SizedBox(height: 20),
                    _buildTextField(posid, 'Retailer POSID', Icons.work),
                    const SizedBox(height: 20),
                    _buildTextField(region, 'Region', CupertinoIcons.rectangle_grid_1x2),
                    const SizedBox(height: 30),
                    _buildTextField(mbu, 'Retailer MBU', Icons.menu_book_sharp),
                    const SizedBox(height: 30),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _saveRetailer,
                      child: Text(
                        "Save Retailer",
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
    );
  }
}
