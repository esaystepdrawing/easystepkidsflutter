import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "#E53935" or "E53935" -> Color
Color cbnHex(String hex) {
  var s = hex.replaceAll('#', '').trim();
  if (s.length == 6) s = 'FF$s';
  return Color(int.tryParse(s, radix: 16) ?? 0xFF9E9E9E);
}

double _num(dynamic v, [double fallback = 0]) => v is num ? v.toDouble() : fallback;

// MARK: - Page model (matches the page JSON files)

class CbnPaletteColor {
  final int number;
  final String name;
  final String hex;

  CbnPaletteColor({required this.number, required this.name, required this.hex});

  Color get color => cbnHex(hex);

  factory CbnPaletteColor.fromJson(Map<String, dynamic> j) => CbnPaletteColor(
        number: (j['number'] as num).toInt(),
        name: j['name'] as String,
        hex: j['hex'] as String,
      );
}

class CbnRegion {
  final String id;
  final int number;
  final Offset label;
  final double labelSize;

  /// Page coordinates (viewBox units).
  final Path path;

  CbnRegion({
    required this.id,
    required this.number,
    required this.label,
    required this.labelSize,
    required this.path,
  });

  factory CbnRegion.fromJson(Map<String, dynamic> j) {
    final label = (j['label'] as List?) ?? const [0, 0];
    return CbnRegion(
      id: j['id'] as String,
      number: (j['number'] as num).toInt(),
      label: Offset(_num(label[0]), _num(label[1])),
      labelSize: _num(j['labelSize'], 60),
      path: cbnParsePath(j['d'] as String),
    );
  }
}

class CbnDetail {
  final String? fill;
  final double? strokeWidth;
  final Path path;

  CbnDetail({this.fill, this.strokeWidth, required this.path});

  factory CbnDetail.fromJson(Map<String, dynamic> j) => CbnDetail(
        fill: j['fill'] as String?,
        strokeWidth: j['strokeWidth'] is num ? (j['strokeWidth'] as num).toDouble() : null,
        path: cbnParsePath(j['d'] as String),
      );
}

class CbnPage {
  final String id;
  final String subject;
  final String title;
  final String category;
  final int level;
  final Rect viewBox;
  final double strokeWidth;
  final bool showColorHints;
  final List<CbnPaletteColor> palette;
  final List<CbnRegion> regions;
  final List<CbnDetail> details;

  CbnPage({
    required this.id,
    required this.subject,
    required this.title,
    required this.category,
    required this.level,
    required this.viewBox,
    required this.strokeWidth,
    required this.showColorHints,
    required this.palette,
    required this.regions,
    required this.details,
  });

  factory CbnPage.fromJson(Map<String, dynamic> j) {
    final vb = (j['viewBox'] as List?) ?? const [0, 0, 1024, 1024];
    return CbnPage(
      id: j['id'] as String,
      subject: j['subject'] as String,
      title: j['title'] as String,
      category: j['category'] as String,
      level: (j['level'] as num).toInt(),
      viewBox: Rect.fromLTWH(_num(vb[0]), _num(vb[1]), _num(vb[2], 1024), _num(vb[3], 1024)),
      strokeWidth: _num(j['strokeWidth'], 14),
      showColorHints: j['showColorHints'] == true,
      palette: ((j['palette'] as List?) ?? const [])
          .map((e) => CbnPaletteColor.fromJson(e as Map<String, dynamic>))
          .toList(),
      regions: ((j['regions'] as List?) ?? const [])
          .map((e) => CbnRegion.fromJson(e as Map<String, dynamic>))
          .toList(),
      details: ((j['details'] as List?) ?? const [])
          .map((e) => CbnDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Color colorFor(int number) {
    for (final p in palette) {
      if (p.number == number) return p.color;
    }
    return Colors.grey;
  }

  String colorNameFor(int number) {
    for (final p in palette) {
      if (p.number == number) return p.name;
    }
    return '';
  }

  /// The area the drawing actually covers, so a picture can fill its tile.
  Rect get contentBounds {
    Rect? rect;
    for (final r in regions) {
      final b = r.path.getBounds();
      rect = rect == null ? b : rect.expandToInclude(b);
    }
    for (final d in details) {
      final b = d.path.getBounds();
      rect = rect == null ? b : rect.expandToInclude(b);
    }
    return (rect ?? viewBox).inflate(strokeWidth);
  }
}

/// Scale and offset that fit `source` (page units) centered inside `size`.
class CbnFit {
  final double scale;
  final Offset offset;

  const CbnFit(this.scale, this.offset);

  factory CbnFit.of(Rect source, Size size) {
    final s = math.min(size.width / source.width, size.height / source.height);
    return CbnFit(
      s,
      Offset(
        (size.width - source.width * s) / 2 - source.left * s,
        (size.height - source.height * s) / 2 - source.top * s,
      ),
    );
  }

  Offset toPage(Offset screen) => (screen - offset) / scale;

  Offset toScreen(Offset page) => page * scale + offset;
}

// MARK: - Path parser (absolute M, L, C, Q, Z with space-separated numbers)

Path cbnParsePath(String d) {
  final path = Path();
  final t = d.trim().split(RegExp(r'[\s,]+'));
  double n(int i) => i < t.length ? (double.tryParse(t[i]) ?? 0) : 0;
  var i = 0;
  while (i < t.length) {
    switch (t[i]) {
      case 'M':
        path.moveTo(n(i + 1), n(i + 2));
        i += 3;
        break;
      case 'L':
        path.lineTo(n(i + 1), n(i + 2));
        i += 3;
        break;
      case 'C':
        path.cubicTo(n(i + 1), n(i + 2), n(i + 3), n(i + 4), n(i + 5), n(i + 6));
        i += 7;
        break;
      case 'Q':
        path.quadraticBezierTo(n(i + 1), n(i + 2), n(i + 3), n(i + 4));
        i += 5;
        break;
      case 'Z':
        path.close();
        i += 1;
        break;
      default:
        i += 1;
    }
  }
  return path;
}

// MARK: - Drawing a page

/// Draws the page in page coordinates (call after scaling the canvas).
/// Regions in `filled` (or all regions when `allColored`) get their color;
/// `shadow` paints everything as one dark silhouette.
void cbnPaintPage(
  Canvas canvas,
  CbnPage page, {
  Set<String> filled = const {},
  bool allColored = false,
  bool shadow = false,
}) {
  const ink = Color(0xFF222222);
  final fillPaint = Paint()..style = PaintingStyle.fill;
  final strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = page.strokeWidth
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = shadow ? ink : Colors.black;

  for (final r in page.regions) {
    if (shadow) {
      fillPaint.color = ink;
    } else if (allColored || filled.contains(r.id)) {
      fillPaint.color = page.colorFor(r.number);
    } else {
      fillPaint.color = Colors.white;
    }
    canvas.drawPath(r.path, fillPaint);
    canvas.drawPath(r.path, strokePaint);
  }

  for (final d in page.details) {
    final fill = d.fill;
    if (fill != null && fill != 'none') {
      fillPaint.color = shadow ? ink : cbnHex(fill);
      canvas.drawPath(d.path, fillPaint);
    }
    final w = d.strokeWidth ?? page.strokeWidth;
    if (w > 0) {
      canvas.drawPath(
        d.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = shadow ? ink : Colors.black,
      );
    }
  }
}

// MARK: - Loading pages from assets/coloring_pages/

class CbnLibrary {
  static List<CbnPage>? _cache;

  static Future<List<CbnPage>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final files = manifest
        .listAssets()
        .where((a) => a.startsWith('assets/coloring_pages/') && a.endsWith('.json'))
        .toList();

    final byId = <String, CbnPage>{};
    for (final f in files) {
      try {
        final json = jsonDecode(await rootBundle.loadString(f)) as Map<String, dynamic>;
        final page = CbnPage.fromJson(json);
        byId[page.id] = page;
      } catch (_) {
        // not a page file: skip
      }
    }
    final pages = byId.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    _cache = pages;
    return pages;
  }

  /// One page per subject for the age level; falls back to the nearest
  /// lower level, so new levels can be added without code changes.
  static List<CbnPage> pagesForLevel(int level, List<CbnPage> all) {
    final bySubject = <String, List<CbnPage>>{};
    for (final p in all) {
      bySubject.putIfAbsent('${p.category}/${p.subject}', () => []).add(p);
    }
    final result = <CbnPage>[];
    for (final versions in bySubject.values) {
      versions.sort((a, b) => a.level.compareTo(b.level));
      final lowerOrEqual = versions.where((p) => p.level <= level).toList();
      result.add(lowerOrEqual.isNotEmpty ? lowerOrEqual.last : versions.first);
    }
    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }
}
