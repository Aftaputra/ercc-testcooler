import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> fetchSensorData() async {
    // URL API yang mau diambil datanya
    var url = Uri.parse("https://bmsmipa-default-rtdb.asia-southeast1.firebasedatabase.app/sensor_data/sensor_test.json");

    // Mengirim GET request ke API
    var response = await http.get(url);

    // Mengecek apakah request berhasil
    if (response.statusCode == 200) {
      // Mengambil data dari body response dan mengubahnya ke Map (JSON)
      var data = jsonDecode(response.body);

      // Memastikan data sesuai dengan format yang diinginkan
      return {"sensor_data": {"sensor_test": data}};
    } else {
      throw Exception("Failed to fetch data: ${response.statusCode}");
    }
  }
}