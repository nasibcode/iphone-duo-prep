/// Phase A5 — Flutter Dart façade.
/// Thin Dart façade over the iPhoneDuoPrep iOS MethodChannel.
/// Defaults match DuoFeatureGate degrade (zeros / compact false) when the channel is absent.
library iphone_duo_prep;

import 'package:flutter/services.dart';

const _channel = MethodChannel('iphone_duo_prep');
const _hingeEvents = EventChannel('iphone_duo_prep/hinge');

class DuoInsets {
  const DuoInsets({this.top = 0, this.left = 0, this.bottom = 0, this.right = 0});
  final double top, left, bottom, right;
}

/// Dart façade for iPhone Duo prep helpers (channel: `iphone_duo_prep`).
class IPhoneDuoPrep {
  /// Safe-area insets; asymmetric across the fold when the native side is live.
  static Future<DuoInsets> safeAreaInsets() async {
    try {
      final map = await _channel.invokeMethod<Map>('safeAreaInsets');
      if (map == null) return const DuoInsets();
      return DuoInsets(
        top: (map['top'] as num?)?.toDouble() ?? 0,
        left: (map['left'] as num?)?.toDouble() ?? 0,
        bottom: (map['bottom'] as num?)?.toDouble() ?? 0,
        right: (map['right'] as num?)?.toDouble() ?? 0,
      );
    } on PlatformException {
      return const DuoInsets();
    } on MissingPluginException {
      return const DuoInsets();
    }
  }

  static Future<bool> isCompactWidth(double width) async {
    try {
      final value = await _channel.invokeMethod<bool>('isCompactWidth', {'width': width});
      return value ?? width < 600;
    } on PlatformException {
      return width < 600;
    } on MissingPluginException {
      return width < 600;
    }
  }

  /// 0...1 fold fraction; 0 when unavailable.
  static Future<double> hingeFraction() async {
    try {
      final value = await _channel.invokeMethod<num>('hingeFraction');
      return value?.toDouble() ?? 0;
    } on PlatformException {
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }

  /// 0...1 fold fraction stream; empty when the native EventChannel is absent.
  static Stream<double> observeHinge() {
    try {
      return _hingeEvents
          .receiveBroadcastStream()
          .map((event) => (event as num).toDouble())
          .handleError((Object _, [StackTrace? __]) {});
    } on PlatformException {
      return const Stream<double>.empty();
    } on MissingPluginException {
      return const Stream<double>.empty();
    }
  }

  static Future<DuoInsets> reservedInsets() async {
    try {
      final map = await _channel.invokeMethod<Map>('reservedInsets');
      if (map == null) return const DuoInsets();
      return DuoInsets(
        top: (map['top'] as num?)?.toDouble() ?? 0,
        left: (map['left'] as num?)?.toDouble() ?? 0,
        bottom: (map['bottom'] as num?)?.toDouble() ?? 0,
        right: (map['right'] as num?)?.toDouble() ?? 0,
      );
    } on PlatformException {
      return const DuoInsets();
    } on MissingPluginException {
      return const DuoInsets();
    }
  }
}
