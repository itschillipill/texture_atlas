import 'package:shelf_router/shelf_router.dart';

import '../routes/root_routes.dart';
import '../routes/upload_route.dart';
import '../routes/atlas_route.dart';
import '../routes/debug_route.dart';

Router buildRouter() {
  final router = Router();

  router.mount('/', rootRoutes());
  router.mount('/', uploadRoutes());
  router.mount('/', atlasRoutes());
  router.mount('/', debugRoutes());

  return router;
}
