import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../ble_provider.dart'; // Import BLEProvider

class DashboardPage extends StatefulWidget {
  final double level;
  final int amperage;
  final String batteryHealth;
  final int voltage;
  final int temperature;

  DashboardPage({
    required this.level,
    required this.amperage,
    required this.batteryHealth,
    required this.voltage,
    required this.temperature,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  bool isCooling = false; // Status tombol Cooler (Idle atau Cooling)
  bool isBLEEnabled = false; // Status toggle Wi-Fi/BLE
  late AnimationController _controller; // Controller untuk animasi rotasi

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Hentikan controller saat widget dibuang
    super.dispose();
  }

  void _toggleCooling() {
    setState(() {
      isCooling = !isCooling;
      if (isCooling) {
        _controller.repeat(); // Mulai animasi berputar
      } else {
        _controller.stop(); // Hentikan animasi
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var bleProvider = Provider.of<BLEProvider>(context); // Access BLEProvider
    return Container(
      color: Color.fromARGB(255, 241, 243, 247), // Background color
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WiFi/BLE toggle switch section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    bleProvider.isBLEEnabled ? Icons.bluetooth : Icons.wifi,
                    size: 28,
                    color: bleProvider.isBLEEnabled ? Colors.blue : Colors.green,
                  ),
                  SizedBox(width: 8),
                  Text(
                    bleProvider.isBLEEnabled ? 'Bluetooth' : 'Wi-Fi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Switch(
                value: bleProvider.isBLEEnabled,
                onChanged: (value) {
                  bleProvider.toggleBLE(value);
                },
                activeColor: Colors.blue,
                inactiveThumbColor: Colors.green,
                inactiveTrackColor: Colors.green.shade200,
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(16),
            width: double.infinity, // Full horizontal width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isCooling
                      ? '${(widget.level * 100).toStringAsFixed(0)}% - Cooling'
                      : '${(widget.level * 100).toStringAsFixed(0)}% - Idle',
                  style: TextStyle(
                    color: isCooling ? Colors.blue : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '8 h 15 m remaining',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16),
                CircularPercentIndicator(
                  reverse: true,
                  radius: 38.0, // Setengah dari 76px
                  lineWidth: 10.0, // Sesuaikan dengan ketebalan lingkaran
                  percent: widget.level,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Icon(
                    Icons.bolt,
                    size: 32.0,
                    color: isCooling ? Colors.green : Colors.black,
                  ),
                  progressColor: _getBatteryColor(
                      widget.level), // Warna berubah sesuai level
                  backgroundColor: Colors.grey.shade300,
                ),
                SizedBox(height: 16),
                Text(
                  'Last charge was 7 h ago',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _toggleCooling, // Ubah state saat tombol ditekan
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300), // Animasi perubahan warna
              decoration: BoxDecoration(
                gradient: isCooling
                    ? null // Jika Cooling, tidak ada gradasi, warna putih dengan border biru
                    : LinearGradient(
                        colors: [
                          Colors.lightGreenAccent,
                          Colors.blue.shade800,
                          Colors.black,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isCooling ? Colors.white : null,
                borderRadius: BorderRadius.circular(20),
                border: isCooling
                    ? Border.all(color: Colors.black12, width: 2)
                    : Border.all(color: Colors.white, width: 2),
              ),
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rotating Icon
                  RotationTransition(
                    turns:
                        _controller, // Menggunakan controller untuk animasi rotasi
                    child: Icon(
                      Icons.ac_unit_rounded,
                      color: isCooling ? Colors.black : Colors.white,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    isCooling ? 'Cooler Active' : 'Cooler',
                    style: TextStyle(
                      color: isCooling ? Colors.black : Colors.white,
                      fontSize: 24,
                      fontWeight: isCooling ? FontWeight.w600 : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16), // Tambahin space biar nggak nabrak yang bawah
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2 / 1.5,
              children: [
                _buildInfoCard(
                    'Amperage', '${widget.amperage} mAh', Icons.waves),
                _buildInfoCard('Battery Health', widget.batteryHealth,
                    Icons.battery_charging_full),
                _buildInfoCard('Voltage', '${widget.voltage} V', Icons.power),
                _buildInfoCard('Temperature', '${widget.temperature} C',
                    Icons.thermostat_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(double level) {
    int red, green;
    int b = 48; // Biru tetap konstan
    if (isCooling) {
      red = 0;
      green = 75;
      b = 150;
    } else {
      if (level > 0.5) {
        // Transisi dari Hijau ke Kuning
        red = (48 + (level - 0.5) * 2 * (151 - 48)).toInt();
        green = 177;
      } else {
        // Transisi dari Kuning ke Merah
        red = 151 + ((0.5 - level) * 2 * (177 - 151)).toInt();
        green = (177 - (0.5 - level) * 2 * (177 - 48)).toInt();
      }
    }

    return Color.fromARGB(255, red, green, b);
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              icon,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
