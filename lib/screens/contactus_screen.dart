import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:quick_ping/helper/dialogs.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: ContactForm(),
    );
  }
}

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(); // No country code prefix
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _sendEmail() async {
    if (!_formKey.currentState!.validate()) {
      return; // If validation fails, return and don't send email
    }

    // Show progress indicator
    Dialogs.showProgressBar(context);

    // Simple Email body without bold or italic formatting
    String emailBody = '''
Name: ${_nameController.text}

Phone Number: ${_phoneController.text}

Description: ${_descriptionController.text}
''';

    final Email email = Email(
      body: emailBody,
      subject:
          'Quick Ping Contact Form Submission: Inquiry from ${_nameController.text}',
      recipients: ['harishsondagar3@gmail.com'], // Your email address here
      isHTML: false, // Sending email in plain text
    );

    try {
      await FlutterEmailSender.send(email);

      // Dismiss progress indicator and show success message
      Navigator.of(context).pop();
      Dialogs.showSnackbar(context, 'Email Sent!');
    } catch (error) {
      // Dismiss progress indicator and show error message
      Navigator.of(context).pop();
      Dialogs.showSnackbar(context, 'Error sending email');
    }
  }

  // Validator for phone number
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Ensure the value is exactly 10 digits
    final phoneRegExp = RegExp(r'^\d{10}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  // Method to show info message when "i" button is pressed
  void _showInfoMessage(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        'Submit your message and expect a response within three business days.',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        elevation: 0,
        backgroundColor: Color(0xFFF8F4FC),
        centerTitle: true,
        actions: [
          // "i" button to show information message
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.blueAccent),
            onPressed: () => _showInfoMessage(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get in Touch',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: 'Your Name',
                  hint: 'Enter your name',
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                ),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Your Phone Number',
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                  ],
                ),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter your message',
                  maxLines: 6,
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _sendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLines = 1,
    required String? Function(String?) validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.blueGrey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
