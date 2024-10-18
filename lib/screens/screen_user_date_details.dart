import 'package:flutter/material.dart';

class UserDataScreen extends StatelessWidget {
  final String moduleId;

  UserDataScreen({required this.moduleId});

  @override
  Widget build(BuildContext context) {
    // Sample uploaded data with only 4 specific modules for each date
    final Map<String, List<Map<String, String>>> uploadedData = {
      '01-10-2024': [
        {'module': 'Module 1'},
        {'module': 'Module 2'},
        {'module': 'Module 3'},
        {'module': 'Module 4'},
      ],
      '02-10-2024': [
        {'module': 'Module 1'},
        {'module': 'Module 2'},
        {'module': 'Module 3'},
        {'module': 'Module 4'},
      ],
      '03-10-2024': [
        {'module': 'Module 1'},
        {'module': 'Module 2'},
        {'module': 'Module 3'},
        {'module': 'Module 4'},
      ],
      '04-10-2024': [
        {'module': 'Module 1'},
        {'module': 'Module 2'},
        {'module': 'Module 3'},
        {'module': 'Module 4'},
      ],
      // More dates can be added, ensuring each has exactly these 4 modules
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Details for $moduleId'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Makes the content scrollable
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module: $moduleId',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ...uploadedData.entries.map((entry) {
                  String date = entry.key;
                  List<Map<String, String>> modules = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date header
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(height: 10),
                      // List of uploaded modules for that date
                      for (var module in modules) // For loop for clarity
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                module['module']!,
                                style: TextStyle(fontSize: 18),
                              ),
                              // Add an action button if needed
                              ElevatedButton(
                                onPressed: () {
                                  // Handle the action (like viewing details)
                                },
                                child: Text('View Details'),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 20), // Spacing between date sections
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
