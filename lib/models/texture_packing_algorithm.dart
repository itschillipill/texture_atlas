/// Texture atlas packing algorithms.
///
/// Each algorithm defines a different strategy
/// for placing images inside a single atlas.
enum TexturePackingAlgorithm {
  /// Shelf (row-based) packing.
  ///
  /// Images are placed from left to right in horizontal rows.
  /// When the current row has no space left,
  /// a new row is started below.
  ///
  /// The height of each row is defined by
  /// the tallest image placed in that row.
  shelf,

  /// Sorted shelf packing.
  ///
  /// Images are sorted by size (commonly by height or area)
  /// before being placed using the shelf strategy.
  ///
  /// The placement itself is still row-based,
  /// but ordering reduces empty vertical gaps.
  shelfSorted,

  /// Skyline packing.
  ///
  /// The algorithm maintains a "skyline" profile
  /// representing the top contour of already placed images.
  ///
  /// Each new image is placed at the lowest possible
  /// position where it fits within the skyline.
  skyline,

  /// MaxRects packing.
  ///
  /// The atlas space is represented as a set of free rectangles.
  /// For each image, the algorithm selects a free rectangle
  /// that can contain it and splits the remaining space
  /// into new free rectangles.
  maxRects,

  /// Guillotine packing.
  ///
  /// After placing an image, the remaining free space
  /// is split into two rectangles using a straight cut
  /// (horizontal or vertical), similar to cutting with a guillotine.
  ///
  /// The process repeats recursively for the remaining space.
  guillotine,

  /// Brute-force or multi-pass packing.
  ///
  /// Multiple packing attempts are performed using
  /// different algorithms, orderings, or atlas sizes.
  ///
  /// The best resulting layout is selected based on
  /// a chosen evaluation metric.
  bruteForce;

  static TexturePackingAlgorithm fromString(String value) {
    switch (value.toLowerCase()) {
      case 'shelf':
        return TexturePackingAlgorithm.shelf;
      case 'shelf_sorted':
      case 'shelfsorted':
        return TexturePackingAlgorithm.shelfSorted;
      case 'skyline':
        return TexturePackingAlgorithm.skyline;
      case 'maxrects':
        return TexturePackingAlgorithm.maxRects;
      default:
        throw ArgumentError('Unknown packing algorithm: $value');
    }
  }
}

extension TexturePackingAlgorithmDocs on TexturePackingAlgorithm {
  String get description {
    switch (this) {
      case TexturePackingAlgorithm.shelf:
        return 'Places images in horizontal rows from left to right.';
      case TexturePackingAlgorithm.shelfSorted:
        return 'Sorts images by size, then places them in rows.';
      case TexturePackingAlgorithm.skyline:
        return 'Places images along the lowest available skyline.';
      case TexturePackingAlgorithm.maxRects:
        return 'Manages free rectangles and places images into them.';
      case TexturePackingAlgorithm.guillotine:
        return 'Splits free space using straight cuts after placement.';
      case TexturePackingAlgorithm.bruteForce:
        return 'Runs multiple packing passes and selects the best result.';
    }
  }
}
