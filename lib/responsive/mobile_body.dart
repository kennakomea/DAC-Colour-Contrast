import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../enums/enums.dart';
import '../mobile_results_container.dart';

class MobileBody extends StatefulWidget {
  final AppView currentView;
  final File? selectedImage;
  final String? initialUrl;
  final bool isEyeDropperVisible;
  final Function(InAppWebViewController) onWebViewCreated;
  final Function(InAppWebViewController, int) onProgressChanged;

  const MobileBody({
    super.key,
    required this.currentView,
    required this.selectedImage,
    required this.initialUrl,
    required this.isEyeDropperVisible,
    required this.onWebViewCreated,
    required this.onProgressChanged,
  });

  @override
  State<MobileBody> createState() => _MobileBodyState();
}

class _MobileBodyState extends State<MobileBody> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image View
        if ((widget.currentView == AppView.gallery ||
                widget.currentView == AppView.camera) &&
            widget.selectedImage != null)
          Center(child: Image.file(widget.selectedImage!)),

        // Web View
        if (widget.currentView == AppView.web)
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse(widget.initialUrl ??
                  'https://digitalaccessibilitytraining.org/catalogue'),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                supportZoom: true,
                preferredContentMode: UserPreferredContentMode.MOBILE,
                disableVerticalScroll: widget.isEyeDropperVisible,
                javaScriptEnabled: false,
              ),
            ),
            onWebViewCreated: widget.onWebViewCreated,
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
              widget.onProgressChanged(controller, progress);
            },
          ),

        // Loading Spinner
        if (widget.currentView == AppView.web && _progress < 1)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),

        // Results Container
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ResultsContainer(),
        ),
      ],
    );
  }
}
