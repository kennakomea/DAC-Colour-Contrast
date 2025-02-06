import 'package:dac_colour_contrast/app_provider.dart';
import 'package:dac_colour_contrast/mobile_results_container.dart';
import 'package:dac_colour_contrast/wcgag_text_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Displays correct contrast ratio when colors are set',
      (WidgetTester tester) async {
    // Create and configure mock AppProvider
    final mockAppProvider = AppProvider()
      ..setFgColor(const Color(0xFF000000)) // Use method to set color
      ..setBgColor(const Color(0xFFFFFFFF)); // Use method to set color

    // Expected values
    const expectedRatio = '21.00:1';
    const expectedFgHex = '#FF000000';
    const expectedBgHex = '#FFFFFFFF';

    // Build the test widget for mobile results container
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppProvider>.value(
          value: mockAppProvider,
          child: const Scaffold(
            body: ResultsContainer(),
          ),
        ),
      ),
    );

    // Wait for animations to settle
    await tester.pumpAndSettle();

    // Verify contrast ratio display
    expect(find.text(expectedRatio), findsOneWidget);

    // Verify color hex codes
    expect(find.text(expectedFgHex), findsOneWidget);
    expect(find.text(expectedBgHex), findsOneWidget);

    // Verify WCAG result widget presence
    expect(find.byType(WCAGTextResult), findsOneWidget);

    // Verify main UI components
    expect(find.text('Contrast Results'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Ionicons.share_social), findsOneWidget);
  });
}
