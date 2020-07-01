import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:contrace/Models/BluetoothInfoModel.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'AccelerometerProvider.dart';

class BluetoothProvider with ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  FlutterScanBluetooth bluetoothScan = FlutterScanBluetooth();
  AccelerometerProvider acMeterProvider = AccelerometerProvider();

  bool isOn;
  Colors _isNearby;
  List<BluetoothInfoModel> _scanResults = [];
  String bluetoothStateMSG = 'Checking your Bluetooth status';

  Colors get isNearby => _isNearby;
  List<BluetoothInfoModel> get scanResults => _scanResults;

  set isNearby(Colors value) {
    _isNearby = value;
    notifyListeners();
  }

  set scanResults(List<BluetoothInfoModel> items) {
    _scanResults = items;
    notifyListeners();
  }

  void checkBLEStatus() async {
    isOn = await flutterBlue.isOn;

    if (isOn == false) {
      bluetoothStateMSG = 'Please enable your bluetooth before we start';
      notifyListeners();
    } else {
      bluetoothStateMSG = 'Great! Lets now proceed on filling out the form.';
      notifyListeners();
    }
  }

  Future<List<BluetoothInfoModel>> searchForDevices() async {
    Timer.periodic(
      Duration(seconds: 10),
      (timer) {
        startScanning();
      },
    );
  }

  startScanning() {
    List<BluetoothInfoModel> deviceInfo = [];
    if (isOn == true) {
      try {
        Fluttertoast.showToast(
          msg: 'Scanning',
        );

        bluetoothScan.startScan(pairedDevices: false);
        bluetoothScan.devices.distinct().listen(
          (device) {
            if (device != null) {
              if (device.name != null) {
                deviceInfo.add(
                  BluetoothInfoModel(
                      deviceName: device.name,
                      deviceBLEID: device.address,
                      isDeviceNearby: device.nearby),
                );
              }
            }
          },
        );

        Future.delayed(
          Duration(seconds: 5),
          () async {
            _scanResults.clear();
            bluetoothScan.stopScan();
            bluetoothScan.devices.listen((event) {}).cancel();
            _scanResults.addAll(Set.of(deviceInfo).toList());
            notifyListeners();
            Fluttertoast.showToast(
              msg: 'Done!',
            );
          },
        );
      } catch (e) {
        print(e);
      }
    }
  }
}
