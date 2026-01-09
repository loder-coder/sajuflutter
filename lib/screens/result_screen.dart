import 'dart:math';
import 'package:flutter/material.dart';
import '../models/saju_model.dart';

class ResultScreen extends StatefulWidget {
  final SajuModel sajuModel;

  const ResultScreen({super.key, required this.sajuModel});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Joseon Pixel-Punk Color Palette ---
  final Color bgInk = const Color(0xFF121216);      // 먹색 (배경)
  final Color paperGrey = const Color(0xFFD3D3D3);  // 한지 회색 (텍스트)
  final Color danRed = const Color(0xFFD94844);     // 단청 적색
  final Color danBlue = const Color(0xFF496EA7);    // 단청 청색
  final Color danGreen = const Color(0xFF488C68);   // 단청 녹색
  final Color goldCoin = const Color(0xFFE5B04F);   // 엽전 금색

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgInk,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildPixelDivider(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // 탭바로만 이동 (게임 느낌)
                children: [
                  _RoadmapTab(model: widget.sajuModel, colors: _colors),
                  _DimensionsTab(model: widget.sajuModel, colors: _colors),
                  _BondTab(model: widget.sajuModel, colors: _colors),
                  _SoulProfileTab(model: widget.sajuModel, colors: _colors),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildPixelBottomNav(),
    );
  }

  // 색상 전달용 맵 getter
  Map<String, Color> get _colors => {
        'bg': bgInk,
        'paper': paperGrey,
        'red': danRed,
        'blue': danBlue,
        'green': danGreen,
        'gold': goldCoin,
      };

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.token, color: goldCoin, size: 24),
              const SizedBox(width: 10),
              Text(
                "SAJU.OS",
                style: TextStyle(
                  color: paperGrey,
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
          _PixelBadge(
            text: "USER: ${widget.sajuModel.userName}",
            color: danBlue,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildPixelDivider() {
    return Container(
      height: 4,
      color: Colors.black,
      child: Row(
        children: List.generate(
          10,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: index % 2 == 0 ? danRed : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPixelBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A20),
        border: const Border(top: BorderSide(color: Colors.white24, width: 2)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: goldCoin,
        indicatorWeight: 4,
        labelColor: goldCoin,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(icon: Icon(Icons.map_outlined), text: "ROADMAP"),
          Tab(icon: Icon(Icons.grid_view), text: "THEMES"),
          Tab(icon: Icon(Icons.cable), text: "BOND"),
          Tab(icon: Icon(Icons.person_pin), text: "PROFILE"),
        ],
      ),
    );
  }
}

// =============================================================================
// UI Components (Pixel Art Style)
// =============================================================================

class _PixelContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double padding;

  const _PixelContainer({
    required this.child,
    this.backgroundColor = const Color(0xFF1E1E26),
    this.borderColor = Colors.white24,
    this.padding = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.black, // Hard shadow color
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0, // No blur for pixel feel
          ),
        ],
      ),
      child: Container(
        transform: Matrix4.translationValues(-2, -2, 0), // Shift for shadow effect
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: child,
      ),
    );
  }
}

class _PixelBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _PixelBadge({required this.text, required this.color, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader(this.title, {this.color = const Color(0xFFE5B04F)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Container(width: 8, height: 8, color: color),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 2, color: Colors.white12)),
        ],
      ),
    );
  }
}

// =============================================================================
// Tab 1: The Roadmap (Time-based)
// =============================================================================
class _RoadmapTab extends StatelessWidget {
  final SajuModel model;
  final Map<String, Color> colors;

  const _RoadmapTab({required this.model, required this.colors});

  @override
  Widget build(BuildContext context) {
    // 실제 데이터 사용
    final dailyVibe = model.vibeKeyword;
    final yearTheme = model.yearTheme;
    final yearDesc = model.yearDescription;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader("Daily Forecast", color: colors['red']!),
        _PixelContainer(
          borderColor: colors['red']!,
          child: Row(
            children: [
              Icon(Icons.sunny, color: colors['red'], size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S KEYWORD",
                      style: TextStyle(color: Colors.grey, fontFamily: 'monospace', fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dailyVibe.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "The energy flows towards change. Check your surroundings.",
                      style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 12),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),

        _SectionHeader("Yearly Theme", color: colors['blue']!),
        _PixelContainer(
          borderColor: colors['blue']!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("2026 ARCHETYPE", style: TextStyle(color: colors['blue'], fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  Icon(Icons.calendar_today, color: colors['blue'], size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                yearTheme.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(height: 2, width: 40, color: colors['blue']),
              const SizedBox(height: 12),
              Text(
                yearDesc,
                style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Tab 2: Dimensions (Themes)
// =============================================================================
class _DimensionsTab extends StatelessWidget {
  final SajuModel model;
  final Map<String, Color> colors;

  const _DimensionsTab({required this.model, required this.colors});

  @override
  Widget build(BuildContext context) {
    // 실제 데이터가 없으면 기본값 0 표시
    final rpg = model.rpgStats;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader("Life Stats", color: colors['green']!),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _buildStatCard("WEALTH", "Drive", rpg['Drive'] ?? 0, colors['gold']!),
            _buildStatCard("CAREER", "Discipline", rpg['Discipline'] ?? 0, colors['blue']!),
            _buildStatCard("SOCIAL", "Network", rpg['Network'] ?? 0, colors['red']!),
            _buildStatCard("CREATIVE", "Output", rpg['Creativity'] ?? 0, colors['green']!),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String subTitle, int level, Color color) {
    return _PixelContainer(
      borderColor: color,
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.bolt, color: color, size: 20),
              Text("LV.$level", style: TextStyle(color: color, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.grey, fontFamily: 'monospace', fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            subTitle.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Progress Bar
          Container(
            height: 6,
            width: double.infinity,
            color: Colors.white10,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (level / 5).clamp(0.0, 1.0),
              child: Container(color: color),
            ),
          )
        ],
      ),
    );
  }
}

// =============================================================================
// Tab 3: The Bond (Social)
// =============================================================================
class _BondTab extends StatelessWidget {
  final SajuModel model;
  final Map<String, Color> colors;

  const _BondTab({required this.model, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PixelContainer(
              borderColor: Colors.white30,
              padding: 30,
              child: Icon(Icons.link_off, size: 48, color: Colors.white54),
            ),
            const SizedBox(height: 30),
            Text(
              "NO CONNECTION",
              style: TextStyle(color: colors['red'], fontFamily: 'monospace', fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Invite a friend to unlock\nthe Chemistry Module.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontFamily: 'monospace', height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // 공유 로직 추후 구현
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors['blue'],
                  shape: const RoundedRectangleBorder(), // 사각형 버튼
                  elevation: 0,
                  side: const BorderSide(color: Colors.black, width: 2), // 픽셀 테두리
                ),
                child: const Text(
                  "GENERATE INVITE CODE",
                  style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Tab 4: Soul Profile (My Page)
// =============================================================================
class _SoulProfileTab extends StatelessWidget {
  final SajuModel model;
  final Map<String, Color> colors;

  const _SoulProfileTab({required this.model, required this.colors});

  @override
  Widget build(BuildContext context) {
    // 실제 데이터 로드
    final archetype = model.mainArchetype;
    final stats = model.elementalStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ID Card Style
          Container(
            decoration: BoxDecoration(
              color: colors['gold'], // Gold border
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              color: const Color(0xFF15151A),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("ID: ${model.userName}", style: TextStyle(color: colors['gold'], fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                      Icon(Icons.qr_code_2, color: colors['gold']),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colors['gold']?.withOpacity(0.1),
                    child: Icon(Icons.face, size: 40, color: colors['gold']),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    archetype.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Primary Class",
                    style: TextStyle(color: Colors.grey, fontFamily: 'monospace', fontSize: 12),
                  ),
                  const SizedBox(height: 32),
                  
                  // Radar Chart
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CustomPaint(
                      painter: _PixelRadarPainter(stats: stats, lineColor: colors['blue']!),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text("SAVE CARD IMAGE"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                shape: const RoundedRectangleBorder(),
                textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Pixel Art Radar Chart
// -----------------------------------------------------------------------------
class _PixelRadarPainter extends CustomPainter {
  final Map<String, double> stats;
  final Color lineColor;

  _PixelRadarPainter({required this.stats, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(centerX, centerY);

    final paintGrid = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Thick lines for pixel look

    final paintFill = Paint()
      ..color = lineColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw Background Pentagon Grid
    for (int level = 1; level <= 3; level++) {
      double r = radius * (level / 3);
      var path = Path();
      for (int i = 0; i < 5; i++) {
        double angle = (2 * pi / 5) * i - (pi / 2);
        double x = centerX + r * cos(angle);
        double y = centerY + r * sin(angle);
        if (i == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paintGrid);
    }

    // Draw Data Polygon
    var pathStat = Path();
    // Keys match SajuModel getters
    final values = [
      stats['Wood'] ?? 0,
      stats['Fire'] ?? 0,
      stats['Earth'] ?? 0,
      stats['Metal'] ?? 0,
      stats['Water'] ?? 0,
    ];

    // Normalize values (assuming input is roughly 0-10 or 0-100, normalize to radius)
    // 데이터가 1.0 단위(0.0~1.0)인지 100단위인지 모르므로 일단 최대값 기준으로 정규화하거나 100을 max로 가정
    double maxVal = values.reduce(max);
    if (maxVal == 0) maxVal = 1; 

    for (int i = 0; i < 5; i++) {
      double angle = (2 * pi / 5) * i - (pi / 2);
      // Normalize to 0.0 ~ 1.0 range based on a fixed max (e.g., 10 or 100) or dynamic max
      // 여기서는 값이 0~1.0 사이라고 가정하거나, 큰 값이면 줄임
      double rawVal = values[i];
      double normalized = (rawVal > 1.0) ? rawVal / 100.0 : rawVal; // Heuristic
      if (normalized > 1.0) normalized = 1.0;

      double valRadius = radius * normalized;
      
      double sx = centerX + valRadius * cos(angle);
      double sy = centerY + valRadius * sin(angle);
      
      if (i == 0) pathStat.moveTo(sx, sy);
      else pathStat.lineTo(sx, sy);

      // Draw Pixel Point (Square)
      canvas.drawRect(
        Rect.fromCenter(center: Offset(sx, sy), width: 8, height: 8),
        Paint()..color = lineColor,
      );
    }
    pathStat.close();
    
    canvas.drawPath(pathStat, paintFill);
    canvas.drawPath(pathStat, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}