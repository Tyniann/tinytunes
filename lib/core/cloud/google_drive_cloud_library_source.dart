import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/drive_media_locator.dart';
import 'package:tinytunes/core/cloud/drive_remote.dart';
import 'package:tinytunes/core/cloud/free_space_source.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/features/library/application/audio_extensions.dart';
import 'package:tinytunes/features/library/application/library_entry_order.dart';

/// Google Drive [CloudLibrarySource] (list / download / resolve cache only).
///
/// Purpose: Read-only Drive access with on-disk cache files keyed by file id.
/// Usage Context: Phase 7 ingest and playback; inject [DriveRemote] in tests.
class GoogleDriveCloudLibrarySource implements CloudLibrarySource {
  /// Creates a source writing cache files under [cacheRootDirectory].
  GoogleDriveCloudLibrarySource({
    required DriveRemote remote,
    required Directory cacheRootDirectory,
    FreeSpaceSource freeSpace = const UnlimitedFreeSpaceSource(),
  }) : _remote = remote,
       _cacheRoot = cacheRootDirectory,
       _freeSpace = freeSpace;

  final DriveRemote _remote;
  final Directory _cacheRoot;
  final FreeSpaceSource _freeSpace;

  /// Special Drive parent id for My Drive root (`gdrive:root`).
  static const myDriveRootFileId = 'root';

  @override
  Future<List<CloudLibraryEntry>> list(MediaLocator parent) async {
    final parentId = DriveMediaLocator.decode(parent);
    final children = await _remote.listChildren(parentId);
    final entries = [
      for (final child in children)
        if (child.isDirectory || isAudioFileName(child.name))
          CloudLibraryEntry(
            locator: DriveMediaLocator.encode(child.fileId),
            name: child.name,
            isDirectory: child.isDirectory,
            sizeBytes: child.sizeBytes,
            modifiedAt: child.modifiedAt,
          ),
    ];
    entries.sort((a, b) => compareDisplayNames(a.name, b.name));
    return entries;
  }

  @override
  Future<MediaLocator> downloadToCache(
    MediaLocator item, {
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    final fileId = DriveMediaLocator.decode(item);
    final meta = await _remote.getFileMeta(fileId);
    if (!isAudioFileName(meta.name)) {
      throw StateError('Refusing to cache non-audio Drive file: ${meta.name}');
    }

    await _cacheRoot.create(recursive: true);
    final available = await _freeSpace.availableBytesFor(_cacheRoot.path);
    if (meta.sizeBytes > 0 && available < meta.sizeBytes) {
      throw InsufficientFreeSpaceException(
        requiredBytes: meta.sizeBytes,
        availableBytes: available,
      );
    }

    final destDir = Directory(p.join(_cacheRoot.path, fileId));
    await destDir.create(recursive: true);
    final destPath = p.join(destDir.path, _safeFileName(meta.name));
    var received = 0;
    await _remote.downloadFile(
      fileId: fileId,
      destinationPath: destPath,
      onBytes: (chunk) {
        received += chunk;
        onProgress?.call(received, meta.sizeBytes);
      },
    );
    return MediaLocator(destPath);
  }

  @override
  Future<Uri> resolveCached(MediaLocator item) async {
    final path = await cachedFilePath(item);
    if (path == null) {
      throw CloudCacheMissException(item);
    }
    return Uri.file(path);
  }

  /// Absolute path of a cached file for [item], or `null` if missing.
  Future<String?> cachedFilePath(MediaLocator item) async {
    final fileId = DriveMediaLocator.decode(item);
    final dir = Directory(p.join(_cacheRoot.path, fileId));
    if (!await dir.exists()) return null;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is File) {
        return entity.path;
      }
    }
    return null;
  }

  String _safeFileName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'track.bin';
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
