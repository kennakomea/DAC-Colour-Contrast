import 'package:dac_colour_contrast/constants.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Help', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          HelpSection(
            title: "Color Contrast",
            content: "Analyze the color contrast of selected images from either the camera or gallery. The results will show compliance with WCAG guidelines.",
          ),
          HelpSection(
            title: "Using the Eyedropper Tool",
            content: "To use the eyedropper tool, select an image either from the camera or gallery. Then, tap the eyedropper icon and click on any part of the image to select the foreground or background color. The color code and contrast ratio will automatically update based on your selection.",
          ),
          HelpSection(
            title: "Foreground (FG) Color Selection",
            content: "Tap the FG color icon to activate the eyedropper for selecting a foreground color directly from the image. The selected color will be used for color contrast calculations.",
          ),
          HelpSection(
            title: "Background (BG) Color Selection",
            content: "Tap the BG color icon to activate the eyedropper for selecting a background color. Similar to FG selection, this color will be used for contrast analysis with the FG color.",
          ),
          HelpSection(
            title: "Web URL",
            content: "Access any website by entering its URL. Tap the 'Upload File' icon, choose 'Web URL', and enter the URL you wish to access.",
          ),
          HelpSection(
            title: "Camera",
            content: "Use your camera to take photos directly within the app for color analysis. Tap the 'Upload File' icon and select 'Camera'.",
          ),
          HelpSection(
            title: "Gallery",
            content: "Select images from your device's gallery for color analysis. Tap the 'Upload File' icon and choose 'Gallery' to pick an image.",
          ),
        ],
      ),
    );
  }
}

class HelpSection extends StatelessWidget {
  final String title;
  final String content;

  const HelpSection({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content),
          ),
        ],
      ),
    );
  }
}
