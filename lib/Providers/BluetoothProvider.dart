import 'dart:async';
import 'package:contrace/Models/AccelerometerModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:contrace/Models/BluetoothInfoModel.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sensors/sensors.dart';
import 'AccelerometerProvider.dart';

class BluetoothProvider with ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  FlutterScanBluetooth bluetoothScan = FlutterScanBluetooth();
  AccelerometerProvider acMeterProvider = AccelerometerProvider();

  bool isOn = false;
  bool isUserMoving = false;
  Colors _isNearby;
  List<BluetoothInfoModel> _scanResults = [];
  String bluetoothStateMSG = 'Checking your Bluetooth status';
  List<AccelerometerModel> _acMeterResults = List<AccelerometerModel>();
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
    try {
      getAccelerometerValue();
      if (_acMeterResults != null) {
        Timer.periodic(
          Duration(seconds: 1),
          (timer) {
            if (timer.tick >= 2) {
              print(_acMeterResults[0].xAxis.roundToDouble());
            }
            if (timer.tick == 10) {
              timer.cancel();
            }
          },
        );
      }
    } catch (e) {
      print(e);
    }
  }

  getAccelerometerValue() {
    Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        acMeterProvider.getAccelerometerInfo().listen((event) {});
        print(timer.tick);
        if (timer.tick >= 2) {
          acMeterProvider.getAccelerometerInfo().listen(
            (event) {
              _acMeterResults = [
                AccelerometerModel(
                  xAxis: event[0].xAxis.roundToDouble(),
                  yAxis: event[0].yAxis.roundToDouble(),
                  zAxis: event[0].zAxis.roundToDouble(),
                ),
              ];
            },
          );
        }
        if (timer.tick == 10) {
          timer.cancel();
        }
      },
    );
  }

  startScanningEveryFive() {
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
                    isDeviceNearby: device.nearby,
                  ),
                );
              }
            }
          },
        );

        Future.delayed(
          Duration(seconds: 10),
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

  startScanningEveryTen() {
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
                    isDeviceNearby: device.nearby,
                  ),
                );
              }
            }
          },
        );

        Future.delayed(
          Duration(seconds: 10),
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
