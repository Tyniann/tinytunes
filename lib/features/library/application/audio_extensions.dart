/// Case-insensitive audio suffixes accepted by the scanner.
///
/// Purpose: Single place for Phase 2 extension allow-list matching.
const audioFileExtensions = <String>{
  '.mp3',
  '.flac',
  '.m4a',
  '.aac',
  '.ogg',
  '.opus',
  '.wav',
};

/// Whether [fileName] looks like an audio file (files only; not directories).
bool isAudioFileName(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot < 0) return false;
  final ext = fileName.substring(dot).toLowerCase();
  return audioFileExtensions.contains(ext);
}

/// Best-effort display label from an opaque root locator URI string.
String displayNameFromRootLocator(String locatorValue) {
  try {
    final decoded = Uri.decodeFull(locatorValue);
    final parts = decoded.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return locatorValue;
    var last = parts.last;
    last = Uri.decodeComponent(last);
    final colon = last.lastIndexOf(':');
    if (colon >= 0 && colon < last.length - 1) {
      last = last.substring(colon + 1);
    }
    return last.isEmpty ? locatorValue : last;
  } on Object {
    return locatorValue;
  }
}
