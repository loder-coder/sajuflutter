import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/saju_model.dart';

class ResultScreen extends StatefulWidget {
  final SajuModel sajuModel;

  const ResultScreen({super.key, required this.sajuModel});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Theme Colors (Synced with Intro/Input) ---
  final Color bgStart = const Color(0xFF08080A);
  final Color bgEnd = const Color(0xFF101018);
  
  // Oriental Accents
  final Color accentTeal = const Color(0xFF00E676); // 메인 액센트
  final Color danRed = const Color(0xFFFF4E50);     // 주작
  final Color danBlue = const Color(0xFF1976D2);    // 청룡
  final Color danGold = const Color(0xFFFFD700);    // 황금

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
      backgroundColor: bgStart,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _RoadmapTab(model: widget.sajuModel, colors: _colors),
                    _DimensionsTab(model: widget.sajuModel, colors: _colors),
                    _BondTab(model: widget.sajuModel, colors: _colors),
                    _SoulProfileTab(model: widget.sajuModel, colors: _colors),
                  ],
                ),
              ),
              // 하단 네비게이션 바 공간 확보
              SizedBox(height: 80 + MediaQuery.of(context).padding.bottom), 
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Map<String, Color> get _colors => {
        'teal': accentTeal,
        'red': danRed,
        'blue': danBlue,
        'gold': danGold,
      };

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "SAJU.OS",
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentTeal.withOpacity(0.3)),
            ),
            child: Text(
              widget.sajuModel.userName.toUpperCase(),
              style: GoogleFonts.inter(
                color: accentTeal,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      margin: EdgeInsets.fromLTRB(24, 0, 24, 30 + MediaQuery.of(context).padding.bottom),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TabBar(
            controller: _tabController,
            indicator: const UnderlineTabIndicator(borderSide: BorderSide.none),
            labelColor: accentTeal,
            unselectedLabelColor: Colors.white24,
            onTap: (index) => setState(() {}),
            tabs: [
              _buildTabItem(Icons.timeline, 0),
              _buildTabItem(Icons.grid_view, 1),
              _buildTabItem(Icons.emergency_share, 2), // Bond
              _buildTabItem(Icons.fingerprint, 3), // Profile
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms).moveY(begin: 50, end: 0);
  }

  Widget _buildTabItem(IconData icon, int index) {
    final isSelected = _tabController.index == index;
    return Tab(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: isSelected
            ? BoxDecoration(
                color: accentTeal.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: accentTeal.withOpacity(0.2), blurRadius: 12)],
              )
            : null,
        child: Icon(icon, size: 22),
      ),
    );
  }
}

// =============================================================================
// UI Components
// =============================================================================

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final bool isGlowing;

  const _GlassCard({
    required this.child,
    this.borderColor,
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.08), 
          width: 1
        ),
        boxShadow: isGlowing
            ? [BoxShadow(color: (borderColor ?? Colors.white).withOpacity(0.15), blurRadius: 20, spreadRadius: -5)]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader(this.title, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

// =============================================================================
// Tabs
// =============================================================================

// 1. Roadmap Tab
class _RoadmapTab extends StatelessWidget {
  final SajuModel model;
  final Map<String, Color> colors;

  const _RoadmapTab({required this.model, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader("TODAY'S ENERGY", color: colors['red']!),
        _GlassCard(
          borderColor: colors['red']!.withOpacity(0.3),
          isGlowing: true,
          child: Row(
            children: [
              Icon(Icons.sunny, color: colors['red'], size: 32),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.vibeKeyword.toUpperCase(),
                      style: GoogleFonts.cinzel(
                        color: Colors.white, 
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "High intensity energy detected.",
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              )
            ],
          ),
        ).animate().fadeIn().moveX(begin: -20, end: 0),

        _SectionHeader("YEARLY THEME", color: colors['blue']!),
        _GlassCard(
          borderColor: colors['blue']!.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.yearTheme.toUpperCase(),
                style: GoogleFonts.cinzel(
                  color: Colors.white, 
                  fontSize: 20, 
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: Colors.white10),
              const SizedBox(height: 12),
              Text(
                model.yearDescription,
                style: GoogleFonts.inter(
                  color: Colors.white70, 
                  fontSize: 13, 
                  height: 1.6
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).moveX(begin: -20, end: 0),
      ],
    );
  }
}

// 2. Dimensions Tab
class _DimensionsTab extends StatelessWidget {
  final SajuModel model;
  final Map<String, Color> colors;

  const _DimensionsTab({required this.model, required this.colors});

  @override
  Widget build(BuildContext context) {
    final rpg = model.rpgStats;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader("ATTRIBUTE MATRIX", color: colors['teal']!),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _buildStatBox("WEALTH", rpg['Drive'] ?? 0, colors['gold']!, Icons.diamond_outlined),
            _buildStatBox("HONOR", rpg['Discipline'] ?? 0, colors['blue']!, Icons.shield_outlined),
            _buildStatBox("NETWORK", rpg['Network'] ?? 0, colors['red']!, Icons.hub_outlined),
            _buildStatBox("CREATIVE", rpg['Creativity'] ?? 0, colors['teal']!, Icons.auto_fix_high_outlined),
          ],
        ).animate().fadeIn(delay: 100.ms).scale(),
      ],
    );
  }

  Widget _buildStatBox(String label, int value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 28),
          const SizedBox(height: 12),
          Text(
            label, 
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, letterSpacing: 1.5)
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "$value", 
                style: GoogleFonts.cinzel(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
              ),
              const SizedBox(width: 4),
              Text("/ 5", style: GoogleFonts.inter(color: Colors.white24, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// 3. Bond Tab
class _BondTab extends StatelessWidget {
  final SajuModel model;
  final Map<String, Color> colors;

  const _BondTab({required this.model, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors['red']!.withOpacity(0.3)),
              color: colors['red']!.withOpacity(0.05),
            ),
            child: Icon(Icons.link, size: 48, color: colors['red']),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: Offset(0.95, 0.95), end: Offset(1.05, 1.05), duration: 2000.ms),
          
          const SizedBox(height: 32),
          
          Text(
            "CONNECT SOULS",
            style: GoogleFonts.cinzel(
              color: Colors.white, 
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 4.0
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Sync with another blueprint to\nreveal your synergy.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white38, height: 1.5),
          ),
          const SizedBox(height: 48),
          
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.qr_code_scanner, color: colors['teal']),
            label: Text(
              "SCAN CODE", 
              style: GoogleFonts.inter(color: colors['teal'], letterSpacing: 2.0, fontWeight: FontWeight.bold)
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              backgroundColor: colors['teal']!.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. Soul Profile (The Card)
class _SoulProfileTab extends StatelessWidget {
  final SajuModel model;
  final Map<String, Color> colors;

  const _SoulProfileTab({required this.model, required this.colors});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      child: Column(
        children: [
          // Card Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 15)),
              ],
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: CustomPaint(painter: _PatternPainter(color: Colors.white.withOpacity(0.03))),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.nfc, color: Colors.white24, size: 20),
                          Text("IDENTITY CARD", style: GoogleFonts.inter(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      Text(
                        model.mainArchetype.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "The Chosen One",
                        style: GoogleFonts.inter(color: colors['teal'], fontSize: 12, letterSpacing: 4),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Radar Chart
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: CustomPaint(
                          painter: _RadarPainter(stats: model.elementalStats, color: colors['teal']!),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCardStat("STR", "A+"),
                          Container(width: 1, height: 20, color: Colors.white10),
                          _buildCardStat("INT", "S"),
                          Container(width: 1, height: 20, color: Colors.white10),
                          _buildCardStat("LUK", "B"),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ).animate().flip(duration: 800.ms, direction: Axis.horizontal),
          
          const SizedBox(height: 32),
          
          // Share Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colors['teal']!, const Color(0xFF00BFA5)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: colors['teal']!.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    "SHARE IDENTITY",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),
        ],
      ),
    );
  }

  Widget _buildCardStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white24, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// =============================================================================
// Painters
// =============================================================================

class _PatternPainter extends CustomPainter {
  final Color color;
  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double step = 30;
    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadarPainter extends CustomPainter {
  final Map<String, double> stats;
  final Color color;

  _RadarPainter({required this.stats, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final paintGrid = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw Grid (Pentagon)
    for (int i = 1; i <= 3; i++) {
      double r = radius * (i / 3);
      Path path = Path();
      for (int j = 0; j < 5; j++) {
        double angle = (2 * pi / 5) * j - pi / 2;
        double x = center.dx + r * cos(angle);
        double y = center.dy + r * sin(angle);
        if (j == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paintGrid);
    }

    // Draw Stats
    final values = [
      stats['Wood'] ?? 0,
      stats['Fire'] ?? 0,
      stats['Earth'] ?? 0,
      stats['Metal'] ?? 0,
      stats['Water'] ?? 0,
    ];
    
    // Max value normalize (assuming 5 is max)
    double maxVal = 5.0;
    Path statPath = Path();

    for (int i = 0; i < 5; i++) {
      double angle = (2 * pi / 5) * i - pi / 2;
      double val = (values[i] / maxVal).clamp(0.2, 1.0) * radius;
      double x = center.dx + val * cos(angle);
      double y = center.dy + val * sin(angle);
      if (i == 0) statPath.moveTo(x, y);
      else statPath.lineTo(x, y);
    }
    statPath.close();

    canvas.drawPath(statPath, paintFill);
    canvas.drawPath(statPath, paintStroke);
    
    // Draw Glow
    canvas.drawPath(statPath, Paint()..color = color.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)..style = PaintingStyle.stroke..strokeWidth = 4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}