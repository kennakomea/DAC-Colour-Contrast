import 'package:dac_colour_contrast/app_provider.dart';
import 'package:dac_colour_contrast/constants.dart';
import 'package:dac_colour_contrast/utilities/colour_utils_service.dart';
import 'package:dac_colour_contrast/wcgag_text_result.dart';
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
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _isExpanded = true;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      _sheetController.animateTo(
        _isExpanded ? 0.7 : 0.2,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: true);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = screenWidth * 0.02;
    final textScaler = mediaQuery.textScaler;

    return Semantics(
      label: 'Color Contrast Analysis Panel',
      child: SizedBox(
        height: screenHeight * 0.6,
        width: screenWidth,
        child: DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: _isExpanded ? 0.7 : 0.2,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.2, 0.7, 0.9],
          builder: (context, scrollController) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: padding, vertical: padding * 0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Semantics(
                          button: true,
                          label:
                              _isExpanded ? 'Collapse panel' : 'Expand panel',
                          child: IconButton(
                            icon: Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: kPrimaryColor,
                              size: textScaler.scale(24),
                            ),
                            onPressed: _toggleExpansion,
                          ),
                        ),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Contrast Results',
                              style: TextStyle(
                                fontSize: textScaler.scale(18),
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Share contrast results',
                          child: IconButton(
                            icon: Icon(
                              Ionicons.share_social,
                              color: kPrimaryColor,
                              size: textScaler.scale(24),
                            ),
                            onPressed: () => _handleShare(appProvider),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    color: kPrimaryColor.withOpacity(0.1),
                    thickness: 2,
                    indent: padding,
                    endIndent: padding,
                  ),

                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          children: [
                            // Color Pickers and Contrast Display
                            Wrap(
                              spacing: padding,
                              runSpacing: padding,
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                _buildColorPicker(
                                  context,
                                  'Foreground',
                                  appProvider.fgColor ?? Colors.deepOrange,
                                  true,
                                  Ionicons.eyedrop_outline,
                                  screenWidth,
                                  textScaler,
                                ),
                                const SizedBox(width: 20),
                                _buildColorPicker(
                                  context,
                                  'Background',
                                  appProvider.bgColor ?? Colors.deepOrange,
                                  false,
                                  Ionicons.eyedrop,
                                  screenWidth,
                                  textScaler,
                                ),
                              ],
                            ),

                            SizedBox(height: padding * 1.5),

                            _buildContrastDisplay(appProvider, textScaler),

                            if (appProvider.fgColor != null &&
                                appProvider.bgColor != null)
                              WCAGTextResult(
                                contrastRatio:
                                    ColorUtils.calculateContrastRatio(
                                  appProvider.fgColor!,
                                  appProvider.bgColor!,
                                ),
                              )
                            else
                              const WCAGTextResult(contrastRatio: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    String label,
    Color color,
    bool isForeground,
    IconData icon,
    double screenWidth,
    TextScaler textScaler,
  ) {
    final double boxSize = (screenWidth * 0.15) * textScaler.scale(1.0);
    final hexColor = ColorUtils.toHex(color);

    return Semantics(
      label: '$label color picker',
      value: 'Current color is $hexColor',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: boxSize,
            width: boxSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: kPrimaryColor.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _handleEyeDropper(context, isForeground),
                child: Icon(
                  icon,
                  color: calculateIconColor(color),
                  size: boxSize * 0.5,
                ),
              ),
            ),
          ),
          SizedBox(height: textScaler.scale(8)),
          FittedBox(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: textScaler.scale(14),
              ),
            ),
          ),
          SizedBox(height: textScaler.scale(4)),
          FittedBox(
            child: Text(
              hexColor,
              style: TextStyle(
                fontSize: textScaler.scale(12),
                fontFamily: 'monospace',
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContrastDisplay(AppProvider appProvider, TextScaler textScaler) {
    final hasColors =
        appProvider.fgColor != null && appProvider.bgColor != null;
    final ratio = hasColors
        ? ColorUtils.calculateContrastRatio(
            appProvider.fgColor!, appProvider.bgColor!)
        : 0.0;

    return Semantics(
      label: 'Contrast ratio display',
      value: hasColors
          ? 'Current contrast ratio is ${ratio.toStringAsFixed(2)} to 1'
          : 'No colors selected',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Text(
              hasColors ? '${ratio.toStringAsFixed(2)}:1' : 'N/A',
              style: TextStyle(
                fontSize: textScaler.scale(28),
                fontWeight: FontWeight.bold,
                color: hasColors
                    ? (ratio >= 4.5 ? Colors.green : Colors.red)
                    : Colors.grey,
              ),
            ),
          ),
          SizedBox(height: textScaler.scale(4)),
          FittedBox(
            child: Text(
              'Contrast Ratio',
              style: TextStyle(
                fontSize: textScaler.scale(12),
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare(AppProvider appProvider) {
    if (appProvider.fgColor != null && appProvider.bgColor != null) {
      double ratio = ColorUtils.calculateContrastRatio(
          appProvider.fgColor!, appProvider.bgColor!);
      String result = 'Color Contrast Results:\n'
          'Foreground Color: ${ColorUtils.toHex(appProvider.fgColor!)}\n'
          'Background Color: ${ColorUtils.toHex(appProvider.bgColor!)}\n'
          'Contrast Ratio: ${ratio.toStringAsFixed(2)}:1\n'
          'WCAG AA Compliance: ${ratio >= 4.5 ? "Pass" : "Fail"}\n'
          'WCAG AAA Compliance: ${ratio >= 7.0 ? "Pass" : "Fail"}';
      Share.share(result);
    } else {
      Share.share('Color contrast results are not available yet.');
    }
  }

  void _handleEyeDropper(BuildContext context, bool isForeground) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
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
  }

  Color calculateIconColor(Color backgroundColor) {
    double luminance = ColorUtils.calculateLuminance(backgroundColor);
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
