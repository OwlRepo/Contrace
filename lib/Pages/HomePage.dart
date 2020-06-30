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
    bleProvider.checkBLEStatus();

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlatButton(
                      color: Colors.blue,
                      onPressed: () async {
                        if (await SystemShortcuts.checkBluetooth == false) {
                          try {
                            Fluttertoast.showToast(
                                msg: "BLE:ON",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);

                            await SystemShortcuts.bluetooth();
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          try {
                            Future.delayed(Duration(seconds: 2), () {
                              Fluttertoast.showToast(
                                  msg: "BLE:OFF",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });

                            await SystemShortcuts.bluetooth();
                          } catch (e) {
                            print(e);
                          }
                        }
                      },
                      child: Text(
                        'Open bluetooth connection',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        bleProvider.searchForDevices();
                      },
                      child: Text('Scan bluetooth connection'),
                    ),
                    Center(
                      child: Text(bleProvider.bluetoothStateMSG),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 100.0),
            Expanded(
              flex: 8,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                          itemCount: bleProvider.scanResults.length,
                          itemBuilder: (context, index) {
                            return Text(
                              '${bleProvider.scanResults[index].deviceName}',
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
