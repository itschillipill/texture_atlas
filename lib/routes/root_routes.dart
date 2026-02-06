import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router rootRoutes() {
  final router = Router();

  router.get('/', _rootHandler);
  router.get('/health', _healthHandler);

  return router;
}

Response _rootHandler(Request request) {
  return Response.ok(
    'Texture Atlas Server v0.2\n\n'
    'Endpoints:\n'
    '  GET  /\n'
    '  GET  /health\n'
    '  POST /upload\n'
    '  GET  /atlas/<id>\n'
    '  GET  /download/<id>\n',
  );
}

Response _healthHandler(Request request) => Response.ok('OK');