import 'dart:convert';
import 'package:image/image.dart' show Image;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:texture_atlas/models/texture_packing_algorithm.dart';

import '../services/multipart/multipart_parser.dart';
import '../services/texture_packer/shelf_packer.dart';
import '../services/storage_service.dart';

Router uploadRoutes() {
  final router = Router();

  router.post('/upload', _uploadHandler);

  return router;
}

Future<Response> _uploadHandler(Request request) async {
  try {
    final (List<Image> images, TexturePackingAlgorithm algorithm) =
        await MultipartParser.parseRequest(request);

    if (images.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'No images uploaded'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result =
        await (switch (algorithm) { _ => ShelfTexturePacker() }).pack(images);

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
