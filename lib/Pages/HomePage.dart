import 'dart:collection';

import 'package:contrace/Models/AccelerometerModel.dart';
import 'package:contrace/Models/BluetoothInfoModel.dart';
import 'package:contrace/Providers/AccelerometerProvider.dart';
import 'package:contrace/Providers/BluetoothProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:system_shortcuts/system_shortcuts.dart';

class HomePage extends StatelessWidget {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  FlutterScanBluetooth bluetooth = FlutterScanBluetooth();
  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BluetoothProvider>(context);
    final acMeterProvider = Provider.of<AccelerometerProvider>(context);
    bleProvider.checkBLEStatus();
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                    ),
                    Center(
                      child: bleProvider.isOn == true
                          ? Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 60.0,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Icon(
                                Icons.bluetooth_disabled,
                                color: Colors.red,
                                size: 60.0,
                              ),
                            ),
                    ),
                    Center(
                      child: Text(
                        bleProvider.bluetoothStateMSG,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Bluetooth connection'),
                        Switch(
                          value: bleProvider.isOn,
                          onChanged: (bool e) {
                            if (e == true) {
                              SystemShortcuts.bluetooth();
                              Fluttertoast.showToast(
                                msg: 'Turning on bluetooth...',
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                              );
                            } else {
                              SystemShortcuts.bluetooth();
                              Fluttertoast.showToast(
                                msg: 'Turning off bluetooth...',
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                              );
                            }
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50.0,
                      width: 100.0,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        onPressed: () {
                          bleProvider.searchForDevices();
                        },
                        child: Text(
                          'START',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                        color: bleProvider.isOn ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Near Devices',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 30.0,
                          right: 30.0,
                        ),
                        child: ListView.builder(
                          itemCount:
                              bleProvider.scanResults.toSet().toList().length,
                          itemBuilder: (context, index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              color: Colors.blue,
                              child: ListTile(
                                leading: Icon(
                                  Icons.bluetooth,
                                  color: Colors.white,
                                  size: 35.0,
                                ),
                                title: Text(
                                  '${bleProvider.scanResults[index].deviceName}',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  '${bleProvider.scanResults[index].deviceBLEID}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10.0),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
