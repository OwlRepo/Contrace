import 'package:contrace/Providers/AccelerometerProvider.dart';
import 'package:contrace/Providers/BluetoothProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Pages/HomePage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  requestPermissions();
  AccelerometerProvider acMeterProvider = AccelerometerProvider();
  BluetoothProvider bluetoothProvider = BluetoothProvider();
  acMeterProvider.dispose();
  bluetoothProvider.dispose();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BluetoothProvider()),
        ChangeNotifierProvider(
          create: (context) => AccelerometerProvider(),
        )
      ],
      child: MyApp(),
    ),
  );
}

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses =
      await [Permission.sensors].request();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}
