import 'dart:io';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class CSVController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate CSV for a specific user
  Future<void> generateUserCSV(String userId) async {
    try {
      var userData = await _firestore
          .collection('users')
          .doc(userId)
          .collection('userData')
          .get();

      List<List<dynamic>> csvData = [
        ["Module", "Data"],
      ];

      for (var doc in userData.docs) {
        csvData.add([doc.id, doc.data()]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/user_$userId.csv";
      final file = File(path);
      await file.writeAsString(csv);

      Get.snackbar("Success", "CSV generated at $path");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
  
}
