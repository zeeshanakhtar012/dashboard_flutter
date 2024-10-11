import 'package:admin/constants.dart';
import 'package:flutter/material.dart';

class ScreenProfile extends StatelessWidget {
  const ScreenProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Profile"),
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
              SizedBox(height: 30),
              _actions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileDetails(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Admin profile picture
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage("assets/images/logo.png"),
        ),
        const SizedBox(height: 20),

        // Admin name
        Text(
          "Admin Name: Rahil Khan",
          style: titleFont,
        ),
        const SizedBox(height: 20),

        // Email address
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              "Email: admin@example.com",
              style: subtitle,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Phone number
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              "Phone: +1-123-456-7890",
              style: subtitle,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Role
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              "Role: Super Admin",
              style: subtitle,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Admin ID
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              "Admin ID: ADM12345",
              style: subtitle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _actions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
          },
          icon: Icon(Icons.lock, color: Colors.white),
          label: Text("Change Password"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {

          },
          icon: Icon(Icons.logout, color: Colors.red),
          label: Text(
            "Logout",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
