import 'package:flutter/material.dart';

class DataDetailScreen extends StatelessWidget {
  final String moduleId;

  DataDetailScreen({required this.moduleId});

  @override
  Widget build(BuildContext context) {
    final dataDetails = {
      'data': 'Some detailed data for $moduleId',
      'status': 'Completed',
      'uploadedAt': '01-10-2024',
    };

    final images = [
      'https://images.unsplash.com/photo-1607603750916-eaf866bc907d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1607603750916-eaf866bc907d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1607603750916-eaf866bc907d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1607603750916-eaf866bc907d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1607603750916-eaf866bc907d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1607603750916-eaf866bc907d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ];

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
                Text('Uploaded Data:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(dataDetails['data']!, style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                Text('Status: ${dataDetails['status']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Uploaded At: ${dataDetails['uploadedAt']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                Text('Images:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                // Updated GridView
                GridView.builder(
                  shrinkWrap: true,  // Allows GridView to fit inside the Column
                  physics: NeverScrollableScrollPhysics(),  // Disable scroll within the GridView to use the main scroll
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,  // 3 images per row
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.0,  // Aspect ratio to control image size
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0), // Round the corners
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: 80, // Adjusted width for smaller images
                          height: 80, // Adjusted height for smaller images
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
