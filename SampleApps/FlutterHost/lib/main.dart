// Phase A5 — FlutterHost smoke entry.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Intentional R6 anti-patterns for duo-harness audit dogfood.
void main() {
  // R6.OrientationLock
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const VictimApp());
}

class VictimApp extends StatelessWidget {
  const VictimApp({super.key});

  @override
  Widget build(BuildContext context) {
    // R6.FixedMediaQuery (+ R6.MissingAdapter)
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // R6.FixedMediaQuery via const Size
    final phone = const Size(390, 844);
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: Text('w=$width phone=$phone')),
      ),
    );
  }
}
