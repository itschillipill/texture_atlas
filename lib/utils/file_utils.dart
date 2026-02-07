import 'dart:io' show Directory;

void ensureUploadsDir(String uploadsDir) {
  final dir = Directory(uploadsDir);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
    print('📁 Создана директория uploads/');
  }
}
