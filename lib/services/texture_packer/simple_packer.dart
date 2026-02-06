import 'dart:math';

import 'package:image/image.dart';

import '../../models/packed_sprite.dart';
import 'pack_result.dart';
import 'texture_packer.dart';

class SimpleTexturePacker implements TexturePacker {
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
    
    for (var i = 0; i < images.length; i++) {
      final image = images[i];
      
      // Если изображение не помещается в текущую строку, начинаем новую
      if (currentX + image.width > 1024) { // временный лимит
        currentX = 0;
        currentY += rowHeight;
        rowHeight = 0;
      }
      
      // Размещаем изображение
      packedSprites.add(PackedSprite(
        name: 'image_$i',
        x: currentX,
        y: currentY,
        width: image.width,
        height: image.height,
      ));
      
      currentX += image.width;
      rowHeight = max(rowHeight, image.height);
      
      // Обновляем размеры атласа
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
      image: atlasImage,
      sprites: packedSprites,
      pngBytes: encodePng(atlasImage),
      efficiency: _calculateEfficiency(packedSprites, atlasWidth, atlasHeight),
    );
  }
  
  static double _calculateEfficiency(List<PackedSprite> sprites, int width, int height) {
    final usedArea = sprites.fold<int>(0, (sum, sprite) => sum + sprite.width * sprite.height);
    final totalArea = width * height;
    return totalArea > 0 ? (usedArea / totalArea * 100) : 0;
  }
}