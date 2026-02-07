import 'dart:math';

import 'package:image/image.dart';

import '../../models/packed_sprite.dart';
import 'pack_result.dart';
import 'texture_packer.dart';

class SimpleTexturePacker extends TexturePacker {
  @override
  Future<PackResult> pack(List<Image> images, {int padding = 1}) async {
    if (images.isEmpty) {
      throw ArgumentError('No images to pack');
    }

    images.sort((a, b) => b.height.compareTo(a.height));

    var atlasWidth = 0;
    var atlasHeight = 0;
    var currentX = 0;
    var currentY = 0;
    var rowHeight = 0;

    final packedSprites = <PackedSprite>[];
    final totalArea = images.fold<int>(
      0,
      (sum, img) => sum + img.width * img.height,
    );

    final targetWidth = sqrt(totalArea).ceil();
    print("$targetWidth " + "$totalArea");

    for (var i = 0; i < images.length; i++) {
      final image = images[i];

      if (currentX + image.width > targetWidth) {
        currentX = 0;
        currentY += rowHeight + padding;
        rowHeight = 0;
      }

      packedSprites.add(PackedSprite(
        name: 'image_$i',
        x: currentX,
        y: currentY,
        width: image.width,
        height: image.height,
      ));

      currentX += image.width + padding;
      rowHeight = max(rowHeight, image.height);

      atlasWidth = max(atlasWidth, currentX);
      atlasHeight = max(atlasHeight, currentY + rowHeight);
    }

    // Создаем итоговое изображение атласа
    final atlasImage = Image(width: atlasWidth, height: atlasHeight);

    // Заполняем прозрачным цветом
    fill(atlasImage, color: ColorRgba8(0, 0, 0, 0));

    // Размещаем все изображения
    for (var i = 0; i < images.length; i++) {
      final sprite = packedSprites[i];
      compositeImage(
        atlasImage,
        images[i],
        dstX: sprite.x,
        dstY: sprite.y,
      );
    }

    return PackResult(
      width: atlasWidth,
      height: atlasHeight,
      sprites: packedSprites,
      imgBytes: encodePng(atlasImage),
      efficiency: calculateEfficiency(packedSprites, atlasWidth, atlasHeight),
    );
  }
}
