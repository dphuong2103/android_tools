import 'dart:io';
import 'package:android_tools/flavors.dart';
import 'package:path/path.dart' as p;

class FilePath {
  static final String scripts = "scripts";
}

class TextFileService {
  final Flavor flavor;

  TextFileService({required this.flavor});

  // Get the file with a dynamic name
  Future<File?> _getFile(String filePath) async {
    String path;
    if (flavor == Flavor.PROD) {
      path = p.join(Directory.current.path);
    } else {
      path = p.join(Directory.current.path, "file");
    }

    final file = File(
      '$path/$filePath.txt',
    );
    if (!await file.exists()) {
      return null;
    }

    return file;
  }

  // Save a list of strings to the file (each item on a new line)
  Future<void> saveData(List<String> data, String filePath) async {
    final file = await _getFile(filePath);
    if(file == null){
      return;
    }
    await file.writeAsString(data.join('\n'));
  }

  // Read data from the file
  Future<List<String>?> readData(String filePath) async {
    final file = await _getFile(filePath);
    if(file == null){
      return null;
    }
    if (await file.exists()) {
      String contents = await file.readAsString();
      return contents.isNotEmpty ? contents.split('\n') : [];
    }
    return [];
  }

  // Modify a specific line by index
  Future<void> modifyLineAtIndex(
    int index,
    String newData,
    String filePath,
  ) async {
    if(!await fileExists(filePath)){
      return;
    }
    List<String> data = (await readData(filePath))!;
    if (index >= 0 && index < data.length) {
      data[index] = newData;
      await saveData(data, filePath);
    }
  }

  // Edit a line based on content (replace first occurrence)
  Future<void> editLine(String oldData, String newData, String filePath) async {
    if(!await fileExists(filePath)){
      return;
    }
    List<String> data = (await readData(filePath))!;
    int index = data.indexOf(oldData);
    if (index != -1) {
      data[index] = newData;
      await saveData(data, filePath);
    }
  }

  // Delete a specific line by index
  Future<void> deleteLine(int index, String filePath) async {
    if(!await fileExists(filePath)){
      return;
    }
    List<String> data = (await readData(filePath))!;
    if (index >= 0 && index < data.length) {
      data.removeAt(index);
      await saveData(data, filePath);
    }
  }

  Future<void> deleteLineByValue(String value, String filePath) async {
    if(!await fileExists(filePath)){
      return;
    }
    List<String> data = (await readData(filePath))!;
    int index = data.indexOf(value);
    if (index != -1) {
      data.removeAt(index);
      await saveData(data, filePath);
    }
  }

  Future<bool> fileExists(String filePath) async {
    String path;
    if (flavor == Flavor.PROD) {
      path = p.join(Directory.current.path);
    } else {
      path = p.join(Directory.current.path, "file");
    }

    final file = File(
      '$path/$filePath.txt',
    );
    return file.exists();

  }
}
