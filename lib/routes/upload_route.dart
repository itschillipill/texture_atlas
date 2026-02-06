import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/multipart/multipart_parser.dart';
import '../services/texture_packer/simple_packer.dart';
import '../services/storage_service.dart';

Router uploadRoutes() {
  final router = Router();

  router.post('/upload', _uploadHandler);

  return router;
}

Future<Response> _uploadHandler(Request request) async {
  try {
    final images = await MultipartParser.parseImages(request);

    if (images.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'No images uploaded'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final packer = SimpleTexturePacker();
    final result = await packer.pack(images);

    final metadata = await StorageService.saveAtlas(result);

    return Response.ok(
      jsonEncode(metadata),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
