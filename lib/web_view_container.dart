import 'package:dac_colour_contrast/results_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';

class WebViewContainer extends StatefulWidget {
  final String? initialUrl;

  const WebViewContainer({super.key, this.initialUrl});

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  static const MethodChannel _methodChannel = MethodChannel('color_picker');
  InAppWebViewController? _controller;

  InAppWebViewController get webViewController => _controller!;

  //late String currentUrl;

  @override
  void initState() {
    super.initState();
  }

  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    String url = widget.initialUrl ?? 'https://www.pub.dev';

    return Scaffold(
        body: Stack(children: [
      InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(url)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(

            javaScriptEnabled: true,
          ),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          _controller = controller;
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          setState(() {
            _progress = progress / 100; // Convert progress to a percentage
          });
        },
      ),
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ResultsContainer(),
        )
    ]));
  }
}
