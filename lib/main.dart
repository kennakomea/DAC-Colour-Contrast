import 'package:flutter/material.dart';

import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colour Contrast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF234b6e)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Colour Contrast'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              setState(() {
                // Handle the selection
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Web URL',
                child: Row(
                  children: [
                    Icon(Icons.link, color: kPrimaryColor),
                    const SizedBox(width: 10),
                    Text('Web URL'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Camera',
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt, color: kPrimaryColor),
                    const SizedBox(width: 10),
                    Text('Camera'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Gallery',
                child: Row(
                  children: [
                    const Icon(Icons.photo, color: kPrimaryColor),
                    const SizedBox(width: 10),
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
          ],
        ),
      ),
      body: Container(
        // Web view goes here
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
