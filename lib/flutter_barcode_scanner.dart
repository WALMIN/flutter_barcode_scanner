import 'dart:async';

import 'package:flutter/services.dart';

/// Scan mode which is either QR code or BARCODE
enum ScanMode { QR, BARCODE, DEFAULT }

/// Provides access to the barcode scanner.
///
/// This class is an interface between the native Android and iOS classes and a
/// Flutter project.
class FlutterBarcodeScanner {
  static const MethodChannel _channel =
      MethodChannel('flutter_barcode_scanner');

  static const EventChannel _eventChannel =
      EventChannel('flutter_barcode_scanner_receiver');

  static Stream? _onBarcodeReceiver;

  /// Scan with the camera until a barcode is identified, then return.
  ///
  /// Show a message at the top with [title].
  /// Shows a scan line with [lineColor] over a scan window. A camera switch icon is
  /// displayed if [isShowSwitchIcon] is true. A flash icon is
  /// displayed if [isShowFlashIcon] is true. The text of the cancel button can
  /// be customized with the [cancelButtonText] string.
  static Future<String> scanBarcode(
      String title,
      String lineColor,
      String cancelButtonText,
      bool isShowSwitchIcon,
      bool isShowFlashIcon,
      bool frontCamera,
      ScanMode scanMode) async {
    if (cancelButtonText.isEmpty) {
      cancelButtonText = 'Cancel';
    }

    // Pass params to the plugin
    Map params = <String, dynamic>{
      'title': title,
      'lineColor': lineColor,
      'cancelButtonText': cancelButtonText,
      'isShowSwitchIcon': isShowSwitchIcon,
      'isShowFlashIcon': isShowFlashIcon,
      'isContinuousScan': false,
      'frontCamera': frontCamera,
      'scanMode': scanMode.index
    };

    /// Get barcode scan result
    final barcodeResult =
        await _channel.invokeMethod('scanBarcode', params) ?? '';
    return barcodeResult;
  }

  /// Returns a continuous stream of barcode scans until the user cancels the
  /// operation.
  ///
  /// Show a message at the top with [title].
  /// Shows a scan line with [lineColor] over a scan window. A camera switch icon is
  /// displayed if [isShowSwitchIcon] is true. A flash icon is
  /// displayed if [isShowFlashIcon] is true. The text of the cancel button can
  /// be customized with the [cancelButtonText] string. Returns a stream of
  /// detected barcode strings.
  static Stream? getBarcodeStreamReceiver(
      String title,
      String lineColor,
      String cancelButtonText,
      bool isShowSwitchIcon,
      bool isShowFlashIcon,
      bool frontCamera,
      ScanMode scanMode) {
    if (cancelButtonText.isEmpty) {
      cancelButtonText = 'Cancel';
    }

    // Pass params to the plugin
    Map params = <String, dynamic>{
      'title': title,
      'lineColor': lineColor,
      'cancelButtonText': cancelButtonText,
      'isShowSwitchIcon': isShowSwitchIcon,
      'isShowFlashIcon': isShowFlashIcon,
      'isContinuousScan': true,
      'frontCamera': frontCamera,
      'scanMode': scanMode.index
    };

    // Invoke method to open camera, and then create an event channel which will
    // return a stream
    _channel.invokeMethod('scanBarcode', params);
    _onBarcodeReceiver ??= _eventChannel.receiveBroadcastStream();
    return _onBarcodeReceiver;
  }
}
