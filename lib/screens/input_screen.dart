import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/saju_api.dart';
import 'result_screen.dart'; // 결과 화면으로 이동

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  bool _isLoading = false;

  // 날짜 선택기
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF45A29E),
              onPrimary: Colors.black,
              surface: Color(0xFF1F2833),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // 시간 선택기
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF45A29E),
              onPrimary: Colors.black,
              surface: Color(0xFF1F2833),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      setState(() {
        _timeController.text = DateFormat('HH:mm').format(dt);
      });
    }
  }

  // 분석 시작
  Future<void> _analyze() async {
    if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await SajuApi.calculateSaju(
        birthDate: _dateController.text,
        birthTime: _timeController.text,
        timezone: 'America/New_York', // 일단 고정 (나중에 선택 기능 추가 가능)
        longitude: -74.0060,
      );

      if (!mounted) return;
      
      // 결과 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(data: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Origin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 날짜 입력
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Birth Date',
                labelStyle: TextStyle(color: Color(0xFF45A29E)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF45A29E))),
                suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF45A29E)),
              ),
            ),
            const SizedBox(height: 20),
            
            // 시간 입력
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: _selectTime,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Birth Time',
                labelStyle: TextStyle(color: Color(0xFF45A29E)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF45A29E))),
                suffixIcon: Icon(Icons.access_time, color: Color(0xFF45A29E)),
              ),
            ),
            const SizedBox(height: 40),

            // 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF45A29E),
                  foregroundColor: Colors.black,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('REVEAL MY ENERGY', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}