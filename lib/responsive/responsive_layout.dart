import 'package:flutter/cupertino.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget tabletBody;
  const ResponsiveLayout(
      {super.key, required this.mobileBody, required this.tabletBody});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return mobileBody;
      } else {
        return tabletBody;
      }
    });
  }
}
