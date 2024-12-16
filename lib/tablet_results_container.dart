import 'dart:math';

import 'package:dac_colour_contrast/results_container.dart';
import 'package:eye_dropper/eye_dropper.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import 'app_provider.dart';
import 'constants.dart';

class TabletResultsContainer extends StatefulWidget {
  const TabletResultsContainer({super.key});

  @override
  State<TabletResultsContainer> createState() => _TabletResultsContainerState();
}

class _TabletResultsContainerState extends State<TabletResultsContainer> {
  Color? _fgColor;
  Color? _bgColor;

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: true);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Contrast Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Color Pickers
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Foreground Color
                _buildColorPickerSection(
                  'Foreground Color',
                  _fgColor ?? Colors.deepOrange,
                  onPickColor: (color) {
                    setState(() => _fgColor = color);
                    appProvider.isEyeDropperVisible = false;
                  },
                  icon: Ionicons.eyedrop_outline,
                ),

                const SizedBox(height: 20),

                // Background Color
                _buildColorPickerSection(
                  'Background Color',
                  _bgColor ?? Colors.deepOrange,
                  onPickColor: (color) {
                    setState(() => _bgColor = color);
                    appProvider.isEyeDropperVisible = false;
                  },
                  icon: Ionicons.eyedrop,
                ),
              ],
            ),
          ),

          // Contrast Ratio Display
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _fgColor != null && _bgColor != null
                      ? '${_calculateContrastRatio(_fgColor!, _bgColor!).toStringAsFixed(2)}:1'
                      : 'Ratio: N/A',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                if (_fgColor != null && _bgColor != null)
                  WCAGTextResult(
                    contrastRatio:
                        _calculateContrastRatio(_fgColor!, _bgColor!),
                  )
                else
                  const WCAGTextResult(contrastRatio: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerSection(String label, Color color,
      {required Function(Color) onPickColor, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kPrimaryColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RGB(${color.red}, ${color.green}, ${color.blue})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                final appProvider =
                    Provider.of<AppProvider>(context, listen: false);
                appProvider.isEyeDropperVisible = true;
                EyeDropper.enableEyeDropper(context, (color) {
                  if (color != null) {
                    onPickColor(color);
                  }
                  appProvider.isEyeDropperVisible = false;
                });
              },
              icon: Icon(icon),
              color: kPrimaryColor,
            ),
          ],
        ),
      ],
    );
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

    red = red <= 0.03928
        ? red / 12.92
        : pow((red + 0.055) / 1.055, 2.4).toDouble();
    green = green <= 0.03928
        ? green / 12.92
        : pow((green + 0.055) / 1.055, 2.4).toDouble();
    blue = blue <= 0.03928
        ? blue / 12.92
        : pow((blue + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
  }
}
