import 'dart:convert';
import 'package:http/http.dart' as http;

class SajuApi {
  // 본인의 Railway 서버 주소 (끝에 / 빼기)
  static const String baseUrl = 'https://saju-production-4978.up.railway.app';

  static Future<Map<String, dynamic>> calculateSaju({
    required String birthDate,
    required String birthTime,
    required String timezone,
    required double longitude,
    String? userId, // [추가됨] 이 부분이 없어서 에러 났던 거임
    String theme = 'general',
    bool includeAnalysis = false,
  }) async {
    final url = Uri.parse('$baseUrl/saju');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'birth_date': birthDate,
          'birth_time': birthTime,
          'timezone': timezone,
          'longitude': longitude,
          'latitude': 0.0,
          'include_analysis': includeAnalysis,
          'theme': theme,
          'user_id': userId, // 백엔드 Redis/DB 연동용
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection Failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getFortune(String period, int recordId) async {
    final url = Uri.parse('$baseUrl/fortune/$period/$recordId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Fortune Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection Failed: $e');
    }
  }

  static Future<List<dynamic>> searchLocation(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}