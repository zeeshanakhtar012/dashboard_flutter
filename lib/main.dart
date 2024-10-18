import 'package:admin/constants.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/screens/screen_login.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/controller_admin.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AdminController adminController = Get.put(AdminController()); // Initialize AdminController

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jazz Power',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: FutureBuilder(
        future: adminController.checkAdminLoginStatus(), // Check login status
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking the login status
            return Center(child: CircularProgressIndicator());
          } else {
            return adminController.isLoggedIn.value ? MainScreen() : ScreenLogin();
          }
        },
      ),
    );
  }
}
