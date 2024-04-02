
import 'dart:ui' as ui;
import 'package:eye_dropper/eye_dropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class EyeDropper extends StatefulWidget {
  const EyeDropper({
    super.key,
    required this.child,
    this.haveTextColorWidget = true,
  });

  final Widget child;
  final bool haveTextColorWidget;

  static void enableEyeDropper(
      BuildContext context, Function(Color?)? onEyeDropper) async {
    _EyeDropperState? state =
    context.findAncestorStateOfType<_EyeDropperState>();
    state?.enableEyeDropper(onEyeDropper);
  }

  @override
  State<EyeDropper> createState() => _EyeDropperState();
}

class _EyeDropperState extends State<EyeDropper> {
  final GlobalKey _renderKey = GlobalKey();

  ui.Image? _image;
  bool _enableEyeDropper = false;

  final _offsetNotifier = ValueNotifier<Offset>(const Offset(0, 0));
  final _colorNotifier = ValueNotifier<Color?>(null);
  Function(Color?)? _onEyeDropper;

  void enableEyeDropper(Function(Color?)? onEyeDropper) async {
    var renderBox = _renderKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final boundary =
    _renderKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    // inital image - byte data
    _image = await boundary.toImage();

    setState(() {
      // enable color picker
      _enableEyeDropper = true;
      // place the color picker overlay's position in the center
      updatePosition(Offset(size.width / 2, size.height / 2));

      _onEyeDropper = onEyeDropper;
    });

    // Call platform channel method to start color capture
    await _startColorCapture();
  }

  // Method to call platform channel to start color capture
  Future<void> _startColorCapture() async {
    try {
      await MethodChannel('webview_color_channel').invokeMethod('startColorCapture');
    } on PlatformException catch (e) {
      print("Failed to start color capture: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: onPointerDown,
          onPointerMove: onPointerMove,
          onPointerUp: onPointerUp,
          child: RepaintBoundary(
            key: _renderKey,
            child: widget.child,
          ),
        ),
        Visibility(
          visible: _enableEyeDropper,
          child: Positioned(
            left: getOverlayPosition().dx,
            top: getOverlayPosition().dy,
            child: Listener(
              onPointerMove: onPointerMove,
              onPointerUp: onPointerUp,
              child: EyeDropperOverlay(
                color: _colorNotifier.value ?? Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset getOverlayPosition() {
    double dx = _offsetNotifier.value.dx - kOverlaySize.width / 2;
    double dy =
        _offsetNotifier.value.dy - kOverlaySize.height + kEyeDropperSize / 2;
    return Offset(dx, dy);
  }

  void onPointerDown(PointerDownEvent event) {
    if (_enableEyeDropper) {
      updatePosition(event.position);
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (_enableEyeDropper) {
      updatePosition(event.position);
    }
  }

  void onPointerUp(PointerUpEvent event) async {
    if (_enableEyeDropper) {
      if (_colorNotifier.value != null) {
        _onEyeDropper?.call(_colorNotifier.value);
      }

      setState(() {
        _enableEyeDropper = false;
        _offsetNotifier.value = const Offset(0, 0);
        _colorNotifier.value = null;
        _image = null;
      });
    }
  }

  updatePosition(Offset newPosition) async {
    var color = await _getPixelColor(newPosition.dx.toInt(), newPosition.dy.toInt());

    setState(() {
      // update position
      _offsetNotifier.value = newPosition;

      // update color
      _colorNotifier.value = color;
    });
  }

  // Method to call platform channel to get pixel color
  Future<Color?> _getPixelColor(int x, int y) async {
    try {
      int? color = await MethodChannel('webview_color_channel').invokeMethod('getPixelColor', {"x": x, "y": y});
      return Color(color!);
    } on PlatformException catch (e) {
      print("Failed to get pixel color: '${e.message}'.");
      return null;
    }
  }
}
