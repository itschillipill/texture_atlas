import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:path/path.dart' as p;
import 'package:texture_atlas/models/texture_packing_algorithm.dart';
import 'package:texture_atlas/utils/constants.dart';
import 'package:uuid/uuid.dart';

import '../services/texture_packer/pack_result.dart';

class StorageService {
  static final _uuid = Uuid();
  static final _baseDir = Directory(uploadsDir);

  static void ensure() {
    if (!_baseDir.existsSync()) {
      _baseDir.createSync(recursive: true);
    }
  }

  static Future<Map<String, dynamic>> saveAtlas(
      PackResult result, TexturePackingAlgorithm algorithm) async {
    ensure();

    final id = _uuid.v4();

    final pngFile = File(p.join(_baseDir.path, '$id.png'));
    await pngFile.writeAsBytes(result.imgBytes);

    final metadata = {
      'id': id,
      'algorithm': algorithm.name,
      'width': result.width,
      'height': result.height,
      'sprites': result.sprites.map((e) => e.toJson()).toList(),
      'efficiency': result.efficiency,
    };

    final jsonFile = File(p.join(_baseDir.path, '$id.json'));
    await jsonFile.writeAsString(jsonEncode(metadata));

    return metadata;
  }

  static Response getMetadata(String id) {
    final file = File(p.join(_baseDir.path, '$id.json'));
    if (!file.existsSync()) {
      return Response.notFound('Atlas not found');
    }
    return Response.ok(
      file.readAsStringSync(),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<Response> getAtlasImage(String id) async {
    final file = File(p.join(_baseDir.path, '$id.png'));
    if (!await file.exists()) {
      return Response.notFound('Atlas image not found');
    }

    return Response.ok(
      await file.readAsBytes(),
      headers: {'Content-Type': 'image/png'},
    );
  }

  static List<Map<String, dynamic>> listFiles() {
    ensure();

    return _baseDir.listSync().map((e) {
      final stat = e.statSync();
      return {
        'name': p.basename(e.path),
        'size': stat.size,
        'modified': stat.modified.toIso8601String(),
      };
    }).toList();
  }
}
