// lib/domain/connectivity/network_info.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
