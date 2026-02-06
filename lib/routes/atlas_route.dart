import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/storage_service.dart';

Router atlasRoutes() {
  final router = Router();

  router.get('/atlas/<id>', _getAtlas);
  router.get('/download/<id>', _downloadAtlas);

  return router;
}

Response _getAtlas(Request request, String id) {
  return StorageService.getMetadata(id);
}

Future<Response> _downloadAtlas(Request request, String id) {
  return StorageService.getAtlasImage(id);
}