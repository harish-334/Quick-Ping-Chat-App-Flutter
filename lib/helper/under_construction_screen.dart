import 'package:flutter/material.dart';

class UnderConstructionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
        backgroundColor: Colors.orangeAccent, // AppBar background color
        title: Text('Under Construction'), // Title of the AppBar
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Centered content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/under_construction.png', // Image below the icon
                  height: 200, // Adjust the height as needed
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  'Under Construction',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'We are working on something great!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orangeAccent,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
