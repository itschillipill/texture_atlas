import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:texture_atlas/server/router.dart';
import 'package:texture_atlas/utils/constants.dart';

import 'utils/file_utils.dart';

Future<void> texture_atlas_server(List<String> args) async {
  final port = int.tryParse(args.firstOrNull ?? '') ?? 8080;

  ensureUploadsDir(uploadsDir);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(buildRouter());

  final server = await serve(handler, 'localhost', port);

  print('✅ Texture Atlas Server запущен!'); 
  print('🌐 Адрес: http://${server.address.host}:${server.port}'); 
  print('📁 Загрузки сохраняются в: $uploadsDir/');
}
