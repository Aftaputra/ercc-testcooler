import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TunePage extends StatefulWidget {
  @override
  _TuningState createState() => _TuningState();
}

class _TuningState extends State<TunePage> {
  double dischargeCurrent = 30;
  double temperatureCutoff = 15;
  double voltageCutoff = 25;
  String dropdownValue = 'Medium threshold';

  bool isEditing = false;

  // Tambahkan controller untuk input manual
  late TextEditingController dischargeController;
  late TextEditingController temperatureController;
  late TextEditingController voltageController;

  final String _baseUrl = 'https://bmsmipa-default-rtdb.asia-southeast1.firebasedatabase.app/tuning.json';

  @override
  void initState() {
    super.initState();
    dischargeController = TextEditingController(text: dischargeCurrent.toString());
    temperatureController = TextEditingController(text: temperatureCutoff.toString());
    voltageController = TextEditingController(text: voltageCutoff.toString());
    _fetchInitialData(dropdownValue);
  }

  @override
  void dispose() {
    // Dispose controller saat tidak digunakan
    dischargeController.dispose();
    temperatureController.dispose();
    voltageController.dispose();
    super.dispose();
  }

  void _fetchInitialData(String threshold) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          String key = _getThresholdKey(threshold);
          dischargeCurrent = data[key]['current']?.toDouble() ?? 30;
          temperatureCutoff = data[key]['temp']?.toDouble() ?? 15;
          voltageCutoff = data[key]['volt']?.toDouble() ?? 25;

          // Update nilai controller saat data di-fetch
          dischargeController.text = dischargeCurrent.toString();
          temperatureController.text = temperatureCutoff.toString();
          voltageController.text = voltageCutoff.toString();
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _saveData() async {
    Map<String, dynamic> jsonData = {
      "current": dischargeCurrent,
      "temp": temperatureCutoff,
      "volt": voltageCutoff
    };

    String selectedThreshold = _getThresholdKey(dropdownValue);

    try {
      final response = await http.patch(
        Uri.parse(_baseUrl),
        body: json.encode({selectedThreshold: jsonData}),
      );

      if (response.statusCode == 200) {
        print('Data saved successfully');
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  String _getThresholdKey(String threshold) {
    switch (threshold) {
      case 'Low threshold':
        return 'low';
      case 'Medium threshold':
        return 'mid';
      case 'High threshold':
        return 'high';
      default:
        return 'mid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 243, 247),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButton<String>(
                value: dropdownValue,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                underline: SizedBox(),
                items: <String>['Low threshold', 'Medium threshold', 'High threshold']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    _fetchInitialData(dropdownValue);
                  });
                },
              ),
            ),
            SizedBox(height: 24),
            _buildSlider(
              title: 'Max. discharge current (A)',
              value: dischargeCurrent,
              min: 0,
              max: 100,
              division: 100,
              onChanged: isEditing
                  ? (double value) {
                      setState(() {
                        dischargeCurrent = value;
                        dischargeController.text = value.toStringAsFixed(1);
                      });
                    }
                  : null,
              controller: dischargeController,
            ),
            _buildSlider(
              title: 'Temperature cut-off (°C)',
              value: temperatureCutoff,
              min: 0,
              max: 30,
              division: 30,
              onChanged: isEditing
                  ? (double value) {
                      setState(() {
                        temperatureCutoff = value;
                        temperatureController.text = value.toStringAsFixed(1);
                      });
                    }
                  : null,
              controller: temperatureController,
            ),
            _buildSlider(
              title: 'Voltage cut-off (V)',
              value: voltageCutoff,
              min: 0,
              max: 50,
              division: 48,
              onChanged: isEditing
                  ? (double value) {
                      setState(() {
                        voltageCutoff = value;
                        voltageController.text = value.toStringAsFixed(1);
                      });
                    }
                  : null,
              controller: voltageController,
            ),
            SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF30B180)),
                      foregroundColor: Color(0xFF30B180),
                    ),
                    child: Text('Edit'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isEditing
                        ? () {
                            setState(() {
                              isEditing = false;
                              _saveData();
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF30B180),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
  required String title,
  required double value,
  required double min,
  required double max,
  required int division,
  required ValueChanged<double>? onChanged,
  required TextEditingController controller, // Controller untuk input manual
}) {
  // Set nilai awal controller sesuai dengan nilai slider sebagai bilangan bulat
  controller.text = value.toStringAsFixed(0);

  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(color: Colors.black)),
          Row(
            children: <Widget>[
              Expanded(
                flex: 4, // Memperbesar ruang slider
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: division,
                  label: value.round().toString(),
                  onChanged: isEditing
                      ? (newValue) {
                          // Perbarui nilai slider dan input manual sebagai bilangan bulat
                          onChanged?.call(newValue);
                          controller.text = newValue.toStringAsFixed(0); // Tampilkan tanpa desimal
                        }
                      : null,
                  activeColor: Color(0xFF30B180),
                  inactiveColor: Color(0xFFD6D6D6),
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                flex: 1, // Ukuran kecil untuk input manual
                child: TextFormField(
                  controller: controller,
                  enabled: isEditing, // Nonaktifkan input manual jika belum dalam mode edit
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  onFieldSubmitted: isEditing
                      ? (text) {
                          int? newValue = int.tryParse(text); // Ubah ke int (bilangan bulat)
                          if (newValue != null && newValue >= min && newValue <= max) {
                            onChanged?.call(newValue.toDouble());
                          }
                        }
                      : null, // Jika tidak dalam mode edit, onFieldSubmitted diabaikan
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


}
