import 'dart:convert';
import 'package:http/http.dart' as http;

class SajuApi {
  // 본인의 Railway 서버 주소 (끝에 / 빼기)
  static const String baseUrl = 'https://saju-production-4978.up.railway.app';

  // 1. 사주 계산 및 저장 요청
  static Future<Map<String, dynamic>> calculateSaju({
    required String birthDate,
    required String birthTime,
    required String timezone,
    required double longitude,
    String? userId, // 구글 로그인 UID (이게 있어야 DB에 저장됨)
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
          'user_id': userId,
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

  // 2. 기간별 운세 (Daily, Weekly 등) 가져오기
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

  // 3. [중요] 내 과거 기록 목록 가져오기 (보관함용)
  static Future<List<dynamic>> getUserHistory(String userId) async {
    final url = Uri.parse('$baseUrl/history/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        return [];
      }
    } catch (e) {
      print("History Load Failed: $e");
      return [];
    }
  }

  // 4. 유저 로그인 정보 동기화 (회원가입/로그인 시 호출)
  static Future<void> syncUser({
    required String uid,
    required String email,
    String provider = 'google',
  }) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'email': email,
          'provider': provider,
        }),
      );
    } catch (e) {
      print("User Sync Failed: $e");
    }
  }

  // 5. 도시 검색 (OpenStreetMap 활용)
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