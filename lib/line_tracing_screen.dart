import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'models.dart';

// ── Line Pattern Enum ─────────────────────────────────────────────────

enum LinePatternType {
  straightDots,
  diagonalSlant,
  bouncingWaves,
  gentleWave,
  oceanWave,
  zigZag,
  loopDeLoop,
  swirls,
  castleStep,
  hillArches;

  String get id => name;

  String get fallbackTitle {
    switch (this) {
      case LinePatternType.straightDots:   return 'Ant March (Straight Line)';
      case LinePatternType.diagonalSlant:  return 'Lightning Slant';
      case LinePatternType.bouncingWaves:  return 'Bouncing Hops';
      case LinePatternType.gentleWave:     return 'Gentle Waves';
      case LinePatternType.oceanWave:      return 'Ocean Crests';
      case LinePatternType.zigZag:         return 'Zig-Zag Road';
      case LinePatternType.loopDeLoop:     return 'Loop de Loop';
      case LinePatternType.swirls:         return 'Whirlpool Swirls';
      case LinePatternType.castleStep:     return 'Castle Steps';
      case LinePatternType.hillArches:     return 'Bouncing Hills';
    }
  }

  String localizedTitle(String languageId) {
    const map = <String, Map<LinePatternType, String>>{
      'hi': {
        LinePatternType.straightDots:  'चींटी की चाल (सीधी रेखा)',
        LinePatternType.diagonalSlant: 'बिजली की तिरछी रेखा',
        LinePatternType.bouncingWaves: 'उछलती लहरें',
        LinePatternType.gentleWave:    'हल्की लहरें',
        LinePatternType.oceanWave:     'समुद्री लहरें',
        LinePatternType.zigZag:        'टेढ़ी-मेढ़ी सड़क',
        LinePatternType.loopDeLoop:    'गोल-गोल छल्ले',
        LinePatternType.swirls:        'भंवर चक्कर',
        LinePatternType.castleStep:    'किले की सीढ़ियाँ',
        LinePatternType.hillArches:    'पहाड़ी मोड़',
      },
      'te': {
        LinePatternType.straightDots:  'చీమల నడక (సరళ రేఖ)',
        LinePatternType.diagonalSlant: 'మెరుపు గీత',
        LinePatternType.bouncingWaves: 'ఎగిరే అలలు',
        LinePatternType.gentleWave:    'మృదువైన అలలు',
        LinePatternType.oceanWave:     'సముద్రపు కెరటాలు',
        LinePatternType.zigZag:        'వంకర టింకర దారి',
        LinePatternType.loopDeLoop:    'చుట్లు ముట్లు',
        LinePatternType.swirls:        'సుడిగుండం తిరుగుడు',
        LinePatternType.castleStep:    'కోట మెట్లు',
        LinePatternType.hillArches:    'కొండ వంపులు',
      },
      'ta': {
        LinePatternType.straightDots:  'எறும்பு நடை (நேர்கோடு)',
        LinePatternType.diagonalSlant: 'மின்னல் கோடு',
        LinePatternType.bouncingWaves: 'துள்ளும் அலைகள்',
        LinePatternType.gentleWave:    'மென்மையான அலைகள்',
        LinePatternType.oceanWave:     'கடல் அலைகள்',
        LinePatternType.zigZag:        'வளைந்து நெளிந்த பாதை',
        LinePatternType.loopDeLoop:    'சுழல் வளையங்கள்',
        LinePatternType.swirls:        'சுழல் காற்று',
        LinePatternType.castleStep:    'கோட்டைப் படிகள்',
        LinePatternType.hillArches:    'மலை வளைவுகள்',
      },
      'gu': {
        LinePatternType.straightDots:  'કીડીની ચાલ (સીધી રેખા)',
        LinePatternType.diagonalSlant: 'વીજળી રેખા',
        LinePatternType.bouncingWaves: 'કૂદતા મોજાં',
        LinePatternType.gentleWave:    'ધીમા મોજાં',
        LinePatternType.oceanWave:     'દરિયાઈ મોજાં',
        LinePatternType.zigZag:        'વાંકોચૂંકો રસ્તો',
        LinePatternType.loopDeLoop:    'ગોળ કડીઓ',
        LinePatternType.swirls:        'ચક્કર ભમરી',
        LinePatternType.castleStep:    'કિલ્લાના પગથિયાં',
        LinePatternType.hillArches:    'ટેકરીની કમાનો',
      },
      'mr': {
        LinePatternType.straightDots:  'मुंगी चाल (सरळ रेषा)',
        LinePatternType.diagonalSlant: 'विजेची तिरपी रेषा',
        LinePatternType.bouncingWaves: 'उड्या मारणाऱ्या लाटा',
        LinePatternType.gentleWave:    'संथ लाटा',
        LinePatternType.oceanWave:     'सागरी लाटा',
        LinePatternType.zigZag:        'वळणावळणाचा रस्ता',
        LinePatternType.loopDeLoop:    'गोल गोल फेरे',
        LinePatternType.swirls:        'भोवऱ्याचे वळण',
        LinePatternType.castleStep:    'किल्ल्याच्या पायऱ्या',
        LinePatternType.hillArches:    'टेकडीच्या कमानी',
      },
      'ur': {
        LinePatternType.straightDots:  'چیونٹی کی چال (سیدھی لکیر)',
        LinePatternType.diagonalSlant: 'بجلی کی لکیر',
        LinePatternType.bouncingWaves: 'اچھلتی لہریں',
        LinePatternType.gentleWave:    'ہلکی لہریں',
        LinePatternType.oceanWave:     'سمندری لہریں',
        LinePatternType.zigZag:        'ٹیڑھی میڑھی سڑک',
        LinePatternType.loopDeLoop:    'گول گول چھلے',
        LinePatternType.swirls:        'بھنور چکر',
        LinePatternType.castleStep:    'قلعے کی سیڑھیاں',
        LinePatternType.hillArches:    'پہاڑی موڑ',
      },
      'ml': {
        LinePatternType.straightDots:  'ഉറുമ്പ് നടത്തം (നേർരേഖ)',
        LinePatternType.diagonalSlant: 'മിന്നൽ വര',
        LinePatternType.bouncingWaves: 'തുള്ളിച്ചാടും തിരകൾ',
        LinePatternType.gentleWave:    'ശാന്തമായ തിരകൾ',
        LinePatternType.oceanWave:     'കടൽത്തിരകൾ',
        LinePatternType.zigZag:        'വളഞ്ഞുപുളഞ്ഞ വഴി',
        LinePatternType.loopDeLoop:    'വട്ടച്ചുഴികൾ',
        LinePatternType.swirls:        'ചുഴലികൾ',
        LinePatternType.castleStep:    'കോട്ടപ്പടികൾ',
        LinePatternType.hillArches:    'കുന്നിൻ വളവുകൾ',
      },
      'kn': {
        LinePatternType.straightDots:  'ಇರುವೆ ನಡಿಗೆ (ಸರಳ ರೇಖೆ)',
        LinePatternType.diagonalSlant: 'ಮಿಂಚಿನ ರೇಖೆ',
        LinePatternType.bouncingWaves: 'ಜಿಗಿಯುವ ಅಲೆಗಳು',
        LinePatternType.gentleWave:    'ಮೃದು ಅಲೆಗಳು',
        LinePatternType.oceanWave:     'ಸಮುದ್ರ ಅಲೆಗಳು',
        LinePatternType.zigZag:        'ಡೊಂಕು ರಸ್ತೆ',
        LinePatternType.loopDeLoop:    'ಸುತ್ತುಬಳಸು ರಿಂಗ್‌ಗಳು',
        LinePatternType.swirls:        'ಸುಳಿಯ ತಿರುವುಗಳು',
        LinePatternType.castleStep:    'ಕೋಟೆಯ ಮೆಟ್ಟಿಲುಗಳು',
        LinePatternType.hillArches:    'ಬೆಟ್ಟದ ತಿರುವುಗಳು',
      },
      'es': {
        LinePatternType.straightDots:  'Paso de hormiga (Línea recta)',
        LinePatternType.diagonalSlant: 'Línea de rayo',
        LinePatternType.bouncingWaves: 'Olas saltarinas',
        LinePatternType.gentleWave:    'Olas suaves',
        LinePatternType.oceanWave:     'Olas del mar',
        LinePatternType.zigZag:        'Camino en zigzag',
        LinePatternType.loopDeLoop:    'Bucles divertidos',
        LinePatternType.swirls:        'Remolinos',
        LinePatternType.castleStep:    'Pasos de castillo',
        LinePatternType.hillArches:    'Colinas saltarinas',
      },
      'de': {
        LinePatternType.straightDots:  'Ameisenmarsch (Gerade Linie)',
        LinePatternType.diagonalSlant: 'Blitzlinie',
        LinePatternType.bouncingWaves: 'Hüpfende Wellen',
        LinePatternType.gentleWave:    'Sanfte Wellen',
        LinePatternType.oceanWave:     'Meereswellen',
        LinePatternType.zigZag:        'Zickzack-Weg',
        LinePatternType.loopDeLoop:    'Looping-Schleifen',
        LinePatternType.swirls:        'Wirbel',
        LinePatternType.castleStep:    'Burg-Stufen',
        LinePatternType.hillArches:    'Hügelbögen',
      },
      'fr': {
        LinePatternType.straightDots:  'Marche des fourmis (Ligne droite)',
        LinePatternType.diagonalSlant: 'Ligne éclair',
        LinePatternType.bouncingWaves: 'Vagues bondissantes',
        LinePatternType.gentleWave:    'Vagues douces',
        LinePatternType.oceanWave:     'Vagues de l’océan',
        LinePatternType.zigZag:        'Route en zigzag',
        LinePatternType.loopDeLoop:    'Boucles joyeuses',
        LinePatternType.swirls:        'Tourbillons',
        LinePatternType.castleStep:    'Marches du château',
        LinePatternType.hillArches:    'Petites collines',
      },
      'pt': {
        LinePatternType.straightDots:  'Marcha da formiga (Linha reta)',
        LinePatternType.diagonalSlant: 'Linha de raio',
        LinePatternType.bouncingWaves: 'Ondas saltitantes',
        LinePatternType.gentleWave:    'Ondas suaves',
        LinePatternType.oceanWave:     'Ondas do mar',
        LinePatternType.zigZag:        'Caminho em ziguezague',
        LinePatternType.loopDeLoop:    'Laços divertidos',
        LinePatternType.swirls:        'Redemoinhos',
        LinePatternType.castleStep:    'Degraus do castelo',
        LinePatternType.hillArches:    'Colinas onduladas',
      },
      'ja': {
        LinePatternType.straightDots:  'ありさんのこうしん（まっすぐなせん）',
        LinePatternType.diagonalSlant: 'いなずまのせん',
        LinePatternType.bouncingWaves: 'ぴょんぴょんなみ',
        LinePatternType.gentleWave:    'ゆらゆらなみ',
        LinePatternType.oceanWave:     'うみのなみ',
        LinePatternType.zigZag:        'ジグザグみち',
        LinePatternType.loopDeLoop:    'くるくるループ',
        LinePatternType.swirls:        'うずまき',
        LinePatternType.castleStep:    'おしろのだんさ',
        LinePatternType.hillArches:    'おやまのアーチ',
      },
      'zh': {
        LinePatternType.straightDots:  '小蚂蚁走直线',
        LinePatternType.diagonalSlant: '闪电斜线',
        LinePatternType.bouncingWaves: '跳跃波浪',
        LinePatternType.gentleWave:    '轻柔波浪',
        LinePatternType.oceanWave:     '海洋海浪',
        LinePatternType.zigZag:        '之字形弯路',
        LinePatternType.loopDeLoop:    '旋转圆圈',
        LinePatternType.swirls:        '旋涡转转',
        LinePatternType.castleStep:    '城堡台阶',
        LinePatternType.hillArches:    '起伏山丘',
      },
    };

    return map[languageId]?[this] ?? fallbackTitle;
  }

  String get startEmoji {
    switch (this) {
      case LinePatternType.straightDots:   return '🐜';
      case LinePatternType.diagonalSlant:  return '⚡';
      case LinePatternType.bouncingWaves:  return '🦘';
      case LinePatternType.gentleWave:     return '🐙';
      case LinePatternType.oceanWave:      return '🐬';
      case LinePatternType.zigZag:         return '🐢';
      case LinePatternType.loopDeLoop:     return '⭐';
      case LinePatternType.swirls:         return '🐳';
      case LinePatternType.castleStep:     return '🦞';
      case LinePatternType.hillArches:     return '🦭';
    }
  }

  String get endEmoji {
    switch (this) {
      case LinePatternType.straightDots:   return '🍃';
      case LinePatternType.diagonalSlant:  return '🌟';
      case LinePatternType.bouncingWaves:  return '🏁';
      case LinePatternType.gentleWave:     return '🐚';
      case LinePatternType.oceanWave:      return '🪸';
      case LinePatternType.zigZag:         return '🏁';
      case LinePatternType.loopDeLoop:     return '🌺';
      case LinePatternType.swirls:         return '🌊';
      case LinePatternType.castleStep:     return '🏰';
      case LinePatternType.hillArches:     return '🌴';
    }
  }

  Color get color {
    switch (this) {
      case LinePatternType.straightDots:   return const Color(0xFF0284C7);
      case LinePatternType.diagonalSlant:  return const Color(0xFFF59E0B);
      case LinePatternType.bouncingWaves:  return const Color(0xFF10B981);
      case LinePatternType.gentleWave:     return const Color(0xFF2563EB);
      case LinePatternType.oceanWave:      return const Color(0xFF0891B2);
      case LinePatternType.zigZag:         return const Color(0xFFD97706);
      case LinePatternType.loopDeLoop:     return const Color(0xFFEC4899);
      case LinePatternType.swirls:         return const Color(0xFF7C3AED);
      case LinePatternType.castleStep:     return const Color(0xFFDC2626);
      case LinePatternType.hillArches:     return const Color(0xFF059669);
    }
  }
}

// ── Screen ────────────────────────────────────────────────────────────

class LineTracingScreen extends StatefulWidget {
  const LineTracingScreen({super.key});

  @override
  State<LineTracingScreen> createState() => _LineTracingScreenState();
}

class _LineTracingScreenState extends State<LineTracingScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Offset?> _userStroke = [];
  bool _isCompleted = false;

  late AnimationController _animController;
  late Animation<double> _bounceAnim;

  final List<_ConfettiParticle> _confetti = [];
  final _rnd = math.Random();

  LinePatternType get _currentType => LinePatternType.values[_currentIndex];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _resetCanvas();
      });
      _speakCurrent();
    }
  }

  void _next() {
    if (_currentIndex < LinePatternType.values.length - 1) {
      setState(() {
        _currentIndex++;
        _resetCanvas();
      });
      _speakCurrent();
    }
  }

  void _resetCanvas() {
    _userStroke.clear();
    _isCompleted = false;
    _confetti.clear();
  }

  void _speakCurrent() {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final text = _currentType.localizedTitle(lang.id);
    context.read<TTSProvider>().speak(text, lang.speechCode);
  }

  void _checkCompletion(Offset localPos, double canvasWidth) {
    if (_isCompleted) return;
    if (localPos.dx >= canvasWidth * 0.88) {
      setState(() => _isCompleted = true);
      final lang = context.read<LanguageProvider>().currentLanguage;
      final cheer = _localizedCheer(lang.id);
      context.read<TTSProvider>().speak(cheer, lang.speechCode);
      _spawnConfetti(canvasWidth);
    }
  }

  String _localizedCheer(String langId) {
    switch (langId) {
      case 'hi': return 'शाबाश! बहुत अच्छा!';
      case 'te': return 'చాలా బాగుంది! శభాష్!';
      case 'ta': return 'அருமை! மிக நன்று!';
      case 'gu': return 'ખૂબ સરસ! શાબાશ!';
      case 'mr': return 'खूप छान! शाब्बास!';
      case 'ur': return 'بہت خوب! شاباش!';
      case 'ml': return 'വളരെ നന്നായി!';
      case 'kn': return 'ತುಂಬಾ ಚೆನ್ನಾಗಿದೆ!';
      case 'es': return '¡Muy bien! ¡Excelente trabajo!';
      case 'de': return 'Super gemacht! Toll!';
      case 'fr': return 'Bravo! Très bon travail!';
      case 'pt': return 'Muito bem! Parabéns!';
      case 'ja': return 'じょうずにできたね！すごい！';
      case 'zh': return '太棒了！做得很棒！';
      default:   return 'Yay! Great job!';
    }
  }

  void _spawnConfetti(double canvasWidth) {
    _confetti.clear();
    const colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];
    for (int i = 0; i < 36; i++) {
      final angle = _rnd.nextDouble() * 2 * math.pi;
      final speed = 40.0 + _rnd.nextDouble() * 120.0;
      _confetti.add(_ConfettiParticle(
        x: canvasWidth * 0.85,
        y: 100,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        color: colors[_rnd.nextInt(colors.length)],
        size: 7 + _rnd.nextDouble() * 8,
      ));
    }
    setState(() {});
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _confetti.clear());
    });
  }

  @override
  Widget build(BuildContext context) {
    final pattern = _currentType;
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Category.lines.localizedTitle(lang.id),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 26),
            tooltip: 'Clear Stroke',
            onPressed: () => setState(_resetCanvas),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 24),
            tooltip: 'Speak',
            onPressed: _speakCurrent,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDF8), Color(0xFFF0FDF4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: OrientationBuilder(builder: (ctx, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            return Column(
              children: [
                _patternPickerRail(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 32 : 16,
                      vertical: 10,
                    ),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final cWidth = constraints.maxWidth;
                      final cHeight = constraints.maxHeight;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isCompleted
                                ? Colors.green
                                : pattern.color.withOpacity(0.35),
                            width: _isCompleted ? 3.5 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: pattern.color.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: [
                              // Interactive Start Emoji with bounce
                              AnimatedBuilder(
                                animation: _bounceAnim,
                                builder: (_, __) => Positioned(
                                  left: 14,
                                  top: (cHeight / 2 - 28) + _bounceAnim.value,
                                  child: GestureDetector(
                                    onTap: _speakCurrent,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: pattern.color.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        pattern.startEmoji,
                                        style: const TextStyle(fontSize: 34),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Interactive Target End Emoji with pulse
                              Positioned(
                                right: 14,
                                top: (cHeight / 2 - 28),
                                child: AnimatedScale(
                                  scale: _isCompleted ? 1.3 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _isCompleted
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      pattern.endEmoji,
                                      style: const TextStyle(fontSize: 34),
                                    ),
                                  ),
                                ),
                              ),

                              // Dotted Reference Path
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 72),
                                  child: CustomPaint(
                                    painter: _DottedPatternPainter(pattern),
                                  ),
                                ),
                              ),

                              // Child's Live Finger Tracing Layer
                              Positioned.fill(
                                child: GestureDetector(
                                  onPanStart: (d) {
                                    setState(() => _userStroke.add(d.localPosition));
                                    _checkCompletion(d.localPosition, cWidth);
                                  },
                                  onPanUpdate: (d) {
                                    setState(() => _userStroke.add(d.localPosition));
                                    _checkCompletion(d.localPosition, cWidth);
                                  },
                                  onPanEnd: (_) => setState(() => _userStroke.add(null)),
                                  child: CustomPaint(
                                    painter: _UserTracePainter(
                                      points: _userStroke,
                                      strokeColor: _isCompleted
                                          ? Colors.green
                                          : pattern.color,
                                    ),
                                  ),
                                ),
                              ),

                              // Confetti particles
                              if (_confetti.isNotEmpty)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _ConfettiPainter(_confetti),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Bottom Navigation controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _currentIndex > 0 ? _prev : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        label: const Text('Prev'),
                      ),
                      const Spacer(),
                      Text(
                        '${_currentIndex + 1} / ${LinePatternType.values.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _currentIndex < LinePatternType.values.length - 1
                            ? _next
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pattern.color,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _patternPickerRail() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: LinePatternType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final pat = LinePatternType.values[i];
          final sel = i == _currentIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = i;
                _resetCanvas();
              });
              _speakCurrent();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? pat.color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? pat.color : Colors.grey.shade300,
                  width: sel ? 2.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: sel
                        ? pat.color.withOpacity(0.35)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Text(pat.startEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: sel ? Colors.white : Colors.black45,
                  ),
                  const SizedBox(width: 4),
                  Text(pat.endEmoji, style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Background Dotted Line Painter ────────────────────────────────────

class _DottedPatternPainter extends CustomPainter {
  final LinePatternType pattern;
  const _DottedPatternPainter(this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final midY = size.height / 2;

    // Soft translucent background track
    final bgPaint = Paint()
      ..color = pattern.color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    if (pattern == LinePatternType.straightDots) {
      canvas.drawLine(Offset(0, midY), Offset(w, midY), bgPaint);

      final dotPaint = Paint()
        ..color = pattern.color
        ..style = PaintingStyle.fill;

      const spacing = 12.0;
      const dotRadius = 3.5;
      for (double x = 0; x <= w; x += spacing) {
        canvas.drawCircle(Offset(x, midY), dotRadius, dotPaint);
      }
      return;
    }

    final path = _generatePath(size);
    canvas.drawPath(path, bgPaint);

    final dashedPath = _dashPath(path, dash: 9, gap: 8);
    final strokePaint = Paint()
      ..color = pattern.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(dashedPath, strokePaint);
  }

  Path _generatePath(Size size) {
    final p = Path();
    final w = size.width;
    final h = size.height;
    final midY = h / 2;

    switch (pattern) {
      case LinePatternType.straightDots:
        p.moveTo(0, midY);
        p.lineTo(w, midY);
        break;

      case LinePatternType.diagonalSlant:
        p.moveTo(0, midY + 40);
        final segs = 5;
        final dx = w / segs;
        for (int i = 0; i < segs; i++) {
          final x = i * dx;
          p.lineTo(x + dx * 0.7, midY - 35);
          p.lineTo(x + dx, midY + 25);
        }
        break;

      case LinePatternType.bouncingWaves:
        p.moveTo(0, midY + 30);
        final hops = 5;
        final span = w / hops;
        for (int i = 0; i < hops; i++) {
          p.relativeArcToPoint(
            Offset(span, 0),
            radius: Radius.circular(span / 1.8),
            clockwise: false,
          );
        }
        break;

      case LinePatternType.gentleWave:
        p.moveTo(0, midY);
        const cycles = 4;
        final step = w / cycles;
        for (int i = 0; i < cycles; i++) {
          final sx = i * step;
          p.cubicTo(
            sx + step * 0.25, midY - 35,
            sx + step * 0.75, midY + 35,
            sx + step, midY,
          );
        }
        break;

      case LinePatternType.oceanWave:
        p.moveTo(0, midY + 20);
        const count = 4;
        final step = w / count;
        for (int i = 0; i < count; i++) {
          final sx = i * step;
          p.quadraticBezierTo(sx + step * 0.4, midY - 50, sx + step * 0.8, midY - 20);
          p.quadraticBezierTo(sx + step * 0.9, midY, sx + step, midY + 20);
        }
        break;

      case LinePatternType.zigZag:
        p.moveTo(0, midY);
        const teeth = 5;
        final toothW = w / (teeth * 2);
        for (int i = 0; i < teeth; i++) {
          p.lineTo(toothW * (i * 2 + 1), midY - 45);
          p.lineTo(toothW * (i * 2 + 2), midY + 45);
        }
        p.lineTo(w, midY);
        break;

      case LinePatternType.loopDeLoop:
        p.moveTo(0, midY);
        const loops = 5;
        final span = w / loops;
        for (int i = 0; i < loops; i++) {
          final x = i * span;
          p.cubicTo(x + span * 0.6, midY + 50, x + span * 0.9, midY - 55, x + span * 0.5, midY - 55);
          p.cubicTo(x + span * 0.2, midY - 55, x + span * 0.4, midY + 40, x + span, midY);
        }
        break;

      case LinePatternType.swirls:
        p.moveTo(0, midY);
        const swirls = 4;
        final seg = w / swirls;
        for (int i = 0; i < swirls; i++) {
          final startX = i * seg;
          p.arcToPoint(
            Offset(startX + seg * 0.7, midY),
            radius: Radius.circular(seg * 0.35),
            clockwise: true,
          );
          p.arcToPoint(
            Offset(startX + seg, midY),
            radius: Radius.circular(seg * 0.15),
            clockwise: false,
          );
        }
        break;

      case LinePatternType.castleStep:
        p.moveTo(0, midY + 25);
        const steps = 4;
        final unit = w / (steps * 4);
        for (int i = 0; i < steps; i++) {
          p.relativeLineTo(unit, 0);
          p.relativeLineTo(0, -50);
          p.relativeLineTo(unit * 2, 0);
          p.relativeLineTo(0, 50);
          p.relativeLineTo(unit, 0);
        }
        break;

      case LinePatternType.hillArches:
        p.moveTo(0, midY + 30);
        const hills = 4;
        final hSpan = w / hills;
        for (int i = 0; i < hills; i++) {
          p.relativeQuadraticBezierTo(hSpan / 2, -65, hSpan, 0);
        }
        break;
    }
    return p;
  }

  Path _dashPath(Path source, {required double dash, required double gap}) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dash, metric.length - distance);
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += dash + gap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DottedPatternPainter old) => old.pattern != pattern;
}

// ── Live Finger Drawing Stroke Painter ────────────────────────────────

class _UserTracePainter extends CustomPainter {
  final List<Offset?> points;
  final Color strokeColor;

  const _UserTracePainter({required this.points, required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 7.5;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(points[i]!, 3.75, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_UserTracePainter old) => true;
}

// ── Confetti Particle System ──────────────────────────────────────────

class _ConfettiParticle {
  double x, y, vx, vy, size;
  Color color;
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  const _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(
        Offset(p.x + p.vx * 0.25, p.y + p.vy * 0.25),
        p.size / 2,
        Paint()..color = p.color.withOpacity(0.85),
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}