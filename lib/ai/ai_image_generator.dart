//https://www.imagine.art/dashboard
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_ping/ai/image_api.dart'; // Your API class for image generation

class AiImageGenerator extends StatefulWidget {
  const AiImageGenerator({super.key});

  @override
  State<AiImageGenerator> createState() => _AiImageGeneratorState();
}

class _AiImageGeneratorState extends State<AiImageGenerator> {
  TextEditingController tc = TextEditingController();
  bool isloading = true;
  bool isprog = false;
  Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Disable scroll to prevent extra scrolling
      appBar: AppBar(
        title: Text("AI Image Generator 🖼️"),
        backgroundColor: Colors.white, // Matching with the theme
        elevation: 0, // Flat app bar for minimalism
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard if tapped outside
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Text Field for Prompt with light green background and green border
            Container(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: tc,
                maxLines: null,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  labelText: "Enter Prompt!",
                  labelStyle: TextStyle(color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  filled: true,
                  fillColor:
                      Colors.lightGreen.shade100, // Light green background
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Generate Image Button with blue accent and rounded corners
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Button color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                var prompt = tc.text.trim();
                if (prompt.isNotEmpty) {
                  setState(() {
                    isprog = true;
                  });
                  imgapi.HandlePrompt(prompt).then((value) {
                    setState(() {
                      imageBytes = value;
                      isloading = false;
                      isprog = false;
                    });
                  }).catchError((e) {
                    setState(() {
                      isprog = false;
                    });
                    // Handle any error in API response
                  });
                }
              },
              child: isprog
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Generate Image", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
            // Image Container with blue border and light blue inside
            Container(
              height: MediaQuery.of(context).size.height * .4, // Adjust height
              margin: EdgeInsets.all(20), // Space between the image and edges
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.blue), // Blue border for the image
                borderRadius: BorderRadius.circular(20),
                color: Colors.lightBlue
                    .shade50, // Light blue background inside the border
              ),
              child: isloading
                  ? Center(
                      child: Text(
                        'Your generated image will appear here.',
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    )
                  : ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                      child: Image.memory(imageBytes!, fit: BoxFit.cover),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
