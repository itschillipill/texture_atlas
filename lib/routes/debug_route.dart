import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/storage_service.dart';

Router debugRoutes() {
  final router = Router();

  router.get('/debug/files', (req) {
    final files = StorageService.listFiles();
    return Response.ok(
      jsonEncode({'files': files}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}