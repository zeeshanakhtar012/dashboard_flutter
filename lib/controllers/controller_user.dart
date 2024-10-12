import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  Future<void> uploadModuleData(String moduleName, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('modules')
          .doc(moduleName)
          .set({
        'data': data,
        'uploadedAt': Timestamp.now(),
        'status': 'completed',
      });
    } else {
      print("Error: User is not logged in.");
    }
  }

  // Optionally, you can add methods for fetching user module data and showing progress
  Future<void> getUserModuleProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId'); // Retrieve user ID

    if (userId != null) {
      var modulesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('modules')
          .get();

      for (var doc in modulesSnapshot.docs) {
        print('Module: ${doc.id}, Data: ${doc['data']}, Status: ${doc['status']}');
      }
    } else {
      print("Error: User is not logged in.");
    }
  }
}
