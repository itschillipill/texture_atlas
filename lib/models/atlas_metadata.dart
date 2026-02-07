import 'packed_sprite.dart';

class AtlasMetadata {
  final String id;
  final int width;
  final int height;
  final List<PackedSprite> sprites;

  AtlasMetadata(
      {required this.id,
      required this.width,
      required this.height,
      required this.sprites});
}
