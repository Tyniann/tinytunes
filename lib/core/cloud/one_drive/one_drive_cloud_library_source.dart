import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tinytunes/core/cloud/cloud_library_source.dart';
import 'package:tinytunes/core/cloud/cloud_provider_id.dart';
import 'package:tinytunes/core/cloud/free_space_source.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_media_locator.dart';
import 'package:tinytunes/core/cloud/one_drive/one_drive_remote.dart';
import 'package:tinytunes/core/library/media_locator.dart';
import 'package:tinytunes/features/library/application/audio_extensions.dart';
import 'package:tinytunes/features/library/application/library_entry_order.dart';

/// Personal OneDrive [CloudLibrarySource] (list / download / resolve cache).
///
/// Purpose: Read-only Graph access with on-disk cache keyed by drive/item ids.
/// Usage Context: Phase 4+ ingest and playback; inject [OneDriveRemote] in tests.
class OneDriveCloudLibrarySource implements CloudLibrarySource {
  /// Creates a source writing cache files under [cacheRootDirectory]/onedrive/.
  OneDriveCloudLibrarySource({
    required OneDriveRemote remote,
    required Directory cacheRootDirectory,
    FreeSpaceSource freeSpace = const UnlimitedFreeSpaceSource(),
  }) : _remote = remote,
       _cacheRoot = cacheRootDirectory,
       _freeSpace = freeSpace;

  final OneDriveRemote _remote;
  final Directory _cacheRoot;
  final FreeSpaceSource _freeSpace;

  Directory get _providerCacheRoot => Directory(
    p.join(_cacheRoot.path, CloudProviderId.oneDrive.cacheDirectoryName),
  );

  @override
  Future<List<CloudLibraryEntry>> list(MediaLocator parent) async {
    final List<OneDriveRemoteEntry> children;
    if (OneDriveMediaLocator.isPersonalRoot(parent)) {
      children = await _remote.listRootChildren();
    } else {
      final ids = OneDriveMediaLocator.decode(parent);
      children = await _remote.listChildren(
        driveId: ids.driveId,
        itemId: ids.itemId,
      );
    }
    final entries = [
      for (final child in children)
        if (child.isDirectory || isAudioFileName(child.name))
          CloudLibraryEntry(
            locator: OneDriveMediaLocator.encode(
              driveId: child.driveId,
              itemId: child.itemId,
            ),
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
    final ids = OneDriveMediaLocator.decode(item);
    final meta = await _remote.getFileMeta(
      driveId: ids.driveId,
      itemId: ids.itemId,
    );
    if (!isAudioFileName(meta.name)) {
      throw StateError(
        'Refusing to cache non-audio OneDrive file: ${meta.name}',
      );
    }

    final providerRoot = _providerCacheRoot;
    await providerRoot.create(recursive: true);
    final available = await _freeSpace.availableBytesFor(providerRoot.path);
    if (meta.sizeBytes > 0 && available < meta.sizeBytes) {
      throw InsufficientFreeSpaceException(
        requiredBytes: meta.sizeBytes,
        availableBytes: available,
      );
    }

    final destDir = Directory(
      p.join(providerRoot.path, meta.driveId, meta.itemId),
    );
    await destDir.create(recursive: true);
    final destPath = p.join(destDir.path, _safeFileName(meta.name));
    var received = 0;
    await _remote.downloadFile(
      driveId: meta.driveId,
      itemId: meta.itemId,
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
    final ids = OneDriveMediaLocator.decode(item);
    return _firstFileIn(
      Directory(p.join(_providerCacheRoot.path, ids.driveId, ids.itemId)),
    );
  }

  Future<String?> _firstFileIn(Directory dir) async {
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
