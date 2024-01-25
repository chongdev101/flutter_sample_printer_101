import 'dart:async';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:zsdk/zsdk.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sample Printer 101',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final zsdk = ZSDK();


  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException catch (e) {
      // Printer.PrinterResponse printerResponse;
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          break;
      }

      print('state');
      print(state);
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future<void> connectToPrinter() async {
    List<BluetoothDevice> devices = [];

    try {
      await bluetooth.isConnected;
      await bluetooth.disconnect();
    } catch (e) {
      print("Error disconnecting: $e");
    }

    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      await bluetooth.connect(devices.first);
    } catch (e) {
      print("Error connecting to the printer: $e");
    }
  }

  Future<void> printSlip() async {
    print('typing...');
    // late BluetoothConnection _socket;

    try {
      await bluetooth.isConnected;
    } catch (e) {
      print("Printer is not connected: $e");
      return;
    }

    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      devices.forEach((d) {
        print('Device: ${d.name} [${d.address}] ${d.type} ${d.connected}');
      });

      BluetoothDevice device = devices.firstWhere((d) => d.name == "XXXXJ170800674");
      String macAddress = "${device.address}";

      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(PaperSize.mm80, profile);

      printer.text("Hello, Zebra ZQ320!", styles: const PosStyles(align: PosAlign.center));
      printer.cut();

      // Send the print job to the printer
      final res = await printer.connect(macAddress, port: 9100);
      if (res != PosPrintResult.success) {
        print('Could not connect to printer');
      }

    } catch (e) {
      print("Error printing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Sample Flutter Printer Android Only',
            ),
            ElevatedButton(
              onPressed: () {
                // connectToPrinter().then((_) {
                //   print('typing...');
                // });

                printSlip();
              },
              child: const Text('Print Test'),
            ),
          ],
        ),
      ),
    );
  }
}
