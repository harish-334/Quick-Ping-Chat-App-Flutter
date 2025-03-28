import 'package:flutter/material.dart';
import 'package:quick_ping/helper/dialogs.dart';
import 'package:translator/translator.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Translator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final _controller = TextEditingController();
  final _translator = GoogleTranslator();
  String _translatedText = "";
  String _selectedSourceLang = 'en';
  String _selectedTargetLang = 'hi';

  final languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'gu', 'name': 'Gujarati'},
    {'code': 'pa', 'name': 'Punjabi'},
    {'code': 'mr', 'name': 'Marathi'},
    {'code': 'ta', 'name': 'Tamil'},
  ];

  void _translateText() async {
    if (_controller.text.isEmpty) return;
    final translation = await _translator.translate(
      _controller.text,
      from: _selectedSourceLang,
      to: _selectedTargetLang,
    );
    setState(() {
      _translatedText = translation.text;
    });
  }

  // Function to copy text to clipboard
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _translatedText));
    Dialogs.showSnackbar(context, 'Copied to clipboard!');
  }

  Widget _buildDropdown(String selectedLang, ValueChanged<String?>? onChanged) {
    return DropdownButton<String>(
      value: selectedLang,
      onChanged: onChanged,
      isExpanded: true,
      items: languages
          .map((lang) => DropdownMenuItem<String>(
                value: lang['code'],
                child: Center(
                  child: Text(lang['name']!,
                      textAlign:
                          TextAlign.center), // Center text inside the dropdown
                ),
              ))
          .toList(),
    );
  }

  // Define consistent styling
  final TextStyle commonTextStyle =
      TextStyle(fontSize: 18, color: Colors.black);

  // Input Box Decoration
  final BoxDecoration inputBoxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.green),
    color: Colors.green.shade100,
  );

  // Output Box Decoration
  final BoxDecoration outputBoxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.blue),
    color: Colors.blue.shade100,
  );

  final double boxHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Translator 🌐"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Source Language Dropdown
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(_selectedSourceLang,
                          (String? newValue) {
                        setState(() {
                          _selectedSourceLang = newValue!;
                        });
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Input field
                Container(
                  height: boxHeight,
                  decoration: inputBoxDecoration,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: commonTextStyle,
                    decoration: InputDecoration(
                      hintText: "Enter text to translate",
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Target Language Dropdown
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(_selectedTargetLang,
                          (String? newValue) {
                        setState(() {
                          _selectedTargetLang = newValue!;
                        });
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Translate Button
                ElevatedButton(
                  onPressed: _translateText,
                  child: Text(
                    "Translate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    side: BorderSide(color: Colors.blue),
                    shadowColor: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),

                // Output field
                Container(
                  height: boxHeight,
                  decoration: outputBoxDecoration,
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(
                      _translatedText.isEmpty
                          ? 'Translation will appear here'
                          : _translatedText,
                      style: commonTextStyle,
                    ),
                  ),
                ),

                // Positioned copy button
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(Icons.copy, color: Colors.blue),
                    onPressed: _copyToClipboard,
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
