import 'dart:math';

import 'package:dac_colour_contrast/app_provider.dart';
import 'package:dac_colour_contrast/constants.dart';
import 'package:dac_colour_contrast/suggestions.dart';
import 'package:eye_dropper/eye_dropper.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ResultsContainer extends StatefulWidget {
  const ResultsContainer({super.key});

  @override
  State<ResultsContainer> createState() => _ResultsContainerState();
}

class _ResultsContainerState extends State<ResultsContainer> {
  Color? _fgColor;
  Color? _bgColor;

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  double _calculateContrastRatio(Color color1, Color color2) {
    double luminance1 = _calculateLuminance(color1);
    double luminance2 = _calculateLuminance(color2);

    // Ensure luminance1 is the lighter color (higher luminance)
    if (luminance1 < luminance2) {
      double temp = luminance1;
      luminance1 = luminance2;
      luminance2 = temp;
    }
    return (luminance1 + 0.05) / (luminance2 + 0.05);
  }

  double _calculateLuminance(Color color) {
    double red = color.red / 255.0;
    double green = color.green / 255.0;
    double blue = color.blue / 255.0;

    red = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4).toDouble();
    green = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4).toDouble();
    blue = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
  }

  void _shareResults() {
    if (_fgColor != null && _bgColor != null) {
      double ratio = _calculateContrastRatio(_fgColor!, _bgColor!);
      String result = 'Color Contrast Results:\n'
          'Foreground Color: #${_fgColor!.value.toRadixString(16)}\n'
          'Background Color: #${_bgColor!.value.toRadixString(16)}\n'
          'Contrast Ratio: ${ratio.toStringAsFixed(2)}:1\n'
          'WCAG AA Compliance: ${ratio >= 4.5 ? "Pass" : "Fail"}\n'
          'WCAG AAA Compliance: ${ratio >= 7.0 ? "Pass" : "Fail"}';
      Share.share(result);
    } else {
      Share.share('Color contrast results are not available yet.');
    }
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _openSuggestionsScreen() {
    if (_fgColor != null && _bgColor != null) {
      double ratio = _calculateContrastRatio(_fgColor!, _bgColor!);
      if (ratio < 4.5) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SuggestionsScreen(
              fgColor: _fgColor!,
              bgColor: _bgColor!,
              contrastRatio: ratio,
              onColorSelected: (selectedColor, isForeground) {
                setState(() {
                  if (isForeground) {
                    _fgColor = selectedColor;
                  } else {
                    _bgColor = selectedColor;
                  }
                });
                Navigator.pop(context);
              },
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contrast ratio is already compliant.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both FG and BG colours.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: true);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width,
      child: DraggableScrollableSheet(
          initialChildSize: isExpanded ? 1 : 0.7,
          minChildSize: isExpanded ? 1 : 0.7,
          maxChildSize: isExpanded ? 1 : 0.7,
          builder: (context, scrollController) {
            return Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TextButton.icon(
                              onPressed: toggleExpansion,
                              icon: Icon(isExpanded ? Icons.expand_more : Icons.expand_less),
                              label: Text(isExpanded ? 'Collapse' : 'Expand'),
                            ),
                          ),
                          const Text(
                            'Results',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: kPrimaryColor),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _openSuggestionsScreen,
                                icon: const Icon(Icons.settings_suggest),
                              ),
                              IconButton(
                                onPressed: _shareResults,
                                icon: const Icon(Ionicons.share_social),
                              ),
                            ],
                          )
                        ],
                      ),
                      Divider(
                        color: kPrimaryColor.withOpacity(0.5),
                        thickness: 0.2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: PickedColour(
                                icon: IconButton(
                                    onPressed: () {
                                      appProvider.isEyeDropperVisible = true;
                                      EyeDropper.enableEyeDropper(context, (color) {
                                        setState(() {
                                          _fgColor = color;
                                        });
                                        appProvider.isEyeDropperVisible = false;
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            side: const BorderSide(
                                                color: kPrimaryColor, width: 2),
                                          )),
                                    ),
                                    icon: const Icon(Ionicons.eyedrop_outline)),
                                pickedColour: _fgColor ?? Colors.deepOrange,
                                hexCode: _fgColor != null
                                    ? '#${_fgColor?.value.toRadixString(16)}'
                                    : 'N/A',
                                label: 'FG Colour',
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _fgColor != null && _bgColor != null
                                      ? '${_calculateContrastRatio(
                                      _fgColor!, _bgColor!).toStringAsFixed(2)}:1'
                                      : 'N/A',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 26),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _fgColor != null && _bgColor != null
                                        ? WCAGTextResult(
                                        contrastRatio: _calculateContrastRatio(
                                            _fgColor!, _bgColor!))
                                        : const WCAGTextResult(contrastRatio: 0),
                                    const SizedBox(width: 15),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                              child: PickedColour(
                                icon: IconButton(
                                    onPressed: () {
                                      appProvider.isEyeDropperVisible = true;
                                      EyeDropper.enableEyeDropper(context, (color) {
                                        setState(() {
                                          _bgColor = color;
                                        });
                                        appProvider.isEyeDropperVisible = false;
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            side: const BorderSide(
                                                color: kPrimaryColor, width: 2),
                                          )),
                                    ),
                                    icon: const Icon(Ionicons.eyedrop)),
                                pickedColour: _bgColor ?? Colors.deepOrange,
                                hexCode: _bgColor != null
                                    ? '#${_bgColor?.value.toRadixString(16)}'
                                    : 'N/A',
                                label: 'BG Colour',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ));
          }),
    );
  }
}

class WCAGTextResult extends StatelessWidget {
  final double contrastRatio;

  const WCAGTextResult({super.key, required this.contrastRatio});

  @override
  Widget build(BuildContext context) {
    // Define thresholds for WCAG compliance
    const double aaNormalTextThreshold = 4.5;
    const double aaLargeTextThreshold = 3.0;

    const double aaaNormalTextThreshold = 7.0;
    const double aaaLargeTextThreshold = 4.5;

    bool isAANormalFail = contrastRatio < aaNormalTextThreshold;
    bool isAAANormalFail = contrastRatio < aaaNormalTextThreshold;

    bool isAALargeFail = contrastRatio < aaLargeTextThreshold;
    bool isAAALargeFail = contrastRatio < aaaLargeTextThreshold;

    String aaNormalResult = isAANormalFail ? 'Fail (AA)' : 'Pass (AA)';
    String aaaNormalResult = isAAANormalFail ? 'Fail (AAA)' : 'Pass (AAA)';

    String aaLargeResult = isAALargeFail ? 'Fail (AA)' : 'Pass (AA)';
    String aaaLargeResult = isAAALargeFail ? 'Fail (AAA)' : 'Pass (AAA)';

    TextStyle failTextStyle = const TextStyle(color: Colors.red);
    TextStyle passTextStyle = const TextStyle(color: Colors.green);

    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Normal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Text(aaNormalResult, style: isAANormalFail ? failTextStyle : passTextStyle),
            Text(aaaNormalResult, style: isAAANormalFail ? failTextStyle : passTextStyle),
          ],
        ),
        const SizedBox(width: 15),
        Column(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Large',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Text(aaLargeResult, style: isAALargeFail ? failTextStyle : passTextStyle),
            Text(aaaLargeResult, style: isAAALargeFail ? failTextStyle : passTextStyle),
          ],
        ),
      ],
    );
  }
}

class PickedColour extends StatelessWidget {
  final Color pickedColour;
  final String label;
  final String hexCode;
  final IconButton icon;

  const PickedColour({
    super.key,
    required this.pickedColour,
    required this.hexCode,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width * 0.18,
              decoration: BoxDecoration(
                color: pickedColour,
                border: Border.all(color: kPrimaryColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: icon,
              )),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            hexCode,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
