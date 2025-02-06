import 'package:dac_colour_contrast/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class RequestFeatureScreen extends StatelessWidget {
  const RequestFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Feedback", style: TextStyle(color: Colors.white)),
          backgroundColor: kPrimaryColor),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Help us improve',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor)),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                  'Whether you have a feature request or want to report a bug, your feedback is valuable to us.',
                  style: TextStyle(fontSize: 16)),
            ),
            FeedbackForm(),
          ],
        ),
      ),
    );
  }
}

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isFeature = true; // Toggle between feature request and bug report

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToggleButtons(
          borderColor: Colors.deepPurple,
          fillColor: kPrimaryColor,
          selectedBorderColor: kPrimaryColor,
          selectedColor: Colors.white,
          borderRadius: BorderRadius.circular(4),
          onPressed: (int index) {
            setState(() {
              _isFeature = index == 0;
            });
          },
          isSelected: [_isFeature, !_isFeature],
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Feature Request'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Bug Report'),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            'Your Feedback',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          controller: _feedbackController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Please describe in detail...',
            border: OutlineInputBorder(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: ElevatedButton(
              onPressed: () => _submitFeedback(),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: kPrimaryColor,
              ),
              child:
                  const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  void _submitFeedback() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Add logic to handle the feedback submission
    try {
      final Email email = Email(
        body: _feedbackController.text,
        subject: _isFeature ? 'Feature Request' : 'Bug Report',
        recipients: ['kenn.akomea@digitalaccessibilitycentre.org'],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send feedback. ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    _feedbackController.clear();
  }
}
