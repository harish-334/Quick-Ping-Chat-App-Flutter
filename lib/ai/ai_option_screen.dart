import 'package:flutter/material.dart';
import 'package:quick_ping/ai/ai_chatbot_screen.dart';
import 'package:quick_ping/ai/ai_image_generator.dart';
import 'package:quick_ping/ai/translator_screen.dart';

class AIOptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Intelli-Space 🧠"),
        backgroundColor: Color(0xFFF8F4FC),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'images/ai_friend.png',
                width: MediaQuery.of(context).size.width * 0.6,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AIOptionTile(
                  title: "AI Chatbot",
                  icon: Icons.smart_toy_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AIChatbotScreen()),
                    );
                  },
                ),
                AIOptionTile(
                  title: "Translator",
                  icon: Icons.translate_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TranslationScreen()),
                    );
                  },
                ),
                AIOptionTile(
                  title: "AI Image Generator",
                  icon: Icons.image_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AiImageGenerator()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AIOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const AIOptionTile(
      {required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade400, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100,
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Icon Background
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: Colors.blue.shade700),
            ),
            SizedBox(width: 16),
            // Title Text
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.blue.shade600),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Text(
          "This is the $title screen",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
