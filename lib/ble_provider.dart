import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:typed_data';

class BLEProvider extends ChangeNotifier {
  BluetoothDevice? connectedDevice;
  bool isBLEEnabled = false;
  
  // Data variabel
  double level = 0.0;
  int amperage = 0;
  String batteryHealth = '';
  int voltage = 0;
  int temperature = 0;

  // UUIDs for the BLE service and characteristics
  final String SERVICE_UUID = "12345678-1234-1234-1234-1234567890ab";
  final String LEVEL_CHAR_UUID = "23456789-1234-1234-1234-1234567890bc";
  final String AMPERAGE_CHAR_UUID = "34567890-1234-1234-1234-1234567890cd";
  final String BATTERY_HEALTH_CHAR_UUID = "45678901-1234-1234-1234-1234567890de";
  final String VOLTAGE_CHAR_UUID = "56789012-1234-1234-1234-1234567890ef";
  final String TEMPERATURE_CHAR_UUID = "67890123-1234-1234-1234-1234567890ff";

  // Enable or disable BLE
  void toggleBLE(bool isEnabled) {
    isBLEEnabled = isEnabled;
    notifyListeners();

    if (isBLEEnabled) {
      connectToDevice(); // Connect to the device if BLE is enabled
    } else {
      disconnectDevice(); // Disconnect from the device if BLE is disabled
    }
  }

  Future<void> connectToDevice() async {
    try {
      // Start scanning for BLE devices
      FlutterBluePlus.startScan();

      // Listen for scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (result.device.name == "ESP_ERC") {
            connectedDevice = result.device;
            FlutterBluePlus.stopScan();
            _connectToDevice(connectedDevice!);
            break;
          }
        }
      });
    } catch (e) {
      print("Scanning failed: $e");
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      isBLEEnabled = true; // Update BLE status
      notifyListeners();

      // Mendapatkan services dan characteristics
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        // Cek jika service adalah yang diinginkan
        if (service.uuid.toString() == SERVICE_UUID) {
          // Cek karakteristik Level
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == LEVEL_CHAR_UUID) {
              characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen((value) {
                // Parsing data dari Uint8List ke float (sesuai tipe asli)
                level = _parseFloat(value);
                notifyListeners();
              });
            }
            // Cek karakteristik Amperage
            if (characteristic.uuid.toString() == AMPERAGE_CHAR_UUID) {
              List<int> value = await characteristic.read();
              amperage = _parseInt(value);
              characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen((value) {
                amperage = _parseInt(value);
                notifyListeners();
              });
            }
            // Cek karakteristik Battery Health
            if (characteristic.uuid.toString() == BATTERY_HEALTH_CHAR_UUID) {
              characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen((value) {
                // Parsing data dari Uint8List ke String
                batteryHealth = String.fromCharCodes(value);
                notifyListeners();
              });
            }
            // Cek karakteristik Voltage
            if (characteristic.uuid.toString() == VOLTAGE_CHAR_UUID) {
              characteristic.setNotifyValue(true);
              characteristic.onValueReceived.listen((value) {
                // Parsing data dari Uint8List ke int
                voltage = _parseInt(value);
                notifyListeners();
              });
            }
            // Cek karakteristik Temperature
          if (characteristic.uuid.toString() == TEMPERATURE_CHAR_UUID) {
            List<int> value = await characteristic.read();
            amperage = _parseInt(value);
            characteristic.setNotifyValue(true);
            characteristic.onValueReceived.listen((value) {
              temperature = _parseInt(value);
              notifyListeners();
            });
          }
          }
        }
      }
    } catch (e) {
      print("Connection failed: $e");
    }
  }

  Future<void> disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      isBLEEnabled = false; // Update BLE status
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> readBLEData() async {
    // Pastikan perangkat terhubung
    if (connectedDevice == null) {
      return {};
    }

    // Mengambil data secara langsung
    List<BluetoothService> services = await connectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Baca data karakteristik sesuai UUID
          if (characteristic.uuid.toString() == LEVEL_CHAR_UUID) {
            List<int> bytes = await characteristic.read();
            level = _parseFloat(bytes);
          } else if (characteristic.uuid.toString() == AMPERAGE_CHAR_UUID) {
            List<int> bytes = await characteristic.read();
            amperage = _parseInt(bytes);
          } else if (characteristic.uuid.toString() == BATTERY_HEALTH_CHAR_UUID) {
            List<int> bytes = await characteristic.read();
            batteryHealth = String.fromCharCodes(bytes);
          } else if (characteristic.uuid.toString() == VOLTAGE_CHAR_UUID) {
            List<int> bytes = await characteristic.read();
            voltage = _parseInt(bytes);
          } else if (characteristic.uuid.toString() == TEMPERATURE_CHAR_UUID) {
            List<int> bytes = await characteristic.read();
            temperature = _parseInt(bytes);
          }
        }
      }
    }

    notifyListeners(); // Notifikasi perubahan data setelah pembacaan
    return {
      'level': level,
      'amperage': amperage,
      'batteryHealth': batteryHealth,
      'voltage': voltage,
      'temperature': temperature,
    };
  }

  // Parsing functions
  double _parseFloat(List<int> value) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(value));
    return byteData.getFloat32(0, Endian.little);
  }

  int _parseInt(List<int> value) {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(value));
    return byteData.getInt32(0, Endian.little);
  }
}
