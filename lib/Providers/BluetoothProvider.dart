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

  int defaultTimerValue = 15, defaultDelayValue = 5;
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
    isOn = await flutterBlue.isOn;
    if (isOn == true) {
      checkUserMovementStatus();
      print('Settings set to "Not Moving"');
      Timer.periodic(
        Duration(seconds: defaultTimerValue),
        (timer) {
          switch (isUserMoving) {
            case false:
              changeDefaultTimerValue();
              startScanning();
              break;
            case true:
              timer.cancel();
              changeDefaultTimerValue();
              Future.delayed(
                Duration(seconds: 3),
                () {
                  print('Settings set to "Moving"');
                  Timer.periodic(
                    Duration(seconds: defaultTimerValue),
                    (timer) {
                      switch (isUserMoving) {
                        case true:
                          startScanning();
                          break;
                        case false:
                          timer.cancel();
                          changeDefaultTimerValue();
                          searchForDevices();
                          break;
                      }
                    },
                  );
                },
              );
              break;
          }
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Please enable your bluetooth',
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
    }
  }

  checkUserMovementStatus() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      getAccelerometerValue();
      if (timer.tick >= 2) {
        newXAxis = _newACMeterResults[0].xAxis.floorToDouble();
        newYAxis = _newACMeterResults[0].yAxis.floorToDouble();
        newZAxis = _newACMeterResults[0].zAxis.floorToDouble();
        oldXAxis = _oldACMeterResults[0].xAxis.floorToDouble();
        oldYAxis = _oldACMeterResults[0].yAxis.floorToDouble();
        oldZAxis = _oldACMeterResults[0].zAxis.floorToDouble();
        if (newXAxis != oldXAxis ||
            newYAxis != oldYAxis ||
            newZAxis != oldZAxis) {
          isUserMoving = true;
          notifyListeners();
        } else {
          isUserMoving = false;
          notifyListeners();
        }
      }
    });
  }

  changeDefaultTimerValue() async {
    if (isUserMoving == true) {
      print('defaultTimerValue set to 10');
      defaultTimerValue = defaultTimerValue - 5;
      defaultDelayValue = 5;
      notifyListeners();
    } else {
      print('defaultTimerValue set to 15');
      defaultTimerValue = 15;
      defaultDelayValue = 5;
      notifyListeners();
    }
  }

  getAccelerometerValue() {
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
          Duration(seconds: 3),
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

  startScanning() {
    Fluttertoast.showToast(msg: 'Scanning...');
    List<BluetoothInfoModel> deviceInfo = [];
    if (isOn == true) {
      try {
        bluetoothScan.startScan(pairedDevices: true);
        bluetoothScan.devices.distinct().listen(
          (device) {
            if (device != null) {
              if (device.name != null) {
                deviceInfo.add(BluetoothInfoModel(
                  deviceName: device.name,
                  deviceBLEID: device.address,
                  isDeviceNearby: device.nearby,
                ));
              }
            }
          },
        );

        Future.delayed(
          Duration(seconds: defaultDelayValue),
          () async {
            _scanResults.clear();
            bluetoothScan.stopScan();
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
    if (isUserMoving == true) {
      print('Scanning every 5 seconds');
    } else {
      print('Scanning every 10 seconds');
    }
  }
}
