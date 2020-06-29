import 'package:flutter/cupertino.dart';

class BluetoothInfoModel {
  final String deviceName;
  final String deviceBLEID;
  final bool isDeviceNearby;

  BluetoothInfoModel({
    @required this.deviceName,
    @required this.deviceBLEID,
    @required this.isDeviceNearby,
  });
}
