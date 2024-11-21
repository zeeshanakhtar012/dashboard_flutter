import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:admin/utils/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/modules.dart';
import '../models/user.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var userData = Map<String, dynamic>().obs;
  var usersList = <User>[].obs;
  var isLoading = false.obs;
  var userModules = <Map<String, dynamic>>[].obs;
  var searchUserByName = TextEditingController().obs;
  String? selectedFilePath;

  List<String> validModules = [
    "MarketIntelligence",
    "MarketVisit",
    "NewAsset",
    "TradeAsset",
  ];

  // pick csv file
  Future<void> pickAndUploadCSV() async {
    try {
      // Open file picker to select only CSV files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'], // Restrict to CSV files
      );

      if (result != null && result.files.single.bytes != null) {
        // Access file data as bytes
        List<int> fileBytes = result.files.single.bytes!;
        print("File selected: ${result.files.single.name}");

        // Call your processing and uploading function
        await saveUserCSVFromBytes(fileBytes);
        FirebaseUtils.showSuccess("CSV file uploaded successfully!");
      } else {
        // User canceled the picker or no file selected
        FirebaseUtils.showError("No file selected.");
      }
    } catch (e) {
      print("Error picking file: $e");
      FirebaseUtils.showError("Failed to pick or upload the file.");
    }
  }
  // adding bulk user to firestore == 500 this is the firestore limit you cannot exceed it
  Future<void> saveUserCSVFromBytes(List<int> fileBytes) async {
    try {
      // Convert bytes to a string (CSV content)
      String fileContents = utf8.decode(fileBytes);
      final List<List<dynamic>> fields = const CsvToListConverter().convert(fileContents);

      final headers = fields[0];
      final dataRows = fields.sublist(1);

      final usersCollection = FirebaseFirestore.instance.collection('users');

      // Chunk the rows into groups of 500
      final chunkSize = 500;
      for (int i = 0; i < dataRows.length; i += chunkSize) {
        final chunk = dataRows.sublist(
            i, i + chunkSize > dataRows.length ? dataRows.length : i + chunkSize);

        final batch = FirebaseFirestore.instance.batch();

        for (var row in chunk) {
          final user = User(
            userId: row[headers.indexOf('userId')].toString(),
            phoneNumber: row[headers.indexOf('phoneNumber')].toString(),
            email: row[headers.indexOf('email')].toString(),
            userName: row[headers.indexOf('userName')].toString(),
            fid: row[headers.indexOf('fid')].toString(),
            employeeId: row[headers.indexOf('employeeId')].toString(),
            designation: row[headers.indexOf('designation')].toString(),
            region: row[headers.indexOf('region')].toString(),
            mbu: row[headers.indexOf('mbu')].toString(),
            userAddress: row[headers.indexOf('userAddress')].toString(),
            password: row[headers.indexOf('password')].toString(),
            imageUrl: row[headers.indexOf('imageUrl')].toString(),
          );

          final userDocRef = usersCollection.doc(user.userId);
          batch.set(userDocRef, user.toMap());
        }

        // Commit the batch
        await batch.commit();
        log("Chunk of ${chunk.length} users saved successfully!");
        FirebaseUtils.showSuccess("users saved successfully!");
      }

      log("All users saved successfully!");
      FirebaseUtils.showSuccess("users saved successfully!");
    } catch (e) {
      // In case of error, hide the loading indicator and show an error message
      isLoading.value = false;
      log("Error processing CSV file: $e");
      FirebaseUtils.showError("Failed to process the CSV file.");
    }
  }
  // fetch user details modules data
  Future<void> fetchAllUsersWithModules() async {
    try {
      isLoading(true);
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      // Clear existing data only if necessary, otherwise leave it intact
      if (usersList.isNotEmpty) usersList.clear();

      // Fetch users in parallel
      await Future.wait(usersSnapshot.docs.map((userDoc) async {
        User user = User.fromDocumentSnapshot(userDoc.data() as Map<String, dynamic>);
        user.modules = [];
        QuerySnapshot modulesSnapshot = await userDoc.reference.collection('modules').get();
        await Future.wait(modulesSnapshot.docs.map((moduleDoc) async {
          Module module = Module.fromMap(moduleDoc.data() as Map<String, dynamic>);
          module.dataByDate = [];
          QuerySnapshot dataByDateSnapshot = await moduleDoc.reference.collection('dataByDate').get();
          module.dataByDate.addAll(dataByDateSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
          user.modules.add(module);
        }));

        // Add user to usersList once the modules have been processed
        usersList.add(user);
        log("Fetched users with modules: ${usersList.join(', ')}");
      }));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users and modules: $e');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
  }

  fetchAllUsers() async {
    try {
      isLoading(true);
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      usersList.value = querySnapshot.docs.map((doc) {
        return User.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
      }).toList();
      log("Fetched users: ${usersList.join(', ')}");
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchUserData(String userId) async {
    // Reference to the user's document
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Fetch the user details
    DocumentSnapshot userSnapshot = await userDocRef.get();
    if (userSnapshot.exists) {
      var userData = userSnapshot.data();
      log("Fetched user details: $userData");

      // Reference to the 'modules' subcollection
      final modulesRef = userDocRef.collection('modules');

      // Fetch modules (like MarketIntelligence, MarketVisit, etc.)
      QuerySnapshot modulesSnapshot = await modulesRef.get();
      log("Modules snapshot count: ${modulesSnapshot.docs.length}");

      if (modulesSnapshot.docs.isNotEmpty) {
        for (var moduleDoc in modulesSnapshot.docs) {
          log("Fetched module: ${moduleDoc.id}");

          // Fetch the 'dataByDate' subcollection for each module
          final dataByDateRef = moduleDoc.reference.collection('dataByDate');
          QuerySnapshot dataByDateSnapshot = await dataByDateRef.get();

          log("Data by date snapshot count for module ${moduleDoc.id}: ${dataByDateSnapshot.docs.length}");

          if (dataByDateSnapshot.docs.isNotEmpty) {
            for (var dataDoc in dataByDateSnapshot.docs) {
              print("Fetched data document with ID: ${dataDoc.id}");
              var data = dataDoc.data();

              // Merge the user data and module data here
              // Example: user data + module data (dataDoc.data)
              // You can now process or store this merged data for CSV generation or other purposes
            }
          } else {
            log("No data found in dataByDate for module: ${moduleDoc.id}");
          }
        }
      } else {
        log("No modules found for user: $userId");
      }
    } else {
      log("User document not found for userId: $userId");
    }
  }
  // generate csv file
  Future<String> generateCsv(String userId) async {
    // Fetch user details from Firestore
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userSnapshot.exists) {
      log("User not found");
      return "";
    }

    // Extract user details from the snapshot
    String userName = userSnapshot['userName'] ?? 'N/A';
    String email = userSnapshot['email'] ?? 'N/A';
    String designation = userSnapshot['designation'] ?? 'N/A';
    String employeeId = userSnapshot['employeeId'] ?? 'N/A';
    String phoneNumber = userSnapshot['phoneNumber'] ?? 'N/A';
    String region = userSnapshot['region'] ?? 'N/A';
    String mbu = userSnapshot['mbu'] ?? 'N/A';
    String userAddress = userSnapshot['userAddress'] ?? 'N/A';

    // Initialize the CSV rows
    List<List<String>> rows = [];

    // Add header row
    rows.add([
      "User ID",
      "User Name",
      "Email",
      "Designation",
      "Employee ID",
      "Phone Number",
      "Region",
      "MBU",
      "User Address",
      "Module Name",
      "Company Asset Type",
      "Retailer Name",
      "Retailer Address",
      "Location",
      "Field 5",
      "Images",
      "Location",
      "Time Uploaded",
      "Date Uploaded",
      "Visit Date"
    ]);

    // Predefined list of valid module names
    List<String> validModules = [
      "MarketIntelligence",
      "MarketVisit",
      "NewAsset",
      "TradeAsset",
    ];

    bool hasModulesData = false; // Flag to track if modules data is found

    // Iterate over valid modules and fetch their data
    for (String moduleName in validModules) {
      try {
        // Fetch the dataByDate collection for each module
        QuerySnapshot dataByDateSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('modules')
            .doc(moduleName)
            .collection('dataByDate')
            .get();

        if (dataByDateSnapshot.docs.isEmpty) {
          log("No data found in module $moduleName for user $userId");
          continue;
        }

        hasModulesData = true; // Modules data found

        // Process each document in the dataByDate collection
        for (var doc in dataByDateSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Extract and handle `time` field (as Timestamp)
          String time = data.containsKey('time') && data['time'] is Timestamp
              ? (data['time'] as Timestamp).toDate().toIso8601String()
              : 'N/A';

          // Extract and handle `visitDate` field (as Timestamp)
          String visitDate = data.containsKey('visitDate') && data['visitDate'] is Timestamp
              ? (data['visitDate'] as Timestamp).toDate().toIso8601String()
              : 'N/A';

          // Handle other fields safely
          String assetType = data['assetType'] ?? 'N/A';
          String location = data['location'] ?? 'N/A';
          String retailerName = data['retailerName'] ?? 'N/A';
          String retailerAddress = data['retailerAddress'] ?? 'N/A';

          // Handle images list
          List<String> images = (data['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
              ['N/A'];
          String imageList = images.join(", "); // Convert list to a comma-separated string

          // Log the fetched data for debugging
          log("time: $time, visitDate: $visitDate");

          // Add a new row for each module's data, keeping user details in place
          rows.add([
            // Add user details only once in the first row
            (rows.length == 1) ? userId : '',
            (rows.length == 1) ? userName : '',
            (rows.length == 1) ? email : '',
            (rows.length == 1) ? designation : '',
            (rows.length == 1) ? employeeId : '',
            (rows.length == 1) ? phoneNumber : '',
            (rows.length == 1) ? region : '',
            (rows.length == 1) ? mbu : '',
            (rows.length == 1) ? userAddress : '',
            moduleName,
            assetType,
            retailerName,
            retailerAddress,
            location,
            "N/A", // Placeholder for Field 5
            imageList,
            location,
            time, // Time Uploaded
            time, // Duplicate time as Date Uploaded
            visitDate,
          ]);
        }
      } catch (e) {
        log("Error fetching module data for $moduleName: $e");
      }
    }

    // If no modules were found, add a row with 'N/A' for module fields
    if (!hasModulesData) {
      rows.add([
        userId,
        userName,
        email,
        designation,
        employeeId,
        phoneNumber,
        region,
        mbu,
        userAddress,
        "N/A",
        "N/A",
        "N/A",
        "N/A",
        "N/A",
        "N/A",
        "N/A",
        "N/A",
        "N/A",
      ]);
    }

    // Convert the rows into CSV format
    String csvData = const ListToCsvConverter().convert(rows);
    log("Generated CSV Data:\n$csvData");

    return csvData; // Return the generated CSV data
  }

  // download csv fil
  Future<void> downloadCsv(String userId) async {
    try {
      String csvData = await generateCsv(userId);
      if (csvData.isEmpty) {
        Get.snackbar("Error", "CSV data is empty, user not found.");
        return;
      }

      String fileName =
          "user_report_${userId}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv";

      // Web download logic or mobile download logic here
      // For example:
      if (kIsWeb) {
        // Web download logic
        final bytes = utf8.encode(csvData);
        final blob = html.Blob([Uint8List.fromList(bytes)], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        Get.snackbar(
          snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            "Success", "CSV file is being downloaded");
      } else {

        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/$fileName";
        File file = File(path);
        await file.writeAsString(csvData);
        Get.snackbar(
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            "Success", "CSV saved at: $path");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to download/save CSV: $e");
    }
  }

  // save user to firestore
  Future<void> saveUserToFirestore(User user) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.userId)
        .set(user.toMap())
        .then((_) {
      print("User saved successfully!");
    }).catchError((error) {
      print("Failed to save user: $error");
    });
  }
  // template csv file generator
  Future<void> generateCSVTemplate() async {
    try {
      // Define the headers for the CSV file
      List<String> headers = [
        'userId',
        'phoneNumber',
        'fid',
        'employeeId',
        'designation',
        'email',
        'deviceToken',
        'region',
        'mbu',
        'userName',
        'password',
        'userAddress',
        'imageUrl',
        'linkedRetailers', // Optional: for JSON-like data
      ];

      // Add a row of sample data for reference (optional)
      List<List<String>> rows = [
        headers,
        [
          '12345',
          '+1234567890',
          'FID123',
          'EID001',
          'Manager',
          'zeeshanakhtar.ffc@gmail.com',
          'DeviceTokenXYZ',
          'North Region',
          'MBU001',
          'Zeeshan Akhtar',
          '12345678',
          '123 Street Name',
          'https://example.com/image.jpg',
          '{"RetailerA": "RetailerID001"}', // JSON-like string for linkedRetailers
        ]
      ];

      // Convert rows to CSV format
      String csvData = const ListToCsvConverter().convert(rows);

      // Convert to Blob for web download
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'csv_template.csv'; // File name for download

      anchor.click();

      print("CSV template generated and download started.");
    } catch (e) {
      print("Error generating CSV template: $e");
    }
  }
  // Method to remove a user from Firestore by userId
  Future<void> removeUserFromFirestore(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      Get.snackbar("Success", "User removed successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
      usersList.removeWhere((user) => user.userId == userId);
    } catch (e) {
      Get.snackbar("Error", "Failed to remove user: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Error removing user: $e");
    }
  }

  // get users from firestore
  Future<User?> getUserFromFirestore(String userId) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists) {
      return User.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Update user details
  Future<void> updateUserInFirestore(User user) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.userId).get();
      if (doc.exists) {
        await _firestore
            .collection('users')
            .doc(user.userId)
            .update(user.toMap());
        Get.snackbar("Success", "User updated successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "User not found.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update user: $e");
      print("Failed to update user: $e");
    }
  }

  // Add this method to UserController
  Future<void> searchUsersByUsername(String username) async {
    try {
      isLoading(true);
      String trimmedUsername = username.trim();
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userName',
              isGreaterThanOrEqualTo:
                  trimmedUsername) // Start matching from the trimmed username
          .where('userName',
              isLessThanOrEqualTo:
                  trimmedUsername + '\uf8ff') // Include all possible endings
          .get();

      usersList.value = querySnapshot.docs.map((doc) {
        return User.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
      }).toList();
      log("User found = ${querySnapshot}");
      if (usersList.isEmpty) {
        Get.snackbar('Info', 'No users found matching "$trimmedUsername".');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to search users: $e');
    } finally {
      isLoading(false);
    }
  }

  //
  Future<void> fetchUserListWithModules() async {
    try {
      // Fetch all users from the 'users' collection
      var userQuerySnapshot = await _firestore.collection('users').get();

      // Iterate through each user document
      for (var userDoc in userQuerySnapshot.docs) {
        String userId = userDoc.id;
        Map<String, dynamic> userData = userDoc.data();

        log('User ID: $userId, User Data: $userData');

        // Initialize a map to store module data for this user
        Map<String, dynamic> modulesData = {};
        List<String> moduleNames = [
          'MarketVisit',
          'MarketIntelligence',
          'NewAsset',
          'TradeAsset'
        ];

        // Fetch each module's subcollection data
        for (String moduleName in moduleNames) {
          var moduleSnapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('modules')
              .doc(moduleName)
              .get();

          if (moduleSnapshot.exists) {
            Map<String, dynamic>? moduleData = moduleSnapshot.data();
            modulesData[moduleName] =
                moduleData ?? {}; // Store the module data in the map
            log('$moduleName data for User $userId: $moduleData');
          } else {
            log('$moduleName data not found for User $userId');
          }
        }

        // Now you have user data and their module data in modulesData
        log('All module data for User $userId: $modulesData');
      }
    } catch (e) {
      log('Error fetching users with modules: $e');
    }
  }
}
