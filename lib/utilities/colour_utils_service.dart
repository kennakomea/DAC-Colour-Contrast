// lib/utils/color_utils.dart

import 'dart:math';

import 'package:flutter/material.dart';

class ColorUtils {
  /// Calculates the contrast ratio between two colors
  static double calculateContrastRatio(Color color1, Color color2) {
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

  /// Calculates the relative luminance of a color
  static double _calculateLuminance(Color color) {
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

  /// Formats color to hex string
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}';
  }

  /// Formats color to RGB string
  static String toRGB(Color color) {
    return 'RGB(${color.red}, ${color.green}, ${color.blue})';
  }

  /// Checks if the contrast ratio meets WCAG requirements
  static WCAGCompliance checkWCAGCompliance(double contrastRatio) {
    return WCAGCompliance(
      isAANormalPass: contrastRatio >= 4.5,
      isAALargePass: contrastRatio >= 3.0,
      isAAANormalPass: contrastRatio >= 7.0,
      isAAALargePass: contrastRatio >= 4.5,
    );
  }
}

/// Class to hold WCAG compliance results
class WCAGCompliance {
  final bool isAANormalPass;
  final bool isAALargePass;
  final bool isAAANormalPass;
  final bool isAAALargePass;

  const WCAGCompliance({
    required this.isAANormalPass,
    required this.isAALargePass,
    required this.isAAANormalPass,
    required this.isAAALargePass,
  });
}
