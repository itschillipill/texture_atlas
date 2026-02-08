import 'package:image/image.dart';
import 'package:texture_atlas/models/packed_sprite.dart';

import 'pack_result.dart';

abstract class TexturePacker {
  Future<PackResult> pack(Iterable<Image> images, {int padding = 1});
  static double calculateEfficiency(
      List<PackedSprite> sprites, int width, int height) {
    final usedArea = sprites.fold<int>(
        0, (sum, sprite) => sum + sprite.width * sprite.height);
    final totalArea = width * height;
    return totalArea > 0 ? (usedArea / totalArea * 100) : 0;
  }
}