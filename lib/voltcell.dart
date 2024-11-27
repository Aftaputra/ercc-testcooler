import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Untuk decoding JSON
import 'dart:async'; // Untuk StreamController
import 'main.dart';

class ProgressBarPage extends StatefulWidget {
  @override
  _ProgressBarPageState createState() => _ProgressBarPageState();
}

class _ProgressBarPageState extends State<ProgressBarPage> {
  final double maxValue = 4.2;
  final StreamController<List<double>> _dataController = StreamController<List<double>>();
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    // Setup timer to refresh data every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://bmsmipa-default-rtdb.asia-southeast1.firebasedatabase.app/sensorcel.json'),
      );

      if (response.statusCode == 200) {
        // Decode JSON data
        var jsonData = json.decode(response.body);

        // Print data untuk debugging
        print('Received JSON data: $jsonData');

        // Pastikan jsonData adalah List
        if (jsonData is List) {
          List<double> data = jsonData.map((item) {
            // Pastikan item adalah int atau double sebelum konversi
            if (item is int) {
              return item.toDouble();
            } else if (item is double) {
              return item;
            } else {
              // Handle jika item bukan int atau double
              return 0.0; // Bisa sesuaikan dengan nilai default atau error handling
            }
          }).toList();

          _dataController.add(data);
          setState(() {
            isLoading = false;
          });
        } else {
          throw Exception('Data is not a list');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      _dataController.addError(e);
    }
  }

  @override
  void dispose() {
    _dataController.close(); // Tutup controller saat widget dibuang
    _timer?.cancel(); // Hentikan timer saat widget dibuang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
        ),
        title: Text('Volt per-cell'),
      ),
      body: StreamBuilder<List<double>>(
        stream: _dataController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          // Ambil data dari snapshot
          List<double> data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              double value = data[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Row(
                  children: [
                    // Penomoran di sebelah kiri
                    Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 16), // Spasi antara nomor dan progress bar
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final snackBar = SnackBar(
                            content: Text('Value: ${value.toStringAsFixed(1)}/$maxValue'),
                            duration: Duration(seconds: 2),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Membuat progress bar rounded
                          child: LinearProgressIndicator(
                            value: value / maxValue,
                            minHeight: 20,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.lerp(Colors.red, Colors.green, value / maxValue)!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
