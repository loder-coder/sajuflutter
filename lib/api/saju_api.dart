import 'dart:convert';
import 'package:http/http.dart' as http;

class SajuApi {
  // [수정 포인트 1] 여기에 'https://'를 포함한 도메인을 정확히 입력 (끝에 슬래시 / 제거)
  static const String baseUrl = 'https://saju-production-4978.up.railway.app';

  static Future<Map<String, dynamic>> calculateSaju({
    required String birthDate,
    required String birthTime,
    required String timezone,
    required double longitude,
    String theme = 'general',
  }) async {
    // [수정 포인트 2] baseUrl에 이미 https://가 있으므로 Uri.parse에 그대로 사용
    final url = Uri.parse('$baseUrl/saju');
    
    // 로그 찍어서 주소 확인 (디버깅용)
    print('Requesting URL: $url'); 
    
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
          'include_analysis': true,
          'theme': theme,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // saju 데이터가 없으면 에러 처리
        if (data['saju'] == null) {
          throw Exception('Invalid Data: No Saju info returned');
        }
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Server Error: 404 - ${response.body}');
      } else {
        throw Exception('Server Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow; // 에러를 상위로 던져서 화면에 표시
    }
  }

  static Future<Map<String, dynamic>> getDailyFortune(int recordId) async {
    final url = Uri.parse('$baseUrl/fortune/daily/$recordId');
    print('Requesting Fortune URL: $url');

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Fortune Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Fortune API Error: $e');
      rethrow;
    }
  }
}