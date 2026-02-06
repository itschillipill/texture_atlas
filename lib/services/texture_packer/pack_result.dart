import '../../models/packed_sprite.dart';

import 'dart:typed_data';

class PackResult {
  final int width;
  final int height;
  final Uint8List imgBytes;
  final Iterable<PackedSprite> sprites;
  final double efficiency;

  PackResult({
    required this.width,
    required this.height,
    required this.imgBytes,
    required this.sprites,
    required this.efficiency,
  });
}
