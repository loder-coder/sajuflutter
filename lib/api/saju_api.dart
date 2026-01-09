import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saju_model.dart';

class SajuApi {
  // 본인의 Railway 서버 주소 (끝에 / 빼기)
  static const String baseUrl = 'https://saju-production-4978.up.railway.app';

  // 1. 사주 계산 및 저장 요청
  static Future<SajuModel> calculateSaju({
    required String birthDate,
    required String birthTime,
    String timezone = 'Asia/Seoul',
    double longitude = 127.0,
    double latitude = 37.5,
    String? userId, // 구글 로그인 UID (이게 있어야 DB에 저장됨)
    String? birthPlace, // [NEW] 도시 이름 추가 (백엔드 GeoService용)
    String theme = 'general',
    bool includeAnalysis = false,
  }) async {
    final url = Uri.parse('$baseUrl/saju');
    
    final body = {
      'birth_date': birthDate,
      'birth_time': birthTime,
      'timezone': timezone,
      'longitude': longitude,
      'latitude': latitude, // [NEW] 위도 전송
      'birth_place': birthPlace, // [NEW] 도시 이름 전송
      'include_analysis': includeAnalysis,
      'theme': theme,
      'user_id': userId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Map 데이터를 SajuModel 객체로 변환해서 반환
        return SajuModel.fromJson(data);
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

  // 3. 내 과거 기록 목록 가져오기 (보관함용)
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