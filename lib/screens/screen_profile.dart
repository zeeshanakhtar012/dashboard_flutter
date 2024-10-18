import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controller_admin.dart';
import '../controllers/controller_image_url.dart';

class ScreenProfile extends StatelessWidget {
  final AdminController adminController = Get.put(AdminController());
  final ControllerImagesUrl controllerImagesUrl = Get.put(ControllerImagesUrl());

  ScreenProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    // Fetch admin data and the first image URL once when the screen is opened
    adminController.fetchAdmin(adminController.emailController.value.text);
    if (controllerImagesUrl.imageUrl.isEmpty) {
      controllerImagesUrl.fetchAdminImage('admin');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isWideScreen
              ? Row(
            children: [
              Expanded(
                child: _profileDetails(context),
              ),
              Expanded(
                child: _actions(context),
              ),
            ],
          )
              : Column(
            children: [
              _profileDetails(context),
              const SizedBox(height: 30),
              _actions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileDetails(BuildContext context) {
    return Obx(() {
      if (adminController.isLoading.value) {
        return const CircularProgressIndicator();
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              return CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(controllerImagesUrl.imageUrl.value),
                onBackgroundImageError: (error, stackTrace) {
                  controllerImagesUrl.imageUrl.value = "assets/images/logo.png"; // Fallback image
                },
              );
            }),
            const SizedBox(height: 20),
            Text(
              "Admin Name: ${adminController.nameController.value.text}",
              style: titleFont,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  "Email: ${adminController.emailController.value.text}",
                  style: subtitle,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  "Phone: ${adminController.phoneNoController.value.text}",
                  style: subtitle,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.admin_panel_settings, color: Colors.grey),
                SizedBox(width: 10),
                Text(
                  "Role: Super Admin",
                  style: subtitle,
                ),
              ],
            ),
          ],
        );
      }
    });
  }

  Widget _actions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            adminController.adminLogout();
          },
          child: const Text("Logout"),
        ),
      ],
    );
  }
}
