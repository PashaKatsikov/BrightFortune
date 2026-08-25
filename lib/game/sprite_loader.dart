import 'dart:ui' as ui;

import 'package:flame/sprite.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Loads PNG assets declared in pubspec.yaml into Flame [Sprite]s using
/// Flutter's normal asset bundle, sidestepping Flame's own image-cache
/// prefix conventions entirely. Results are cached by asset path.
class SpriteLoader {
  SpriteLoader._();

  static final Map<String, Sprite> _cache = {};

  static Future<Sprite> load(String assetPath) async {
    final cached = _cache[assetPath];
    if (cached != null) return cached;
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final sprite = Sprite(frame.image);
    _cache[assetPath] = sprite;
    return sprite;
  }

  static Future<void> preload(List<String> assetPaths) async {
    await Future.wait(assetPaths.map(load));
  }
}
