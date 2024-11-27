import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final double maxValue = 4.2;
  final String dataUrl = 'https://bmsmipa-default-rtdb.asia-southeast1.firebasedatabase.app/sensorcel.json';
  late Stream<List<double>> _sensorDataStream;

  @override
  void initState() {
    super.initState();
    // Mulai stream buat fetch data berkala
    _sensorDataStream = _sensorDataPeriodicStream();
  }

  // Stream buat ambil data tiap 1 detik
  Stream<List<double>> _sensorDataPeriodicStream() async* {
    while (true) {
      yield await fetchSensorData();
      await Future.delayed(Duration(seconds: 1)); // Update setiap 1 detik
    }
  }

  // Fungsi fetch data dari Firebase atau HTTP endpoint
  Future<List<double>> fetchSensorData() async {
    try {
      final response = await http.get(Uri.parse(dataUrl));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData is List) {
          return jsonData.map<double>((item) {
            if (item is int) {
              return item.toDouble();
            } else if (item is double) {
              return item;
            } else {
              return 0.0;
            }
          }).toList();
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 243, 247),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<double>>(
          stream: _sensorDataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<double> data = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Avg. Voltage : ',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    (data.reduce((a, b) => a + b) / data.length).toStringAsFixed(2) + " V",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold, // Bold untuk value
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Voltage per Cell',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        height: 200, // Dipendekkan height grafik
                        width: data.length * 40.0, // Lebar grafik per cell
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.center,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipPadding: EdgeInsets.all(5),
                                tooltipMargin: 8,
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    'Cell ${groupIndex + 1}: ${rod.toY.toStringAsFixed(2)} V', // Tambahin Cell info
                                    TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false), // Hapus legend bawah
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            barGroups: data.asMap().entries.map((entry) {
                              int index = entry.key;
                              double value = entry.value;

                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: value,
                                    color: Color(0xFF30B180),
                                    width: 20, // Lebar rod
                                    borderRadius: BorderRadius.circular(10), // Rounded
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: maxValue,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ],
                                barsSpace: 12, // Jarak antar rod
                              );
                            }).toList(),
                            maxY: maxValue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoCard('Min. Voltage', data.reduce((a, b) => a < b ? a : b).toStringAsFixed(2)),
                      _buildInfoCard('Max. Voltage', data.reduce((a, b) => a > b ? a : b).toStringAsFixed(2)),
                    ],
                  ),
                ],
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4, // Distribusi space biar seimbang
      decoration: BoxDecoration(
        color: Colors.white, // Container warna putih
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
