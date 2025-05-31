import 'package:http/http.dart' as http;
import 'dart:convert';

class BaseNetwork {
  static const String baseUrl = 'https://f1api.dev/api';
  
  static Future<List<dynamic>> getData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Memeriksa endpoint dan mengembalikan data yang sesuai
      if (endpoint == 'current/drivers' && data is Map && data.containsKey('drivers')) {
        return data['drivers'] ?? [];
      } else if (endpoint == 'current/teams' && data is Map && data.containsKey('teams')) {
        return data['teams'] ?? [];
      } else if (endpoint == 'circuits' && data is Map && data.containsKey('circuits')) {
        return data['circuits'] ?? [];
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load data from API: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getDetailData(String endpoint, int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load detail data from API: ${response.statusCode}');
    }
  }
}