import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Get current connectivity status
  Future<ConnectivityResult> getCurrentConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('Failed to get connectivity status: $e');
      return ConnectivityResult.none;
    }
  }

  // Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  // Check if device is connected to internet
  Future<bool> get isConnected async {
    final result = await getCurrentConnectivity();
    return result != ConnectivityResult.none;
  }

  // Check if device is connected to WiFi
  Future<bool> get isConnectedToWiFi async {
    final result = await getCurrentConnectivity();
    return result == ConnectivityResult.wifi;
  }

  // Check if device is connected to mobile data
  Future<bool> get isConnectedToMobile async {
    final result = await getCurrentConnectivity();
    return result == ConnectivityResult.mobile;
  }

  // Get connectivity type as string
  Future<String> getConnectivityType() async {
    final result = await getCurrentConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  // Listen to connectivity changes with callback
  void listenToConnectivityChanges({
    required Function(bool isConnected) onConnectivityChanged,
  }) {
    connectivityStream.listen((ConnectivityResult result) {
      final isConnected = result != ConnectivityResult.none;
      onConnectivityChanged(isConnected);
    });
  }
}
