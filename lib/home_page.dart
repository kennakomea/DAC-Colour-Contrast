import 'dart:io';

import 'package:dac_colour_contrast/help.dart';
import 'package:dac_colour_contrast/responsive/mobile_body.dart';
import 'package:dac_colour_contrast/responsive/responsive_layout.dart';
import 'package:dac_colour_contrast/responsive/tablet_body.dart';
import 'package:dac_colour_contrast/send_feedback.dart';
import 'package:dac_colour_contrast/web_view_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_provider.dart';
import 'constants.dart';
import 'enums/enums.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppView _currentView = AppView.web;
  WebViewContainer webViewContainer = const WebViewContainer();
  Key webViewContainerKey = UniqueKey();
  File? _selectedImage;
  InAppWebViewController? _controller;
  double _progress = 0;
  String? initialUrl;

  @override
  void initState() {
    super.initState();
    var appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.addListener(() {
      if (_controller != null) {
        _controller!.setOptions(
            options: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            disableVerticalScroll: appProvider.isEyeDropperVisible,
          ),
        ));
      }
    });
  }

  void _pickImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        // Update the current view
        _currentView = AppView.camera;
        // Reset WebView
        webViewContainer = const WebViewContainer();
        webViewContainerKey = UniqueKey();
      });
    }
  }

  void _pickImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        // If you want to replace the WebViewContainer, reset its state
        webViewContainer = const WebViewContainer();
        webViewContainerKey = UniqueKey();
      });
    }
  }

  void _showUrlInputDialog() {
    String url = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Web URL'),
          content: TextField(
            onChanged: (value) {
              url = value;
            },
            decoration: const InputDecoration(hintText: "example.com"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Open'),
              onPressed: () {
                // Normalizing and validating URL before opening
                final normalizedUrl = _normalizeUrl(url);
                if (_validateUrl(normalizedUrl)) {
                  _updateWebViewUrl(normalizedUrl);
                  Navigator.of(context).pop();
                } else {
                  // Show error message if URL is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Invalid URL, please enter a valid URL.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

// Normalizes a URL by checking and possibly adding protocol
  String _normalizeUrl(String url) {
    // Trim whitespace
    url = url.trim();
    // Add 'https://' if no protocol is specified
    if (!url.contains('://')) {
      url = 'https://$url';
    }
    return url;
  }

// Validates a URL
  bool _validateUrl(String url) {
    // Parse the URL
    final uri = Uri.tryParse(url);
    if (uri == null ||
        (!uri.hasScheme && (uri.scheme != 'http' && uri.scheme != 'https'))) {
      return false;
    }

    // Ensure URL has a valid domain
    final domainPattern =
        RegExp(r'^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$');
    return domainPattern.hasMatch(uri.host);
  }

  void _updateWebViewUrl(String url) {
    if (_controller != null) {
      _controller!.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
    } else {
      // If the controller is not yet initialized, update the initial URL
      setState(() {
        initialUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool check =
        Provider.of<AppProvider>(context, listen: true).isEyeDropperVisible;
    debugPrint('isEyeDropperVisible******: $check');
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            widget.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            PopupMenuButton<String>(
              elevation: 1,
              icon: const Icon(
                Icons.upload_file,
                color: Colors.white,
              ),
              color: Colors.white,
              splashRadius: 20,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              offset: const Offset(0, 50),
              onSelected: (String result) {
                switch (result) {
                  case 'Web URL':
                    _showUrlInputDialog();
                    setState(() {
                      _currentView = AppView.web;
                    });
                    break;
                  case 'Camera':
                    _pickImageFromCamera();
                    setState(() {
                      _currentView = AppView.camera;
                    });
                    break;
                  case 'Gallery':
                    _pickImageFromGallery();
                    setState(() {
                      _currentView = AppView.gallery;
                    });
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Web URL',
                  child: Row(
                    children: [
                      Icon(Icons.link, color: kPrimaryColor),
                      SizedBox(width: 10),
                      Text('Web URL'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Camera',
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt, color: kPrimaryColor),
                      SizedBox(width: 10),
                      Text('Camera'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Gallery',
                  child: Row(
                    children: [
                      Icon(Icons.photo, color: kPrimaryColor),
                      SizedBox(width: 10),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
            // Suggestions Button
            // IconButton(
            //   icon: const Icon(Icons.settings_suggest, color: Colors.white),
            //   onPressed: () {
            //     // if (_resultsKey.currentState != null) {
            //     //   _resultsKey.currentState!.openSuggestionsScreen();
            //     // }
            //   },
            // ),
            // Share Button
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // if (_resultsKey.currentState != null) {
                //   _resultsKey.currentState!.shareResults();
                // }
              },
            ),
          ],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      semanticLabel: 'Colour Contrast Logo',
                      'assets/images/logo_dark.png',
                      fit: BoxFit.contain,
                      height: 100,
                      width: 180,
                    ),
                    const Text(
                      semanticsLabel: 'Colour Contrast',
                      'Colour Contrast',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const Text(
                      semanticsLabel: 'App version 1.2.7',
                      'v1.2.7',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text(
                  'Help',
                  semanticsLabel: 'Help',
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to the second screen using a named route.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('Send Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to the second screen using a named route.
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RequestFeatureScreen()));
                },
              ),
              const Divider(
                color: Colors.grey,
                thickness: 0.3,
              ),
              ListTile(
                leading: const Icon(Icons.accessibility),
                title: const Text('WCAG 2.2'),
                onTap: () {
                  Navigator.pop(context);
                  _launchURL('https://www.w3.org/WAI/WCAG22/quickref/');
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Visit Our E-learning Platform'),
                onTap: () {
                  Navigator.pop(context);
                  _launchURL(
                      'https://digitalaccessibilitytraining.org/catalogue');
                },
              ),
              const Divider(
                color: Colors.grey,
                thickness: 0.3,
              ),
            ],
          ),
        ),
        body: ResponsiveLayout(
          mobileBody: MobileBody(
            currentView: _currentView,
            selectedImage: _selectedImage,
            initialUrl: initialUrl,
            isEyeDropperVisible: Provider.of<AppProvider>(context, listen: true)
                .isEyeDropperVisible,
            onWebViewCreated: (InAppWebViewController controller) {
              setState(() {
                _controller = controller;
              });
            },
            onProgressChanged:
                (InAppWebViewController controller, int progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
          tabletBody: TabletBody(
            currentView: _currentView,
            selectedImage: _selectedImage,
            initialUrl: initialUrl,
            isEyeDropperVisible: Provider.of<AppProvider>(context, listen: true)
                .isEyeDropperVisible,
            onWebViewCreated: (InAppWebViewController controller) {
              setState(() {
                _controller = controller;
              });
            },
            onProgressChanged:
                (InAppWebViewController controller, int progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
        ));
  }

  _launchURL(String address) async {
    final Uri url = Uri.parse(address);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
