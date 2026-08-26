// ignore_for_file: avoid_print
// ============================================================
// gen_icon.dart — launcher icon layers from the source artwork
// ============================================================
// Usage:
//   dart run tool/gen_icon.dart
//   dart run flutter_launcher_icons
//
// Produces three square PNGs under assets/generated/:
//
//   app_icon.png             full-bleed, legacy mipmap source
//   app_icon_foreground.png  full-bleed, adaptive foreground layer
//   app_icon_background.png  solid colour, adaptive background layer
//
// The adaptive foreground is written full-bleed on purpose:
// flutter_launcher_icons wraps it in `<inset android:inset="16%">`
// inside ic_launcher.xml, so the artwork lands at 108dp − 2×17.28dp
// ≈ 73dp of the adaptive canvas — the size the brief asks for. The
// background is the artwork's own border colour so the corners the
// launcher mask leaves visible blend into the picture instead of
// framing it.
//
// The outputs are build-time only; they are NOT declared in
// pubspec.yaml's asset list and never ship inside the APK.
// ============================================================

import 'dart:io';

import 'package:image/image.dart' as img;

const String _source = 'assets/Bright_Fortune_additional_assets/icon2.jpg';
const String _outDir = 'assets/generated';
const int _canvas = 1024;

void main() {
  final File source = File(_source);
  if (!source.existsSync()) {
    stderr.writeln('gen_icon: missing $_source');
    exit(1);
  }

  final img.Image? decoded = img.decodeImage(source.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('gen_icon: could not decode $_source');
    exit(1);
  }

  final img.Image art = img.copyResize(
    _centreSquare(decoded),
    width: _canvas,
    height: _canvas,
    interpolation: img.Interpolation.cubic,
  );

  final img.ColorRgb8 edge = _borderColour(art);
  final img.Image backdrop = img.Image(width: _canvas, height: _canvas);
  img.fill(backdrop, color: edge);

  Directory(_outDir).createSync(recursive: true);
  _write('app_icon.png', art);
  _write('app_icon_foreground.png', art);
  _write('app_icon_background.png', backdrop);

  final String hex = '#'
      '${edge.r.toInt().toRadixString(16).padLeft(2, '0')}'
      '${edge.g.toInt().toRadixString(16).padLeft(2, '0')}'
      '${edge.b.toInt().toRadixString(16).padLeft(2, '0')}';
  print('gen_icon: source ${decoded.width}x${decoded.height} -> $_canvas²');
  print('gen_icon: background $hex');
}

img.Image _centreSquare(img.Image src) {
  final int side = src.width < src.height ? src.width : src.height;
  return img.copyCrop(
    src,
    x: (src.width - side) ~/ 2,
    y: (src.height - side) ~/ 2,
    width: side,
    height: side,
  );
}

/// Mean colour of the outermost 4% band — the tone the launcher mask
/// exposes at the corners of the adaptive icon.
img.ColorRgb8 _borderColour(img.Image src) {
  final int band = (src.width * 0.04).round().clamp(1, src.width);
  int r = 0;
  int g = 0;
  int b = 0;
  int count = 0;
  for (int y = 0; y < src.height; y++) {
    final bool edgeRow = y < band || y >= src.height - band;
    for (int x = 0; x < src.width; x++) {
      if (!edgeRow && x >= band && x < src.width - band) continue;
      final img.Pixel px = src.getPixel(x, y);
      r += px.r.toInt();
      g += px.g.toInt();
      b += px.b.toInt();
      count++;
    }
  }
  if (count == 0) return img.ColorRgb8(0, 0, 0);
  return img.ColorRgb8(r ~/ count, g ~/ count, b ~/ count);
}

void _write(String name, img.Image image) {
  File('$_outDir/$name').writeAsBytesSync(img.encodePng(image));
  print('gen_icon: wrote $_outDir/$name');
}
