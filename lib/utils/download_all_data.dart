import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> fetchFirestoreDataAndExportCSV() async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Predefined module names
    final moduleNames = ['TradeAsset', 'NewAsset', 'MarketVisit', 'MarketIntelligence'];

    final usersCollection = firestore.collection('users');
    final usersSnapshot = await usersCollection.get();

    final allData = <Map<String, dynamic>>[];

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;

      for (var moduleName in moduleNames) {
        // Access the specific module collection
        final moduleRef = userDoc.reference.collection('modules').doc(moduleName);

        // Check if the module document exists
        final moduleSnapshot = await moduleRef.get();
        if (moduleSnapshot.exists) {
          // Fetch all dataByDate entries for the module
          final dataByDateCollection = moduleRef.collection('dataByDate');
          final dataByDateSnapshot = await dataByDateCollection.get();

          for (var dataDoc in dataByDateSnapshot.docs) {
            final data = {
              'userId': userId,
              'moduleName': moduleName,
              ...dataDoc.data(),
            };
            allData.add(data);
          }
        }
      }
    }

    // Convert all data to CSV
    if (allData.isNotEmpty) {
      // Headers for CSV
      final headers = allData.first.keys.map((key) => key.toString()).toList();
      final rows = <List<String>>[headers];

      // Add rows of data
      for (var data in allData) {
        rows.add(headers.map((key) => data[key]?.toString() ?? "").toList());
      }

      // Generate CSV content
      final csvContent = const ListToCsvConverter().convert(rows);

      // Save CSV file
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory?.path}/firestore_data.csv';
        final file = File(filePath);
        await file.writeAsString(csvContent);

        print("CSV file saved at: $filePath");
      } else {
        print("Storage permission denied.");
      }
    } else {
      print("No data found to export.");
    }
  } catch (e) {
    print("Error fetching Firestore data: $e");
  }
}