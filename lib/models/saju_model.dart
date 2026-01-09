class SajuModel {
  final Map<String, dynamic> data;

  SajuModel({required this.data});

  factory SajuModel.fromJson(Map<String, dynamic> json) {
    return SajuModel(data: json);
  }

  // --- 기본 정보 추출 ---
  String get userName {
    // 1순위: 루트의 userName, 2순위: input 내부의 user_id, 3순위: Unknown
    return data['userName'] ??
        data['input']?['user_id'] ??
        data['input']?['userName'] ??
        'User';
  }

  String get birthDate =>
      data['birthDate'] ?? data['input']?['birth_date'] ?? '';

  // --- 아키타입 (캐릭터 클래스) ---
  String get mainArchetype {
    // 1. 명시된 아키타입이 있으면 사용
    if (data['archetype'] != null) return data['archetype'];

    // 2. 없으면 일간(Day Master)을 보고 생성
    try {
      final dayPillar = data['saju']?['day']; // 예: "丙寅"
      if (dayPillar == null || dayPillar.isEmpty) return "The Wanderer";
      
      final dayGan = dayPillar[0]; // "丙"
      return _archetypeMap[dayGan] ?? "The Seeker";
    } catch (e) {
      return "The Unknown";
    }
  }

  // --- 오행 데이터 (Radar Chart용) ---
  Map<String, double> get elementalStats {
    final elements = data['elements'] ?? {};
    return {
      'Wood': (elements['Wood'] ?? 0).toDouble(),
      'Fire': (elements['Fire'] ?? 0).toDouble(),
      'Earth': (elements['Earth'] ?? 0).toDouble(),
      'Metal': (elements['Metal'] ?? 0).toDouble(),
      'Water': (elements['Water'] ?? 0).toDouble(),
    };
  }

  // --- RPG 스탯 (십성) 자동 계산 ---
  // 백엔드에서 십성 점수를 안 주더라도, 오행 개수와 일간을 이용해 프론트에서 계산
  Map<String, int> get rpgStats {
    if (data['stats'] != null) {
      // 백엔드가 준다면 그거 씀
      final s = data['stats'];
      return {
        'Creativity': s['Creativity'] ?? 0,
        'Discipline': s['Discipline'] ?? 0,
        'Empathy': s['Empathy'] ?? 0,
        'Network': s['Network'] ?? 0,
        'Drive': s['Drive'] ?? 0,
      };
    }

    // 없으면 직접 계산 (일간 기준 십성 관계)
    try {
      final dayPillar = data['saju']?['day']; // "丙寅"
      if (dayPillar == null || dayPillar.isEmpty) return _defaultStats;

      final dayGan = dayPillar[0]; // "丙" (나)
      final myElement = _charToElement[dayGan]; // "Fire"

      if (myElement == null) return _defaultStats;

      final elements = data['elements'] ?? {}; // {"Wood": 2, "Fire": 2...}

      // 십성 관계 매핑
      // 비겁(Network): 나와 같은 오행
      // 식상(Creativity): 내가 생하는 오행
      // 재성(Drive): 내가 극하는 오행
      // 관성(Discipline): 나를 극하는 오행
      // 인성(Empathy): 나를 생하는 오행

      int getCount(String? elm) => (elements[elm] ?? 0) as int;

      // 오행의 상생 흐름: Wood -> Fire -> Earth -> Metal -> Water -> Wood
      final flow = ['Wood', 'Fire', 'Earth', 'Metal', 'Water'];
      int myIdx = flow.indexOf(myElement);

      String elementAt(int offset) {
        return flow[(myIdx + offset) % 5];
      }

      // 점수 계산 (기본 1점 + 개수 * 20점, 최대 100점 스케일 -> 1~5 별점)
      // 여기서는 5점 만점(별 개수)으로 환산
      int calcScore(String elm) {
        int count = getCount(elm);
        if (count == 0) return 1;
        if (count == 1) return 2;
        if (count == 2) return 3;
        if (count == 3) return 4;
        return 5; // 4개 이상이면 만렙
      }

      return {
        'Network': calcScore(elementAt(0)),      // 비겁 (Same)
        'Creativity': calcScore(elementAt(1)),   // 식상 (Output)
        'Drive': calcScore(elementAt(2)),        // 재성 (Wealth)
        'Discipline': calcScore(elementAt(3)),   // 관성 (Control)
        'Empathy': calcScore(elementAt(4)),      // 인성 (Resource)
      };

    } catch (e) {
      return _defaultStats;
    }
  }

  // --- 유틸리티 및 매핑 데이터 ---

  String get vibeKeyword => data['analysis'] != null ? "Analyzed" : "Waiting...";
  
  String get yearTheme => "2026 Flow"; // 임시 타이틀
  String get yearDescription {
     // 분석 텍스트가 있으면 요약해서 보여줌, 없으면 기본 문구
     if (data['analysis'] != null) {
       String analysis = data['analysis'].toString();
       if (analysis.length > 100) return analysis.substring(0, 100).replaceAll('#', '').trim() + "...";
       return analysis;
     }
     return "Destiny is unfolding...";
  }

  static const _defaultStats = {
    'Creativity': 1,
    'Discipline': 1,
    'Empathy': 1,
    'Network': 1,
    'Drive': 1,
  };

  static const Map<String, String> _charToElement = {
    '甲': 'Wood', '乙': 'Wood',
    '丙': 'Fire', '丁': 'Fire',
    '戊': 'Earth', '己': 'Earth',
    '庚': 'Metal', '辛': 'Metal',
    '壬': 'Water', '癸': 'Water',
  };

  static const Map<String, String> _archetypeMap = {
    '甲': 'The Pioneer',   // 개척자 (큰 나무)
    '乙': 'The Strategist',// 전략가 (덩굴)
    '丙': 'The Illuminator',// 태양 (밝음)
    '丁': 'The Alchemist', // 촛불/별 (집중)
    '戊': 'The Guardian',  // 태산 (신뢰)
    '己': 'The Nurturer',  // 옥토 (포용)
    '庚': 'The Warrior',   // 원석/도끼 (결단)
    '辛': 'The Artisan',   // 보석 (섬세)
    '壬': 'The Voyager',   // 바다 (유연)
    '癸': 'The Mystic',    // 빗물 (지혜)
  };
}