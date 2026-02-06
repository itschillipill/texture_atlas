import 'package:image/image.dart';

import '../../models/packed_sprite.dart';

import 'dart:typed_data';

class PackResult {
  final int width;
  final int height;
  final Image image;
  final Uint8List pngBytes;
  final List<PackedSprite> sprites;
  final double efficiency;

  PackResult({
    required this.width,
    required this.height,
    required this.image,
    required this.pngBytes,
    required this.sprites,
    required this.efficiency,
  });
}
