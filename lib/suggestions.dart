import 'dart:math';
import 'package:flutter/material.dart';

class SuggestionsScreen extends StatelessWidget {
  final Color fgColor;
  final Color bgColor;
  final double contrastRatio;
  final Function(Color, bool) onColorSelected;

  const SuggestionsScreen({
    super.key,
    required this.fgColor,
    required this.bgColor,
    required this.contrastRatio,
    required this.onColorSelected,
  });

  double get _threshold => 4.5;

  // Generates a list of compliant colors and ranks them by contrast ratio
  List<Color> _generateCompliantColors(Color color, bool isForeground) {
    List<Map<String, dynamic>> compliantColors = [];
    for (int i = 0; i < 360; i += 10) {
      for (double j = -0.5; j <= 0.5; j += 0.1) {
        Color candidateColor = _adjustColorHueAndLightness(color, i.toDouble(), j);
        double ratio = isForeground
            ? _calculateContrastRatio(candidateColor, bgColor)
            : _calculateContrastRatio(fgColor, candidateColor);
        if (ratio >= _threshold) {
          compliantColors.add({'color': candidateColor, 'ratio': ratio});
        }
      }
    }

    // Sort the colors by their contrast ratio in descending order
    compliantColors.sort((a, b) => b['ratio'].compareTo(a['ratio']));

    // Return the top 10 colors
    return compliantColors.take(10).map((entry) => entry['color'] as Color).toList();
  }

  // Adjusts the hue and lightness of a color
  Color _adjustColorHueAndLightness(Color color, double hueDegrees, double lightnessOffset) {
    HSLColor hsl = HSLColor.fromColor(color);
    hsl = hsl
        .withHue((hsl.hue + hueDegrees) % 360)
        .withLightness((hsl.lightness + lightnessOffset).clamp(0.0, 1.0));
    return hsl.toColor();
  }

  double _calculateContrastRatio(Color color1, Color color2) {
    double luminance1 = _calculateLuminance(color1);
    double luminance2 = _calculateLuminance(color2);

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

  @override
  Widget build(BuildContext context) {
    List<Color> fgSuggestions = _generateCompliantColors(fgColor, true);
    List<Color> bgSuggestions = _generateCompliantColors(bgColor, false);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Suggestions', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foreground Color Suggestions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildColorSuggestions(fgSuggestions, true),
            const SizedBox(height: 20),
            const Text(
              'Background Color Suggestions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildColorSuggestions(bgSuggestions, false),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSuggestions(List<Color> colors, bool isForeground) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorSelected(color, isForeground),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black),
            ),
          ),
        );
      }).toList(),
    );
  }
}
