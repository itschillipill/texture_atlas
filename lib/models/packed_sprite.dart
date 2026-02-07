class PackedSprite {
  final String name;
  final int x;
  final int y;
  final int width;
  final int height;

  PackedSprite({
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}
