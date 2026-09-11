import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// ── Note data ─────────────────────────────────────────────────────────

class _Note {
  final String solfege;
  final Color color;
  final double frequency;
  const _Note(this.solfege, this.color, this.frequency);
}

const _notes = [
  _Note('Do',  Color(0xFFE84545), 261.63),
  _Note('Re',  Color(0xFFFF8C00), 293.66),
  _Note('Mi',  Color(0xFFFFD700), 329.63),
  _Note('Fa',  Color(0xFF22A740), 349.23),
  _Note('Sol', Color(0xFF3B6CF4), 392.00),
  _Note('La',  Color(0xFF9B59B6), 440.00),
  _Note('Si',  Color(0xFFE91E8C), 493.88),
  _Note('Do²', Color(0xFFE84545), 523.25),
];

// ── Songs ─────────────────────────────────────────────────────────────

class _Song {
  final String title;
  final String emoji;
  final List<int> steps;
  final List<int> durations;
  const _Song({required this.title, required this.emoji,
    required this.steps, required this.durations});
}

const _songs = [
  _Song(
    title: 'Twinkle Twinkle', emoji: '⭐',
    steps:     [0,0,4,4,5,5,4, 3,3,2,2,1,1,0, 4,4,3,3,2,2,1, 4,4,3,3,2,2,1, 0,0,4,4,5,5,4, 3,3,2,2,1,1,0],
    durations: [400,400,400,400,400,400,800, 400,400,400,400,400,400,800, 400,400,400,400,400,400,800, 400,400,400,400,400,400,800, 400,400,400,400,400,400,800, 400,400,400,400,400,400,800],
  ),
  _Song(
    title: 'Los Pollitos Dicen',
    emoji: '🐥',
    steps: [
      // Los po-lli-tos di-cen:
      0, 1, 2, 3, 4, 4,
      // Pí-o, pí-o, pí-o,
      5, 5, 4, 4, 3, 3, 2,
      // Cuan-do tie-nen ham-bre,
      1, 1, 2, 2, 3, 3, 2,
      // Cuan-do tie-nen frí-o.
      1, 1, 2, 2, 1, 1, 0,
    ],
    durations: [
      // Los po-lli-tos di-cen:
      350, 350, 350, 350, 450, 700,
      // Pí-o, pí-o, pí-o,
      300, 300, 300, 300, 300, 300, 700,
      // Cuan-do tie-nen ham-bre,
      300, 300, 300, 300, 300, 300, 700,
      // Cuan-do tie-nen frí-o.
      300, 300, 300, 300, 300, 300, 800,
    ],
  ),
  _Song(
    title: 'Mary Had a Little Lamb', emoji: '🐑',
    steps:     [2,1,0,1,2,2,2, 1,1,1, 2,4,4, 2,1,0,1,2,2,2, 2,1,1,2,1,0],
    durations: [400,400,400,400,400,400,800, 400,400,800, 400,400,800, 400,400,400,400,400,400,400, 400,400,400,400,400,800],
  ),
  _Song(
    title: 'Happy Birthday', emoji: '🎂',
    steps:     [0,0,1,0,3,2, 0,0,1,0,4,3, 0,0,7,5,3,2,1, 6,6,5,3,4,3],
    durations: [300,300,600,600,600,1200, 300,300,600,600,600,1200, 300,300,600,600,600,600,1200, 300,300,600,600,600,1200],
  ),
  _Song(
    title: 'Wooden Horse',
    emoji: '🐴',
    steps: [
      // Lak-di ki kaa-thi, kaa-thi pe gho-da
      0, 1, 2,  4, 2, 1,  0, 1, 2,  4, 2, 1,
      // Gho-de ki dum pe jo maa-ra ha-thau-da
      0, 1, 2,  4, 2, 1,  0, 1, 2,  4, 4,
      // Dau-da dau-da dau-da gho-da dum u-tha ke dau-da
      5, 5,  5, 5,  4, 4, 3, 3,  2, 2, 1, 1,  0, 0,
    ],
    durations: [
      // Lak-di ki kaa-thi, kaa-thi pe gho-da
      300, 300, 300,  500, 300, 600,  300, 300, 300,  500, 300, 600,
      // Gho-de ki dum pe jo maa-ra ha-thau-da
      300, 300, 300,  500, 300, 600,  300, 300, 300,  500, 800,
      // Dau-da dau-da dau-da gho-da dum u-tha ke dau-da
      300, 300,  300, 300,  300, 300, 300, 300,  300, 300, 300, 300,  400, 800,
    ],
  ),
  _Song(
    title: 'Row Row Row Your Boat',
    emoji: '⛵',
    steps: [
      // Row, row, row your boat, gent-ly down the stream
      0, 0, 0, 1, 2,   2, 1, 2, 3, 4,
      // Mer-ri-ly, mer-ri-ly, mer-ri-ly, mer-ri-ly
      7, 7, 7,  4, 4, 4,  2, 2, 2,  0, 0, 0,
      // Life is but a dream
      4, 3, 2, 1, 0,
    ],
    durations: [
      500, 500, 400, 250, 600,   400, 250, 400, 250, 800,
      200, 200, 250,  200, 200, 250,  200, 200, 250,  200, 200, 250,
      400, 250, 400, 250, 900,
    ],
  ),
  _Song(
    title: 'Joyful Song',
    emoji: '🌸',
    steps: [
      // Ha-re Krish-na, Ha-re Krish-na
      2, 4, 5, 4,  2, 4, 5, 4,
      // Krish-na Krish-na, Ha-re Ha-re
      5, 7, 5, 4,  2, 4, 2, 0,
      // Ha-re Ra-ma, Ha-re Ra-ma
      2, 4, 5, 4,  2, 4, 5, 4,
      // Ra-ma Ra-ma, Ha-re Ha-re
      5, 7, 5, 4,  2, 4, 2, 0,
    ],
    durations: [
      350, 350, 450, 750,  350, 350, 450, 750,
      350, 350, 450, 750,  350, 350, 450, 900,
      350, 350, 450, 750,  350, 350, 450, 750,
      350, 350, 450, 750,  350, 350, 450, 900,
    ],
  ),
  _Song(
    title: 'Quiet Prayer',
    emoji: '🙏',
    steps: [
      // Om bhur bhu-vah svah
      0, 2, 4, 4, 4,
      // Tat sa-vi-tur va-re-nyam
      4, 4, 4, 4, 5, 4, 2,
      // Bhar-go de-vas-ya dhi-ma-hi
      2, 4, 4, 4, 4, 5, 4, 2,
      // Dhi-yo yo nah pra-co-da-yat
      2, 4, 4, 2, 1, 2, 1, 0,
    ],
    durations: [
      700, 400, 400, 400, 800,
      400, 400, 400, 400, 450, 450, 850,
      400, 400, 400, 400, 400, 450, 450, 850,
      400, 400, 400, 400, 400, 400, 400, 950,
    ],
  ),
  _Song(
    title: 'La Vaca Lola',
    emoji: '🐄',
    steps: [
      // La va-ca Lo-la
      4, 4, 2, 0,
      // La va-ca Lo-la
      4, 4, 2, 0,
      // Tie-ne ca-be-za y tie-ne co-la
      1, 1, 1, 1, 2, 3, 4, 2,
      // Tie-ne ca-be-za y tie-ne co-la
      1, 1, 1, 1, 2, 3, 4, 2,
      // Y ha-ce muuu!
      3, 2, 1, 0,
    ],
    durations: [
      // La va-ca Lo-la
      350, 350, 400, 700,
      // La va-ca Lo-la
      350, 350, 400, 700,
      // Tie-ne ca-be-za y tie-ne co-la
      300, 300, 300, 300, 350, 350, 400, 700,
      // Tie-ne ca-be-za y tie-ne co-la
      300, 300, 300, 300, 350, 350, 400, 700,
      // Y ha-ce muuu!
      350, 350, 450, 1100,
    ],
  ),
  _Song(
    title: "Brahms' Lullaby",
    emoji: '🌙',
    steps: [
      // Lul-la-by and good night, in the sky stars are bright
      2, 2, 4,   2, 2, 4,   2, 4, 7, 6, 5, 5, 4,
      // Close your eyes now and sleep, may your slum-bers be deep
      1, 2, 3,   1, 2, 3,   1, 3, 6, 5, 4, 3, 2, 1, 0,
    ],
    durations: [
      300, 300, 600,   300, 300, 600,   300, 300, 400, 300, 300, 300, 700,
      300, 300, 600,   300, 300, 600,   300, 300, 400, 300, 300, 300, 300, 300, 800,
    ],
  ),
];

// ── Tone generator ────────────────────────────────────────────────────

Uint8List _generateWav(double frequency,
    {int sampleRate = 44100, int durationMs = 600}) {
  final numSamples = (sampleRate * durationMs / 1000).round();
  final data = Int16List(numSamples);
  final fadeIn  = 0.01;
  final fadeOut = 0.1;
  final totalSec = durationMs / 1000.0;

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    double env = 1.0;
    if (t < fadeIn) env = t / fadeIn;
    if (t > totalSec - fadeOut) env = (totalSec - t) / fadeOut;
    env = env.clamp(0.0, 1.0);
    data[i] = (math.sin(2 * math.pi * frequency * t) * 28000 * env)
        .round().clamp(-32768, 32767);
  }

  final byteData = ByteData(44 + numSamples * 2);
  byteData.setUint8(0,  0x52); byteData.setUint8(1,  0x49);
  byteData.setUint8(2,  0x46); byteData.setUint8(3,  0x46);
  byteData.setUint32(4, 36 + numSamples * 2, Endian.little);
  byteData.setUint8(8,  0x57); byteData.setUint8(9,  0x41);
  byteData.setUint8(10, 0x56); byteData.setUint8(11, 0x45);
  byteData.setUint8(12, 0x66); byteData.setUint8(13, 0x6D);
  byteData.setUint8(14, 0x74); byteData.setUint8(15, 0x20);
  byteData.setUint32(16, 16, Endian.little);
  byteData.setUint16(20, 1, Endian.little);
  byteData.setUint16(22, 1, Endian.little);
  byteData.setUint32(24, sampleRate, Endian.little);
  byteData.setUint32(28, sampleRate * 2, Endian.little);
  byteData.setUint16(32, 2, Endian.little);
  byteData.setUint16(34, 16, Endian.little);
  byteData.setUint8(36, 0x64); byteData.setUint8(37, 0x61);
  byteData.setUint8(38, 0x74); byteData.setUint8(39, 0x61);
  byteData.setUint32(40, numSamples * 2, Endian.little);
  for (int i = 0; i < numSamples; i++) {
    byteData.setInt16(44 + i * 2, data[i], Endian.little);
  }
  return byteData.buffer.asUint8List();
}

// ── Screen ────────────────────────────────────────────────────────────

class XylophoneScreen extends StatefulWidget {
  const XylophoneScreen({super.key});
  @override
  State<XylophoneScreen> createState() => _XylophoneScreenState();
}

class _XylophoneScreenState extends State<XylophoneScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  final List<AnimationController> _barControllers = [];
  final List<Animation<double>> _barAnims = [];

  String _mode = 'play';
  int _selectedSong = 0;
  bool _isPlaying = false;
  int? _litBar;
  int _learnStep = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _notes.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
      );
      final anim = Tween<double>(begin: 1.0, end: 0.86).animate(
          CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
      ctrl.addStatusListener(
              (s) { if (s == AnimationStatus.completed) ctrl.reverse(); });
      _barControllers.add(ctrl);
      _barAnims.add(anim);
    }
  }

  @override
  void dispose() {
    for (final c in _barControllers) c.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Play note ─────────────────────────────────────────────────────

  Future<void> _playNote(int index, {int durationMs = 600}) async {
    if (!mounted) return;
    setState(() => _litBar = index);
    _barControllers[index].forward(from: 0);
    final wav = _generateWav(_notes[index].frequency, durationMs: durationMs);
    await _player.stop();
    await _player.play(BytesSource(wav));
    Future.delayed(Duration(milliseconds: durationMs), () {
      if (mounted && _litBar == index) setState(() => _litBar = null);
    });
  }

  // ── Play song ─────────────────────────────────────────────────────

  Future<void> _playSong() async {
    if (_isPlaying) {
      setState(() { _isPlaying = false; _litBar = null; _learnStep = 0; });
      return;
    }
    setState(() { _isPlaying = true; _learnStep = 0; });
    final song = _songs[_selectedSong];
    for (int i = 0; i < song.steps.length; i++) {
      if (!mounted || !_isPlaying) break;
      setState(() => _learnStep = i);
      final dur = song.durations[i];
      await _playNote(song.steps[i], durationMs: dur);
      await Future.delayed(Duration(milliseconds: dur + 80));
    }
    if (mounted) setState(() { _isPlaying = false; _litBar = null; _learnStep = 0; });
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Xylophone'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF9EC), Color(0xFFEFF8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: OrientationBuilder(builder: (_, orientation) {
            return orientation == Orientation.portrait
                ? _portraitLayout()
                : _landscapeLayout();
          }),
        ),
      ),
    );
  }

  // ── Portrait layout ───────────────────────────────────────────────

  Widget _portraitLayout() {
    return Column(
      children: [
        _modeToggle(),
        if (_mode == 'learn') ...[
          _songPicker(),
          _learnControls(),
        ],
        Expanded(child: _barsPortrait()),
      ],
    );
  }

  // ── Landscape layout ──────────────────────────────────────────────

  Widget _landscapeLayout() {
    return Row(
      children: [
        SizedBox(
          width: 260,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
              child: Column(
                children: [
                  _modeToggle(),
                  if (_mode == 'learn') ...[
                    const SizedBox(height: 12),
                    _songPicker(),
                    const SizedBox(height: 10),
                    _learnControls(isLandscape: true),
                  ],
                ],
              ),
            ),
          ),
        ),
        Expanded(child: _barsLandscape()),
      ],
    );
  }

  // ── Mode toggle ───────────────────────────────────────────────────

  Widget _modeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [                          // ← remove mainAxisSize: min
          Expanded(child: _modeBtn('play',  '🎵 Play')),
          Expanded(child: _modeBtn('learn', '🎓 Learn')),
        ],
      ),
    );
  }

  Widget _modeBtn(String mode, String label) {
    final on = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() {
        _mode = mode;
        _isPlaying = false;
        _litBar = null;
        _learnStep = 0;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 10),  // ← was 22, now 8
        alignment: Alignment.center,        // ← add this
        decoration: BoxDecoration(
          color: on ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: on
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
              : [],
        ),
        child: Text(label,
            textAlign: TextAlign.center,    // ← add this
            style: TextStyle(
                fontWeight: on ? FontWeight.bold : FontWeight.normal,
                fontSize: 13)),             // ← was 14, slightly smaller
      ),
    );
  }

  // ── Song picker ───────────────────────────────────────────────────

// ── Compact Icon Song Picker ──────────────────────────────────────

  Widget _songPicker() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _songs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final sel = i == _selectedSong;
          final song = _songs[i];
          return GestureDetector(
            onTap: () => setState(() {
              _selectedSong = i;
              _learnStep = 0;
              _isPlaying = false;
              _litBar = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? Colors.purple : Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: sel ? Colors.purple.shade700 : Colors.black12,
                  width: sel ? 2.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: sel
                        ? Colors.purple.withOpacity(0.35)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: sel ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                song.emoji,
                style: TextStyle(
                  fontSize: sel ? 24 : 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Learn controls (With Title & Action) ───────────────────────────

  Widget _learnControls({bool isLandscape = false}) {
    final song = _songs[_selectedSong];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Current selected song name banner
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Text(song.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      song.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (_isPlaying)
                    Text(
                      '${_learnStep + 1}/${song.steps.length}',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Play/Stop Button
          GestureDetector(
            onTap: _playSong,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPlaying
                      ? [Colors.red.shade600, Colors.red.shade800]
                      : [Colors.purple, Colors.blue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isPlaying ? 'Stop' : 'Play',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ── Portrait bars ─────────────────────────────────────────────────

  Widget _barsPortrait() {
    return LayoutBuilder(builder: (_, c) {
      final maxW = c.maxWidth * 0.94;
      final minW = maxW * 0.48;
      final barH = (c.maxHeight / _notes.length).clamp(36.0, 88.0);

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_notes.length, (i) {
          final w = maxW - (maxW - minW) * (i / (_notes.length - 1));
          return _barH(i, width: w, height: barH - 8);
        }),
      );
    });
  }

  // ── Landscape bars ────────────────────────────────────────────────

  Widget _barsLandscape() {
    return LayoutBuilder(builder: (_, c) {
      final maxH = c.maxHeight * 0.90;
      final minH = maxH * 0.45;
      // Subtract more to prevent overflow
      final barW = (c.maxWidth / _notes.length).clamp(32.0, 76.0) - 8; // ← was -4, now -8

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ← was center, now spaceEvenly
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_notes.length, (i) {
          final h = maxH - (maxH - minH) * (i / (_notes.length - 1));
          return _barV(i, width: barW, height: h);
        }),
      );
    });
  }

  // ── Horizontal bar ────────────────────────────────────────────────

  Widget _barH(int i, {required double width, required double height}) {
    final note = _notes[i];
    final isLit = _litBar == i;
    final song = _songs[_selectedSong];
    final isNext = _mode == 'learn' && !_isPlaying &&
        _learnStep < song.steps.length &&
        song.steps[_learnStep] == i;

    return GestureDetector(
      onTap: () => _playNote(i),
      child: ScaleTransition(
        scale: _barAnims[i],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLit
                  ? [Colors.white, note.color.withOpacity(0.4)]
                  : [note.color, note.color.withOpacity(0.72)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: note.color.withOpacity(isLit ? 0.8 : 0.3),
                blurRadius: isLit ? 20 : 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: isNext
                ? Border.all(color: Colors.white, width: 3)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Text(
                  note.solfege,
                  style: TextStyle(
                    color: isLit ? note.color : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: (height * 0.40).clamp(12, 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Vertical bar ──────────────────────────────────────────────────

  Widget _barV(int i, {required double width, required double height}) {
    final note = _notes[i];
    final isLit = _litBar == i;
    final song = _songs[_selectedSong];
    final isNext = _mode == 'learn' && !_isPlaying &&
        _learnStep < song.steps.length &&
        song.steps[_learnStep] == i;

    return GestureDetector(
      onTap: () => _playNote(i),
      child: ScaleTransition(
        scale: _barAnims[i],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLit
                  ? [Colors.white, note.color.withOpacity(0.4)]
                  : [note.color, note.color.withOpacity(0.72)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(width / 2),
            boxShadow: [
              BoxShadow(
                color: note.color.withOpacity(isLit ? 0.8 : 0.3),
                blurRadius: isLit ? 20 : 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: isNext
                ? Border.all(color: Colors.white, width: 3)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                note.solfege,
                style: TextStyle(
                  color: isLit ? note.color : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: (width * 0.28).clamp(10, 18),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}