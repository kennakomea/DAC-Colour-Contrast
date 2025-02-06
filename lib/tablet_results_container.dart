import 'package:dac_colour_contrast/utilities/colour_utils_service.dart';
import 'package:dac_colour_contrast/wcgag_text_result.dart';
import 'package:eye_dropper/eye_dropper.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import 'app_provider.dart';
import 'constants.dart';

class TabletResultsContainer extends StatelessWidget {
  const TabletResultsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: true);

    return Semantics(
      label: 'Color Contrast Results Panel',
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Contrast Results',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width *
                              0.02, // Dynamic font size
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle overflow
                      ),
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
                    context,
                    'Foreground Color',
                    appProvider.fgColor ?? Colors.deepOrange,
                    isForeground: true,
                    icon: Ionicons.eyedrop_outline,
                  ),

                  const SizedBox(height: 20),

                  // Background Color
                  _buildColorPickerSection(
                    context,
                    'Background Color',
                    appProvider.bgColor ?? Colors.deepOrange,
                    isForeground: false,
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
                  Semantics(
                    label: 'Contrast Ratio',
                    value: appProvider.fgColor != null &&
                            appProvider.bgColor != null
                        ? '${ColorUtils.calculateContrastRatio(appProvider.fgColor!, appProvider.bgColor!).toStringAsFixed(2)} to 1'
                        : 'Not available',
                    child: Text(
                      appProvider.fgColor != null && appProvider.bgColor != null
                          ? '${ColorUtils.calculateContrastRatio(appProvider.fgColor!, appProvider.bgColor!).toStringAsFixed(2)}:1'
                          : 'Ratio: N/A',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (appProvider.fgColor != null &&
                      appProvider.bgColor != null)
                    WCAGTextResult(
                        contrastRatio: ColorUtils.calculateContrastRatio(
                            appProvider.fgColor!, appProvider.bgColor!))
                  else
                    const WCAGTextResult(contrastRatio: 0),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerSection(
    BuildContext context,
    String label,
    Color color, {
    required bool isForeground,
    required IconData icon,
  }) {
    final hexColor = ColorUtils.toHex(color);
    final rgbColor = ColorUtils.toRGB(color);
    return Semantics(
      label: '$label Section',
      child: Column(
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
              Semantics(
                label: '$label Preview',
                value: 'Color: $hexColor, $rgbColor',
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'Hexadecimal Value',
                      value: hexColor,
                      child: Text(
                        hexColor,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Semantics(
                      label: 'RGB Value',
                      value: rgbColor,
                      child: Text(
                        rgbColor,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Pick $label using eye dropper',
                child: IconButton(
                  onPressed: () {
                    final appProvider =
                        Provider.of<AppProvider>(context, listen: false);
                    appProvider.isEyeDropperVisible = true;
                    EyeDropper.enableEyeDropper(context, (color) {
                      if (color != null) {
                        if (isForeground) {
                          appProvider.setFgColor(color);
                        } else {
                          appProvider.setBgColor(color);
                        }
                      }
                      appProvider.isEyeDropperVisible = false;
                    });
                  },
                  icon: Icon(icon),
                  color: kPrimaryColor,
                  tooltip: 'Pick $label',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
