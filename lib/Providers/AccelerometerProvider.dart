import 'dart:async';

import 'package:flutter/material.dart';
import 'package:contrace/Models/AccelerometerModel.dart';
import 'package:sensors/sensors.dart';

class AccelerometerProvider with ChangeNotifier {
  List<StreamSubscription<AccelerometerEvent>> accelerometerInfo = [];
  List<AccelerometerModel> scannedResults;
  Stream<List<AccelerometerModel>> getAccelerometerInfo() async* {
    accelerometerInfo.add(
      accelerometerEvents.listen(
        (event) {
          scannedResults = [
            AccelerometerModel(
              xAxis: event.x,
              yAxis: event.y,
              zAxis: event.z,
            ),
          ];
        },
      ),
    );
  }
}
