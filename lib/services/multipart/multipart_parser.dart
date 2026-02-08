import 'dart:convert';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:image/image.dart';

import '../../models/texture_packing_algorithm.dart';

class MultipartParser {
  static Future<(List<Image>, TexturePackingAlgorithm)> parseRequest(
      Request request) async {
    final body = await request.read().expand((e) => e).toList();

    final contentType = request.headers['content-type'] ?? '';
    final boundaryMatch = RegExp(r'boundary=([^\s;]+)').firstMatch(contentType);

    if (boundaryMatch == null) {
      throw Exception('Multipart boundary not found');
    }

    final boundary = boundaryMatch.group(1)!;

    return _extractParts(body, boundary);
  }

  static (List<Image>, TexturePackingAlgorithm) _extractParts(
    List<int> data,
    String boundary,
  ) {
    final images = <Image>[];
    late final TexturePackingAlgorithm algorithm;

    final boundaryBytes = '--$boundary'.codeUnits;
    var pos = 0;

    while (true) {
      final start = _find(data, boundaryBytes, pos);
      if (start == -1) break;

      pos = start + boundaryBytes.length;

      final headersEnd = _find(data, [13, 10, 13, 10], pos);
      if (headersEnd == -1) break;

      final headers = utf8.decode(data.sublist(pos, headersEnd));
      pos = headersEnd + 4;

      final nextBoundary = _find(data, boundaryBytes, pos);
      if (nextBoundary == -1) break;

      final contentBytes = data.sublist(pos, nextBoundary - 2);
      pos = nextBoundary;

      if (headers.contains('filename=')) {
        final image = decodeImage(Uint8List.fromList(contentBytes));
        if (image != null) images.add(image);
        continue;
      }

      final nameMatch = RegExp(r'name="([^"]+)"').firstMatch(headers);
      if (nameMatch == null) continue;

      final fieldName = nameMatch.group(1)!;
      final value = utf8.decode(contentBytes).trim();

      if (fieldName == 'algorithm') {
        algorithm = TexturePackingAlgorithm.fromString(value);
      }
    }

    return (images, algorithm);
  }

  static int _find(List<int> data, List<int> pattern, int start) {
    for (var i = start; i <= data.length - pattern.length; i++) {
      var match = true;
      for (var j = 0; j < pattern.length; j++) {
        if (data[i + j] != pattern[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
    return -1;
  }
}
