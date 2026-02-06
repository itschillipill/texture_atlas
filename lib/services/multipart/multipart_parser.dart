import 'dart:convert';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:image/image.dart';

class MultipartParser {
  static Future<List<Image>> parseImages(Request request) async {
    final body = await request.read().expand((e) => e).toList();

    final contentType = request.headers['content-type'] ?? '';
    final boundaryMatch = RegExp(r'boundary=([^\s;]+)').firstMatch(contentType);

    if (boundaryMatch == null) {
      throw Exception('Multipart boundary not found');
    }

    final boundary = boundaryMatch.group(1)!;

    return _extractImages(body, boundary);
  }

  static List<Image> _extractImages(List<int> data, String boundary) {
    final images = <Image>[];
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

      if (!headers.contains('filename=')) continue;

      final nextBoundary = _find(data, boundaryBytes, pos);
      if (nextBoundary == -1) break;

      final fileBytes = data.sublist(pos, nextBoundary - 2);
      final image = decodeImage(Uint8List.fromList(fileBytes));

      if (image != null) images.add(image);

      pos = nextBoundary;
    }

    return images;
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
