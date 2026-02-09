import 'dart:math';
import 'package:image/image.dart';
import 'texture_packer.dart';
import 'pack_result.dart';
import '../../models/packed_sprite.dart';

class GridTexturePacker implements TexturePacker {
  @override
  Future<PackResult> pack(Iterable<Image> images, {int padding = 1}) async {
    if (images.isEmpty) {
      throw ArgumentError('No images to pack');
    }

    final imageList = images.toList();
    final packedSprites = <PackedSprite>[];

    // Определяем размер ячейки по максимальному изображению
    final cellWidth = imageList.map((img) => img.width).reduce(max) + padding;
    final cellHeight = imageList.map((img) => img.height).reduce(max) + padding;

    // Считаем, сколько ячеек в ряду
    final numCols = sqrt(imageList.length).ceil();

    int currentX = 0;
    int currentY = 0;
    int maxRowHeight = 0;

    int atlasWidth = 0;
    int atlasHeight = 0;

    for (var i = 0; i < imageList.length; i++) {
      final img = imageList[i];

      packedSprites.add(PackedSprite(
        name: 'image_$i',
        x: currentX,
        y: currentY,
        width: img.width,
        height: img.height,
      ));

      currentX += cellWidth;
      maxRowHeight = max(maxRowHeight, cellHeight);

      if ((i + 1) % numCols == 0) {
        currentX = 0;
        currentY += maxRowHeight;
        maxRowHeight = 0;
      }

      atlasWidth = max(atlasWidth, currentX);
      atlasHeight = max(atlasHeight, currentY + maxRowHeight);
    }

    // Создаем итоговое изображение атласа
    final atlasImage = Image(width: atlasWidth, height: atlasHeight);
    fill(atlasImage, color: ColorRgba8(0, 0, 0, 0));

    // Размещаем изображения
    for (var i = 0; i < imageList.length; i++) {
      final sprite = packedSprites[i];
      compositeImage(
        atlasImage,
        imageList[i],
        dstX: sprite.x,
        dstY: sprite.y,
      );
    }

    return PackResult(
      width: atlasWidth,
      height: atlasHeight,
      sprites: packedSprites,
      imgBytes: encodePng(atlasImage),
      efficiency: TexturePacker.calculateEfficiency(
          packedSprites, atlasWidth, atlasHeight),
    );
  }
}
