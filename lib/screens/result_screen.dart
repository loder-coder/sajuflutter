import 'package:flutter/material.dart';
import '../api/saju_api.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ResultScreen({super.key, required this.data});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _selectedPeriod = 'daily';
  Map<String, dynamic>? _fortuneData;
  bool _isLoadingFortune = false;
  String? _themeAnalysis;
  bool _isThemeLoading = false;
  late int _recordId;
  bool _isSaved = true; // 서버에 자동 저장됨을 가정

  @override
  void initState() {
    super.initState();
    _recordId = widget.data['record_id'] ?? 0;
    _fetchFortune('daily');
  }

  Future<void> _fetchFortune(String period) async {
    setState(() {
      _selectedPeriod = period;
      _isLoadingFortune = true;
    });
    try {
      final fortune = await SajuApi.getFortune(period, _recordId);
      setState(() {
        _fortuneData = fortune;
        _isLoadingFortune = false;
      });
    } catch (e) {
      setState(() => _isLoadingFortune = false);
    }
  }

  Future<void> _fetchThemeAnalysis(String theme) async {
    setState(() {
      _isThemeLoading = true;
      _themeAnalysis = null;
    });
    try {
      final input = widget.data['input'];
      final result = await SajuApi.calculateSaju(
        birthDate: input['birth_date'],
        birthTime: input['birth_time'],
        timezone: input['timezone'],
        longitude: input['longitude'],
        theme: theme,
        includeAnalysis: true,
        userId: "current_user_id", // 실제 구현 시 Auth 객체에서 가져옴
      );
      setState(() => _themeAnalysis = result['analysis']);
    } catch (e) {
      setState(() => _themeAnalysis = "Analysis failed. Please try again.");
    } finally {
      setState(() => _isThemeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dp = widget.data['saju']?['day'] ?? "--";
    final fortune = _fortuneData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLUEPRINT'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFF66FCF1)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to your profile history.'))
              );
            },
          )
        ]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 프로필 연동 안내
            if (_isSaved)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF45A29E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Color(0xFF45A29E)),
                    SizedBox(width: 8),
                    Text('ARCHIVED IN PROFILE', style: TextStyle(fontSize: 10, color: Color(0xFF45A29E), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            const Text('DAY MASTER', style: TextStyle(color: Color(0xFF45A29E), letterSpacing: 2)),
            Text(dp, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 30),

            // 기간 탭
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['daily', 'weekly', 'monthly', 'yearly'].map((p) => TextButton(
                onPressed: () => _fetchFortune(p),
                child: Text(p.toUpperCase(), 
                  style: TextStyle(
                    color: _selectedPeriod == p ? const Color(0xFF66FCF1) : Colors.grey,
                    fontWeight: _selectedPeriod == p ? FontWeight.bold : FontWeight.normal,
                  )
                ),
              )).toList(),
            ),
            
            // 운세 카드
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 120),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2833), 
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF45A29E).withOpacity(0.2))
              ),
              child: _isLoadingFortune 
                ? const Center(child: CircularProgressIndicator()) 
                : (fortune == null 
                  ? const Center(child: Text("Syncing with stars..."))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fortune['relation_title']?.toString().toUpperCase() ?? "FLOW", 
                              style: const TextStyle(color: Color(0xFF45A29E), fontWeight: FontWeight.bold)
                            ),
                            Text(
                              "${fortune['score'] ?? 0}", 
                              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fortune['advice']?.toString() ?? "Reading your cosmic path...", 
                          style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 15)
                        ),
                      ],
                    )
                ),
            ),

            const SizedBox(height: 40),
            const Align(alignment: Alignment.centerLeft, child: Text('LIFE THEMES', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1))),
            const SizedBox(height: 10),

            Row(
              children: [
                _themeButton('LOVE', Icons.favorite, Colors.pinkAccent),
                _themeButton('WEALTH', Icons.monetization_on, Colors.amber),
                _themeButton('CAREER', Icons.work, Colors.blueAccent),
              ],
            ),

            if (_isThemeLoading || _themeAnalysis != null)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  border: Border.all(color: const Color(0xFF45A29E).withOpacity(0.3)), 
                  borderRadius: BorderRadius.circular(15)
                ),
                child: _isThemeLoading 
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())) 
                  : Text(_themeAnalysis!, style: const TextStyle(color: Colors.white70, height: 1.7, fontSize: 14)),
              ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _themeButton(String label, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _fetchThemeAnalysis(label.toLowerCase()),
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2833), 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10)
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}