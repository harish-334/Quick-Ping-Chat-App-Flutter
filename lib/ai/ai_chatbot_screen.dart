import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:quick_ping/helper/dialogs.dart';

class AIChatbotScreen extends StatefulWidget {
  @override
  _AIChatbotScreenState createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  final String apiKey =
      "your_api"; // 🔐 Secure your API key
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=";

  Future<void> sendMessage(String userMessage) async {
    setState(() {
      messages.add({"role": "user", "text": userMessage});
      messages.add({
        "role": "ai",
        "text": "🧠 is generating response..."
      }); // Temporary AI message
    });

    var requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": userMessage}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        Uri.parse("$apiUrl$apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiReply = data["candidates"][0]["content"]["parts"][0]["text"] ??
            "🤖 No response.";

        setState(() {
          messages[messages.length - 1] = {
            "role": "ai",
            "text": aiReply
          }; // Replace loading message
        });

        _scrollToBottom();
      } else {
        setState(() {
          messages[messages.length - 1] = {
            "role": "ai",
            "text": "Error: Unable to fetch response."
          };
        });
      }
    } catch (e) {
      setState(() {
        messages[messages.length - 1] = {
          "role": "ai",
          "text": "Error: Something went wrong."
        };
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _chatBubble(String text, bool isUser) {
    bool isLoadingMsg = text.startsWith("🧠 is generating response");

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        Dialogs.showSnackbar(context, 'Copied to clipboard!');
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser ? Color.fromARGB(255, 218, 255, 176) : Colors.white,
            border: Border.all(
                color: isUser ? Colors.lightGreen : Colors.lightBlue),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: isUser ? Radius.circular(30) : Radius.zero,
              bottomRight: isUser ? Radius.zero : Radius.circular(30),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: isLoadingMsg ? Colors.black54 : Colors.black87,
              fontSize: 16,
              fontStyle: isLoadingMsg ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Type message...",
                hintStyle: TextStyle(color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white, // Keeps the input background white
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  sendMessage(_controller.text);
                  _controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Chatbot 🤖"),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return _chatBubble(msg["text"]!, msg["role"] == "user");
                },
              ),
            ),
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            _chatInput(), // Fixed input field at the bottom
          ],
        ),
      ),
    );
  }
}
