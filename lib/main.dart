import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';



Response _$rootHandler(Request request){
  return Response.ok(
    'Texture Atlas Server is running!\n'
      'Endpoints:\n'
      '  GET  /health         - Check server health\n'
      '  POST /upload         - Upload images for atlas\n'
      '  GET  /atlas/<id>     - Get atlas info\n'
      '  GET  /download/<id>  - Download atlas'
  );
}
final _$router = Router()
  ..get('/', _$rootHandler)
  ..get('/health', _$healthHandler)
  ..post('/upload', _$uploadHandler)
  ..get('/atlas/<id>', _$getAtlasHandler)
  ..get('/download/<id>', _$downloadHandler);

Response _$healthHandler(Request request) => Response.ok('OK');

Future<Response> _$uploadHandler(Request request) async {
  try {
    // Парсим multipart запрос
    final body = await request.read().cast<List<int>>().toList();
    
    // Пока просто извлекаем имена файлов
    final boundary = _extractBoundary(request.headers['content-type'] ?? '');
    if (boundary.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'No multipart boundary found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    
    final filenames = await _extractFilenames(body, boundary);
    
    if (filenames.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'No files uploaded'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    
    // Создаем "фейковый" атлас
    final atlasId = 'atlas_${DateTime.now().millisecondsSinceEpoch}';
    final atlasInfo = AtlasInfo(atlasId, filenames);
    
    // Сохраняем в память
    _storage[atlasId] = atlasInfo;
    
    print('✅ Создан атлас $atlasId с ${filenames.length} изображениями');
    
    return Response.ok(
      jsonEncode(atlasInfo.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    
  } catch (e) {
    print('❌ Ошибка при загрузке: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Upload failed', 'details': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Response _$getAtlasHandler(Request request, String id) {
  final atlasInfo = _storage[id];
  
  if (atlasInfo == null) {
    return Response.notFound(
      jsonEncode({'error': 'Atlas not found'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  return Response.ok(
    jsonEncode(atlasInfo.toJson()),
    headers: {'Content-Type': 'application/json'},
  );
}

Response _$downloadHandler(Request request, String id) {
  // Пока возвращаем заглушку
  return Response.ok(
    'This would be the texture atlas file for ID: $id\n\n'
    'In the future, this will return a PNG image.',
    headers: {'Content-Type': 'text/plain'},
  );
}

// Вспомогательные функции
String _extractBoundary(String contentType) {
  final match = RegExp(r'boundary=([^;]+)').firstMatch(contentType);
  return match?.group(1)?.trim() ?? '';
}

Future<List<String>> _extractFilenames(List<List<int>> body, String boundary) async {
  final filenames = <String>[];
  final data = body.expand((x) => x).toList();
  
  // Простой парсинг multipart для извлечения имен файлов
  final boundaryBytes = '--$boundary'.codeUnits;
  
  var start = 0;
  while (true) {
    final boundaryIndex = _indexOf(data, boundaryBytes, start);
    if (boundaryIndex == -1) break;
    
    final nextBoundaryIndex = _indexOf(data, boundaryBytes, boundaryIndex + boundaryBytes.length);
    if (nextBoundaryIndex == -1) break;
    
    final part = data.sublist(boundaryIndex + boundaryBytes.length, nextBoundaryIndex);
    final partStr = utf8.decode(part);
    
    // Ищем имя файла в заголовках
    final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(partStr);
    if (filenameMatch != null) {
      filenames.add(filenameMatch.group(1)!);
    }
    
    start = nextBoundaryIndex;
  }
  
  return filenames;
}

int _indexOf(List<int> list, List<int> pattern, int start) {
  for (int i = start; i <= list.length - pattern.length; i++) {
    bool found = true;
    for (int j = 0; j < pattern.length; j++) {
      if (list[i + j] != pattern[j]) {
        found = false;
        break;
      }
    }
    if (found) return i;
  }
  return -1;
}


Future<void> main(List<String> args) async{
  final port = int.tryParse(args.firstOrNull ?? '8080')?? 8080;
  
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_$router);

  final server = await serve(handler, 'localhost', port);

  print('✅ Texture Atlas Server запущен!');
  print('🌐 Адрес: http://${server.address.host}:${server.port}');
  print('📋 Доступные endpoints:');
  print('   http://localhost:${server.port}/');
  print('   http://localhost:${server.port}/health');
  print('   http://localhost:${server.port}/upload (POST)');
}


class AtlasInfo {
  final String id;
  final DateTime createdAt;
  final List<String> imageNames;
  
  AtlasInfo(this.id, this.imageNames) : createdAt = DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'imageCount': imageNames.length,
      'images': imageNames,
      'status': 'completed',
      'atlasUrl': '/download/$id',
      'infoUrl': '/atlas/$id',
    };
  }
}

final _storage = <String, AtlasInfo>{};