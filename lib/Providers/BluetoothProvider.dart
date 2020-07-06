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

  int defaultTimerValue = 15;
  double newXAxis, newYAxis, newZAxis, oldXAxis, oldYAxis, oldZAxis;
  bool isOn = false;
  bool isUserMoving;
  Colors _isNearby;
  List<BluetoothInfoModel> _scanResults = [];
  String bluetoothStateMSG = 'Checking your Bluetooth status';
  List<AccelerometerModel> _newACMeterResults = List<AccelerometerModel>();
  List<AccelerometerModel> _oldACMeterResults = List<AccelerometerModel>();

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
    await checkUserMovementStatus();
  }

  Future<bool> checkUserMovementStatus() {
    getAccelerometerValue();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick >= 2) {
        newXAxis = _newACMeterResults[0].xAxis.floorToDouble();
        newYAxis = _newACMeterResults[0].yAxis.floorToDouble();
        newZAxis = _newACMeterResults[0].zAxis.floorToDouble();
        oldXAxis = _oldACMeterResults[0].xAxis.floorToDouble();
        oldYAxis = _oldACMeterResults[0].yAxis.floorToDouble();
        oldZAxis = _oldACMeterResults[0].zAxis.floorToDouble();
        if (newXAxis != oldXAxis) {
          print('User is Moving');
          isUserMoving = true;
          print(isUserMoving);
        } else {
          print('User is not Moving');
          isUserMoving = false;
          print(isUserMoving);
        }

        if (timer.tick == 20) {
          timer.cancel();
        }
      }
      return isUserMoving;
    });
  }

  changeDefaultTimerValue() async {
    if (await checkUserMovementStatus()) {
      print('Changing defaultTimerValue to 20');
      defaultTimerValue = 20;
    } else {
      print('defaultTimerValue is not changed');
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
              _newACMeterResults = [
                AccelerometerModel(
                  xAxis: event[0].xAxis.roundToDouble(),
                  yAxis: event[0].yAxis.roundToDouble(),
                  zAxis: event[0].zAxis.roundToDouble(),
                ),
              ];

              Future.delayed(
                Duration(seconds: 2),
                () {
                  _oldACMeterResults = [
                    AccelerometerModel(
                      xAxis: event[0].xAxis.roundToDouble(),
                      yAxis: event[0].yAxis.roundToDouble(),
                      zAxis: event[0].zAxis.roundToDouble(),
                    ),
                  ];
                },
              );
            },
          );
        }
        if (timer.tick == 20) {
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
            acMeterProvider.dispose();
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
            acMeterProvider.dispose();
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
