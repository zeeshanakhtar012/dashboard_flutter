// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
//
// class AdminController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Update data in Firestore for all users
//   Future<void> updateDataForUsers(String dataPath, Map<String, dynamic> updatedData) async {
//     try {
//       var usersSnapshot = await _firestore.collection('users').get();
//       for (var user in usersSnapshot.docs) {
//         await _firestore.collection('users').doc(user.id).update({
//           dataPath: updatedData,
//         });
//       }
//       Get.snackbar("Success", "Data updated successfully for all users!");
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//     }
//   }
//
//   // Fetch all users (admin dashboard usage)
//   Future<QuerySnapshot> fetchAllUsers() async {
//     return await _firestore.collection('users').get();
//   }
//
//   // Fetch all retailers (admin dashboard usage)
//   Future<QuerySnapshot> fetchAllRetailers() async {
//     return await _firestore.collection('retailers').get();
//   }
// }
