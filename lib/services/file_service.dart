import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileService {
  static Future<File?> pickFile({
    required List<String> allowedExtensions,
  }) async {
    if (Platform.isWindows) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } else {
      throw UnsupportedError('File picking is not supported on this platform.');
    }
  }

  static Future<String> readFile(String path) async {
    if (Platform.isWindows) {
      File file = File(path);
      if (await file.exists() == false) {
        throw Exception('File not exists : $path');
      }
      return await file.readAsString();
    } else {
      throw UnsupportedError('Unsupported on this platform.');
    }
  }

  static Future<void> writeFile(String path, String content, {bool createIfNonExists = false}) async {
    if (Platform.isWindows) {
      File file = File(path);
      if (await file.exists() == false && createIfNonExists == false) {
        throw Exception('File not exists : $path');
      }
      if(createIfNonExists == true){
        await file.create();
      }
      
      await file.writeAsString(content);
    } else {
      throw UnsupportedError('Unsupported on this platform.');
    }
  }

  static Future<void> deleteFile(String path) async {
    try {
      File file = File(path);
      if (await file.exists()) {
        await file.delete(recursive: true);
      } else {
        throw FileSystemException("File does not exist", path);
      }
    } catch (e) {
      throw Exception("Failed to delete file: $path. Error: $e");
    }
  }
}
