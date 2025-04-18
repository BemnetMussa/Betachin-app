// This is a stub file for non-web platforms
// It's needed to make conditional imports work correctly

// Empty class for type compatibility with html.File
class File {
  final String type = '';
}

// Empty class to satisfy FileReader references
class FileReader {
  dynamic result;
  Stream<dynamic> get onLoadEnd => const Stream.empty();
  void readAsArrayBuffer(dynamic file) {}
}
