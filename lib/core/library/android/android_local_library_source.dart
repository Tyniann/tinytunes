import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tinytunes/core/library/local_library_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';

/// Android SAF-backed [LocalLibrarySource] via a narrow MethodChannel.
///
/// Purpose: Pick/retain a document tree and resolve items without broad storage
/// permissions or `file_picker` domain types.
/// Usage Context: Phase 0 spike and kept as the Android adapter after cleanup.
class AndroidLocalLibrarySource implements LocalLibrarySource {
  /// Creates an adapter using the default SAF channel name.
  AndroidLocalLibrarySource({
    MethodChannel? channel,
    this.maxMaterializeBytes = 100 * 1024 * 1024,
  }) : _channel = channel ?? const MethodChannel('at.blumenlaube.tinytunes/saf');

  final MethodChannel _channel;

  /// Hard ceiling when copying a document into a temp file for tags.
  final int maxMaterializeBytes;

  @override
  Future<MediaLocator?> pickAndRetainRoot() async {
    final uri = await _channel.invokeMethod<String>('pickAndPersistTree');
    if (uri == null || uri.isEmpty) return null;
    return MediaLocator(uri);
  }

  @override
  Future<List<LibraryEntry>> listChildren(MediaLocator parent) async {
    final raw = await _channel.invokeMethod<List<dynamic>>('listChildren', {
      'directoryUri': parent.value,
    });
    if (raw == null) return const [];
    return raw.map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return LibraryEntry(
        locator: MediaLocator(map['uri'] as String),
        name: map['name'] as String? ?? '',
        isDirectory: map['isDirectory'] as bool? ?? false,
      );
    }).toList(growable: false);
  }

  @override
  Future<Uri> resolvePlaybackUri(MediaLocator item) async {
    return Uri.parse(item.value);
  }

  @override
  Future<String> materializeReadablePath(
    MediaLocator item, {
    String? fileNameHint,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final ext = _extensionFor(fileNameHint, item);
    final dest = p.join(
      tempDir.path,
      'tinytunes_meta_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await _channel.invokeMethod<String>('copyToCache', {
      'documentUri': item.value,
      'destPath': dest,
      'maxBytes': maxMaterializeBytes,
    });
    return dest;
  }

  /// Picks a temp-file extension so path-only tag readers can detect format.
  String _extensionFor(String? fileNameHint, MediaLocator item) {
    final fromHint = fileNameHint == null ? '' : p.extension(fileNameHint);
    if (fromHint.length >= 2) return fromHint.toLowerCase();

    final decoded = Uri.decodeFull(item.value);
    final fromUri = p.extension(decoded.split('/').last);
    if (fromUri.length >= 2 && fromUri.length <= 5) {
      return fromUri.toLowerCase();
    }
    return '.bin';
  }

  @override
  Future<bool> hasPersistedAccess(MediaLocator root) async {
    final ok = await _channel.invokeMethod<bool>('hasPersisted', {
      'treeUri': root.value,
    });
    return ok ?? false;
  }

  @override
  Future<List<MediaLocator>> listPersistedRoots() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('listPersisted');
    if (raw == null) return const [];
    return raw
        .whereType<String>()
        .map(MediaLocator.new)
        .toList(growable: false);
  }

  @override
  Future<void> releaseRoot(MediaLocator root) async {
    await _channel.invokeMethod<void>('release', {'treeUri': root.value});
  }
}

/// Deletes [path] if it exists; ignores missing files.
///
/// Purpose: Shared cleanup for materialized metadata temps.
void deleteQuietly(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  } on Object {
    // Best-effort cleanup for spike/adapter temps.
  }
}
