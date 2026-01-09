import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/saju_api.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  
  double _longitude = -74.0060; // 기본값 뉴욕
  String _timezone = 'America/New_York';
  bool _isLoading = false;
  List<dynamic> _searchResults = [];

  // 날짜/시간 선택기는 기존과 동일
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      final now = DateTime.now();
      setState(() => _timeController.text = DateFormat('HH:mm').format(DateTime(now.year, now.month, now.day, picked.hour, picked.minute)));
    }
  }

  // [신규] 지역 검색 로직
  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    final results = await SajuApi.searchLocation(query);
    setState(() => _searchResults = results);
  }

  Future<void> _analyze() async {
    if (_dateController.text.isEmpty || _timeController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final result = await SajuApi.calculateSaju(
        birthDate: _dateController.text,
        birthTime: _timeController.text,
        timezone: _timezone,
        longitude: _longitude,
      );
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(data: result)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ENTER ORIGIN'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(labelText: 'Birth Date', suffixIcon: Icon(Icons.calendar_today)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: _selectTime,
              decoration: const InputDecoration(labelText: 'Birth Time', suffixIcon: Icon(Icons.access_time)),
            ),
            const SizedBox(height: 20),
            
            // 지역 검색 필드
            TextField(
              controller: _locationController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                labelText: 'City Search',
                hintText: 'e.g. Seoul, New York',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(color: const Color(0xFF1F2833), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: _searchResults.map((item) => ListTile(
                    title: Text(item['display_name'], style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    onTap: () {
                      setState(() {
                        _locationController.text = item['display_name'].split(',')[0];
                        _longitude = double.parse(item['lon']);
                        _searchResults = [];
                        // 대략적인 타임존 설정 로직 (실제로는 더 복잡하지만 우선 고정/유추)
                        _timezone = _longitude > 100 ? 'Asia/Seoul' : 'America/New_York';
                      });
                    },
                  )).toList(),
                ),
              ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyze,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF45A29E)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('REVEAL MY ENERGY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}