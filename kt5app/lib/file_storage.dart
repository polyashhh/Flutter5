import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static const String _fileName = 'user_data.json';

  Future<String> get _filePath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_fileName';
  }

  Future<void> write(String content) async {
    final file = File(await _filePath);
    await file.writeAsString(content);
  }

  Future<String?> read() async {
    final file = File(await _filePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  Future<void> delete() async {
    final file = File(await _filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}