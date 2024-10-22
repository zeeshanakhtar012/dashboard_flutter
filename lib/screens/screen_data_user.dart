import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/screens/screen_user_details_data.dart';

class ScreenUserDetails extends StatefulWidget {
  final String userId;

  ScreenUserDetails({required this.userId});

  @override
  _ScreenUserDetailsState createState() => _ScreenUserDetailsState();
}

class _ScreenUserDetailsState extends State<ScreenUserDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, List<Map<String, String>>> uploadedData = {};

  // Function to fetch all modules from Firestore
  Future<void> fetchAllModules() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      print("Retrieved User ID: $userId"); // Debugging line

      if (userId != null) {
        QuerySnapshot modulesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('modules')
            .get();

        Map<String, List<Map<String, String>>> modulesData = {};

        for (var doc in modulesSnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;

          String moduleName = doc.id;
          String uploadedAt = (data['time'] as Timestamp).toDate().toString();

          // Extract date and format it to "dd-MM-yyyy"
          String formattedDate = "${uploadedAt.split(' ')[0].split('-').reversed.join('-')}";

          if (!modulesData.containsKey(formattedDate)) {
            modulesData[formattedDate] = [];
          }

          modulesData[formattedDate]!.add({
            'module': moduleName,
            'time': formattedDate,
          });
        }

        setState(() {
          uploadedData = modulesData;
        });
      } else {
        Get.snackbar("Error", "User ID not found. Please log in again.", backgroundColor: Colors.red);
      }
    } catch (error) {
      Get.snackbar("Error", "Failed to fetch module data: $error", backgroundColor: Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data for ${widget.userId}'),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Uploaded Data',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Display uploaded data by date
              uploadedData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: uploadedData.keys.length,
                  itemBuilder: (context, index) {
                    String date = uploadedData.keys.elementAt(index);
                    List<Map<String, String>> modules = uploadedData[date]!;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Text('Module',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                                DataColumn(
                                  label: Text('Action',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                              rows: modules.map((data) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(data['module']!)),
                                    DataCell(
                                      ElevatedButton(
                                        child: Text('View Details'),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DataDetailScreen(
                                                      moduleId:
                                                      data['module']!),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
