import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 안전하게 데이터 파싱
    final dayPillar = data['saju']?['day'] ?? "Unknown";
    final analysis = data['analysis']; // AI 분석 결과

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Blueprint'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView( // 스크롤 가능하게
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Day Master',
              style: TextStyle(color: Color(0xFF45A29E), letterSpacing: 2.0),
            ),
            const SizedBox(height: 10),
            Text(
              dayPillar,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 30),
            
            // AI 분석 결과 표시 (있으면 보여주고 없으면 로딩 중 메시지)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2833),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF45A29E).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: Color(0xFF66FCF1), size: 20),
                      SizedBox(width: 10),
                      Text(
                        "AI Analysis",
                        style: TextStyle(color: Color(0xFF66FCF1), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    analysis ?? "Consulting the Oracle...", // 분석 결과 없으면 대기 메시지
                    style: const TextStyle(color: Colors.white70, height: 1.6),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF45A29E),
                foregroundColor: Colors.black,
              ),
              child: const Text('Analyze Again'),
            ),
          ],
        ),
      ),
    );
  }
}