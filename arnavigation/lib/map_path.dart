import 'package:flutter/material.dart';

class MapPath extends StatefulWidget {
  @override
  _MapPathState createState() => _MapPathState();
}

class _MapPathState extends State<MapPath> {
  TextEditingController _routeNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map a New Path'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Route Name',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _routeNameController,
              decoration: InputDecoration(
                hintText: 'Route Name (e.g., Room 105)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_routeNameController.text.isNotEmpty) {
                  // Here you can call an API or continue with the camera logic to start recording the path
                  // For now, let's just navigate to the camera screen (or any other page you need)
                  Navigator.pushNamed(context,
                      '/recordRoute'); // Example route, adjust as per your need
                } else {
                  // Show an error if route name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a route name.')),
                  );
                }
              },
              child: Text('Record Route'),
            ),
          ],
        ),
      ),
    );
  }
}
