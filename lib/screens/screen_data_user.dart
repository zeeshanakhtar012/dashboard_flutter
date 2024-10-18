import 'package:admin/screens/screen_user_details_data.dart';
import 'package:flutter/material.dart';

class UserDataScreen extends StatelessWidget {
  final String userId;

  UserDataScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Updated uploaded data with four modules for each date
    final Map<String, List<Map<String, String>>> uploadedData = {
      '01-10-2024': [
        {'module': 'Module 1', 'uploadedAt': '01-10-2024'},
        {'module': 'Module 2', 'uploadedAt': '01-10-2024'},
        {'module': 'Module 3', 'uploadedAt': '01-10-2024'},
        {'module': 'Module 4', 'uploadedAt': '01-10-2024'},
      ],
      '02-10-2024': [
        {'module': 'Module 1', 'uploadedAt': '02-10-2024'},
        {'module': 'Module 2', 'uploadedAt': '02-10-2024'},
        {'module': 'Module 3', 'uploadedAt': '02-10-2024'},
        {'module': 'Module 4', 'uploadedAt': '02-10-2024'},
      ],
      '03-10-2024': [
        {'module': 'Module 1', 'uploadedAt': '03-10-2024'},
        {'module': 'Module 2', 'uploadedAt': '03-10-2024'},
        {'module': 'Module 3', 'uploadedAt': '03-10-2024'},
        {'module': 'Module 4', 'uploadedAt': '03-10-2024'},
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Data for $userId'),
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
              Expanded(
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
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Text('Module', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                // DataColumn(
                                //   label: Text('Uploaded At', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                // ),
                                DataColumn(
                                  label: Text('Action', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ],
                              rows: modules.map((data) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(data['module']!)),
                                    // DataCell(Text(data['uploadedAt']!)),
                                    DataCell(
                                      ElevatedButton(
                                        child: Text('View Details'),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DataDetailScreen(moduleId: data['module']!),
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
