import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:contrace/Models/BluetoothInfoModel.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BluetoothProvider with ChangeNotifier {
  Colors _isNearby;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  FlutterScanBluetooth bluetoothScan = FlutterScanBluetooth();
  bool isOn;
  List<BluetoothInfoModel> _scanResults = [];
  String bluetoothStateMSG = 'Checking your Bluetooth status';
  Colors get isNearby => _isNearby;
  List<BluetoothInfoModel> get scanResults => _scanResults;

  set scanResults(List<BluetoothInfoModel> items) {
    _scanResults = items;
    notifyListeners();
  }

  set isNearby(Colors value) {
    _isNearby = value;
    notifyListeners();
  }

  void checkBLEStatus() async {
    isOn = await flutterBlue.isOn;
    if (isOn == false) {
      bluetoothStateMSG = 'Please enable your bluetooth before we start';
      notifyListeners();
    } else {
      bluetoothStateMSG =
          'Done checking! Lets now proceed on filling out the form.';
      notifyListeners();
    }
  }

  Future<List<BluetoothInfoModel>> searchForDevices() async {
    scanResults.clear();
    while (isOn == true) {
      try {
        bluetoothScan.startScan(pairedDevices: false);
        bluetoothScan.devices.distinct().listen(
          (device) {
            if (device != null) {
              if (device.name != null) {
                scanResults.add(
                  BluetoothInfoModel(
                    deviceName: device.name,
                    deviceBLEID: device.address,
                    isDeviceNearby: device.nearby,
                  ),
                );
              }
            }
          },
        );
      } catch (e) {
        print(e);
      }
      notifyListeners();
      return scanResults;
    }
  }
}
