import 'package:image/image.dart';

import 'pack_result.dart';

abstract class TexturePacker {
  Future<PackResult> pack(List<Image> images, {int padding});
}
