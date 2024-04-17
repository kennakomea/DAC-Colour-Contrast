
import 'package:dac_colour_contrast/results_container.dart';
import 'package:dac_colour_contrast/web_view_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'app_provider.dart';
import 'constants.dart';

enum AppView { web, camera, gallery, home }


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}
  class _MyHomePageState extends State<MyHomePage> {
    AppView _currentView = AppView.web;
    WebViewContainer webViewContainer = WebViewContainer();
    Key webViewContainerKey = UniqueKey();
    File? _selectedImage;
    InAppWebViewController? _controller;
    double _progress = 0;
    String? initialUrl;

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          webViewContainer = WebViewContainer();
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
          webViewContainer = WebViewContainer();
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
              decoration: const InputDecoration(hintText: "https://example.com"),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Open'),
                onPressed: () {
                  _updateWebViewUrl(url);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
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
          ),],
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
              child:  Column(
                children: [
                  Image.asset(
                    'assets/images/logo_dark.png', fit: BoxFit.contain, height: 100, width: 180,
                  ),
                  const Text(
                    'Colour Contrast',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text(
                    'v1.0.0 (1)',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              onTap: () {
                Navigator.pop(context);
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Visit Our E-learning Platform'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.3,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(children: [
        if ((_currentView == AppView.gallery || _currentView == AppView.camera) && _selectedImage != null)
          Center(child: Image.file(_selectedImage!)),
        if (_currentView == AppView.web)
          InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(initialUrl?? 'https://digitalaccessibilitytraining.org/catalogue')),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              preferredContentMode: UserPreferredContentMode.MOBILE,
              disableVerticalScroll: Provider.of<AppProvider>(context, listen: false).isEyeDropperVisible,
              javaScriptEnabled: false,
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _controller = controller;
          },
          onProgressChanged: (InAppWebViewController controller, int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },

        ),
        // Add a loading spinner
        if (_currentView == AppView.web && _progress < 1)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ResultsContainer(
            ),
          )

      ]),
    );
  }
}