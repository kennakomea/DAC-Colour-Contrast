import 'package:dac_colour_contrast/suggestions.dart';
import 'package:dac_colour_contrast/utilities/colour_utils_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'enums/enums.dart';

class AppProvider extends ChangeNotifier {
  AppView _currentView = AppView.home;
  bool _isEyeDropperVisible = false;
  Color? _fgColor;
  Color? _bgColor;

  AppView get currentView => _currentView;
  bool get isEyeDropperVisible => _isEyeDropperVisible;
  Color? get fgColor => _fgColor;
  Color? get bgColor => _bgColor;

  void setCurrentView(AppView view) {
    _currentView = view;
    notifyListeners();
  }

  set isEyeDropperVisible(bool value) {
    _isEyeDropperVisible = value;
    notifyListeners();
  }

  void setFgColor(Color? color) {
    _fgColor = color;
    notifyListeners();
  }

  void setBgColor(Color? color) {
    _bgColor = color;
    notifyListeners();
  }

  void shareResults() {
    if (_fgColor != null && _bgColor != null) {
      double ratio = ColorUtils.calculateContrastRatio(_fgColor!, _bgColor!);
      String result = 'Color Contrast Results:\n'
          'Foreground Color: ${ColorUtils.toHex(_fgColor!)}\n'
          'Background Color: ${ColorUtils.toHex(_bgColor!)}\n'
          'Contrast Ratio: ${ratio.toStringAsFixed(2)}:1\n'
          'WCAG AA Compliance: ${ratio >= 4.5 ? "Pass" : "Fail"}\n'
          'WCAG AAA Compliance: ${ratio >= 7.0 ? "Pass" : "Fail"}';
      Share.share(result);
    } else {
      Share.share('Color contrast results are not available yet.');
    }
  }

  void checkAndShowSuggestions(BuildContext context) {
    if (_fgColor != null && _bgColor != null) {
      double ratio = ColorUtils.calculateContrastRatio(_fgColor!, _bgColor!);
      if (ratio < 4.5) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SuggestionsScreen(
              fgColor: _fgColor!,
              bgColor: _bgColor!,
              contrastRatio: ratio,
              onColorSelected: (selectedColor, isForeground) {
                if (isForeground) {
                  setFgColor(selectedColor);
                } else {
                  setBgColor(selectedColor);
                }
                Navigator.pop(context);
              },
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contrast ratio is already compliant.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both FG and BG colours.')),
      );
    }
  }
}
