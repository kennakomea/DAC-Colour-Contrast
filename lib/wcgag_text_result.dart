import 'package:dac_colour_contrast/utilities/colour_utils_service.dart';
import 'package:flutter/material.dart';

class WCAGTextResult extends StatelessWidget {
  final double contrastRatio;

  const WCAGTextResult({super.key, required this.contrastRatio});

  @override
  Widget build(BuildContext context) {
    final compliance = ColorUtils.checkWCAGCompliance(contrastRatio);

    const TextStyle failTextStyle = TextStyle(color: Colors.red);
    const TextStyle passTextStyle = TextStyle(color: Colors.green);

    return Semantics(
      label: 'WCAG Compliance Results',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Normal Text Compliance
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Normal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      compliance.isAANormalPass ? 'Pass (AA)' : 'Fail (AA)',
                      style: compliance.isAANormalPass
                          ? passTextStyle
                          : failTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      compliance.isAAANormalPass ? 'Pass (AAA)' : 'Fail (AAA)',
                      style: compliance.isAAANormalPass
                          ? passTextStyle
                          : failTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            // Large Text Compliance
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Large',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      compliance.isAALargePass ? 'Pass (AA)' : 'Fail (AA)',
                      style: compliance.isAALargePass
                          ? passTextStyle
                          : failTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      compliance.isAAALargePass ? 'Pass (AAA)' : 'Fail (AAA)',
                      style: compliance.isAAALargePass
                          ? passTextStyle
                          : failTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
