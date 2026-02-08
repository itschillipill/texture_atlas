import 'package:image/image.dart';
import 'package:texture_atlas/services/texture_packer/shelf_packer.dart';

import 'pack_result.dart';

class ShelfHeightSortedPacker extends ShelfTexturePacker {
  @override
  Future<PackResult> pack(Iterable<Image> images, {int padding = 1}) {
    if (images.isEmpty) {
      throw ArgumentError('No images to pack');
    }

    final sortedImages = List<Image>.from(images)
      ..sort((a, b) => b.height.compareTo(a.height));

    return super.pack(sortedImages, padding: padding);
  }
}

class ShelfAreaSortedPacker extends ShelfTexturePacker {
  @override
  Future<PackResult> pack(Iterable<Image> images, {int padding = 1}) {
    if (images.isEmpty) {
      throw ArgumentError('No images to pack');
    }

    final sortedImages = List<Image>.from(images)
      ..sort((a, b) =>
          (b.width * b.height).compareTo(a.width * a.height));

    return super.pack(sortedImages, padding: padding);
  }
}